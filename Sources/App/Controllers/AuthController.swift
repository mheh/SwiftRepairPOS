//
//  AuthController.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/6/24.
//

import Vapor
import Fluent
import MWServerModels

/// Endpoints for interaction with authentication
///
/// `http://localhost:8080/api/auth/`
struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("auth") { auth in
            auth.post("login", use: login)
            auth.post("refresh", use: refreshToken)
            
            // auth required
            let protected = auth.grouped(UserAuthenticator(), Payload.guardMiddleware())
            protected.post("logout", use: logout)
        }
    }
    
    // Login to an existing user, return user and token
    @Sendable private func login(_ req: Request) async throws -> Auth_DTO.Login.Response {
        let loginRequest = try req.content.decode(Auth_DTO.Login.Body.self)
        try Auth_DTO.Login.Body.validate(content: req)
        
        // Find user
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first() else {
            throw Abort(.badRequest)
        }
        
        // Verify user status
        guard user.isActive, !user.isReset else {
            throw Abort(.badRequest)
        }
        
        // check provided password
        guard try req.password.verify(loginRequest.password, created: user.passwordHash) else {
            // TODO: Implement login count and increment here
            throw Abort(.badRequest)
        }
        
        // Delete lost, expired tokens
        try await RefreshToken.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .delete()
        
        // Create the refresh token
        let (refreshToken, accessToken) = try RefreshToken.newTokens(for: user, with: req.application)
        try await refreshToken.create(on: req.db)
        
        // TODO: Implement login attempt count and reset here
        
        return Auth_DTO.Login.Response(
            token: .init(
                accessToken: accessToken,
                accessExpiration: "\(Date().addingTimeInterval(CONSTANT_TOKEN_ACCESS_LIFETIME))",
                refreshToken: refreshToken.token,
                refreshExpiration: "\(Date().addingTimeInterval(CONSTANT_TOKEN_REFRESH_LIFETIME))"
            ),
            user: try .init(from: user)
        )
    }
    
    // Lookup a refresh token and return a new one if everything is valid
    @Sendable private func refreshToken(_ req: Request) async throws -> Auth_DTO.Token {
        let refreshRequest = try req.content.decode(Auth_DTO.Refresh.Body.self)
        
        // We got a hitbox, delete the token
        guard let foundToken = try await RefreshToken.query(on: req.db)
            .filter(\.$token == refreshRequest.refreshToken)
            .first()
        else {
            throw RefreshTokenError.refreshTokenOrUserNotFound
        }
        // if we find a token here delete it if something else goes wrong down the line
        try await foundToken.delete(on: req.db)
        
        // Popcorn.gif
        guard foundToken.expiresAt > Date()
        else {
            throw RefreshTokenError.refreshTokenHasExpired
        }
        
        // Find the user
        guard let user = try await User.find(foundToken.$user.id, on: req.db)
        else {
            throw RefreshTokenError.refreshTokenOrUserNotFound
        }
        
        // Delete lost, expired tokens.
        // This should be a job at some point
//        try await RefreshToken.deleteExpired(for: user.requireID())
        
        // Verify credentials
        guard user.isActive else { throw UserError.userNotActive }
        guard !user.isReset else { throw UserError.userIsReset }
        
        // New token
        let token = req.random.generate(bits: 256)
        let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())
        try await refreshToken.create(on: req.db)
        let payload = try Payload(user: user)
        let accessToken = try req.jwt.sign(payload)
        
        
        return Auth_DTO.Token(
            accessToken: accessToken,
            accessExpiration: "\(Date().addingTimeInterval(CONSTANT_TOKEN_ACCESS_LIFETIME))",
            refreshToken: token,
            refreshExpiration: "\(Date().addingTimeInterval(CONSTANT_TOKEN_REFRESH_LIFETIME))"
        )
    }
    
    
    @Sendable private func logout(_ req: Request) async throws -> Response {
        throw Abort(.notImplemented)
    }
}

// MARK: DTO extensions

extension Auth_DTO.Login.Body: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("email",        as: String.self, is: .email)
        validations.add("password",     as: String.self, is: !.empty)
    }
}

extension Auth_DTO.Token: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("accessToken",  as: String.self, is: !.empty)
        validations.add("refreshToken", as: String.self, is: !.empty)
    }
}

// conform to content
extension Auth_DTO.Login.Body: Content {}
extension Auth_DTO.Login.Response: Content {}
extension Auth_DTO.Token: Content {}

// initialize DTO with a given user
extension User_DTO.V1.Model {
    init(from user: User) throws {
        self.init(
            id: try user.requireID(),
            username: user.username,
            fullname: user.fullName,
            email: user.email,
            isAdmin: user.isAdmin,
            isActive: user.isActive,
            isReset: user.isReset)
    }
}
