//
//  UserController.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/7/24.
//

import Vapor


/// Endpoints to interact with `User` models
///
/// `http://localhost:8080/api/users/`
struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("users") { users in
            users.get("current", use: getCurrentUser)
        }
    }
    
    @Sendable private func getCurrentUser(_ req: Request) async throws -> User_DTO.V1.Model {
        let payload = try req.auth.require(Payload.self)
        
        guard let user: User = try await User.find(payload.userID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return try User_DTO.V1.Model(with: user)
    }
    
}

extension User_DTO.V1.Model: Content {}
