@testable import App
import XCTVapor
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct AuthenticationTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        }
        catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    // MARK: Login Requests
    
    // Attempt login with no existing user
    @Test("Failed Login Route")
    func failedLogin() async throws {
        try await withApp { app in
            let loginDTO = Auth_DTO.Login.Body(email: "noone@example.com", password: "12345")
            
            try await app.test(
                .POST, "api/auth/login",
                beforeRequest: { req in
                    try req.content.encode(loginDTO)
                },
                afterResponse: { res async in
                    #expect(res.status == .badRequest)
                })
        }
    }
    
    // Create a user, try to login with credentials
    @Test("Successful Login Route")
    func successfulLogin() async throws {
        try await withApp { app in
            let loginDTO = Auth_DTO.Login.Body(email: "test@test.com", password: "test123")
            let user = User(username: "test", fullName: "Test McGee",
                            email: "test@test.com", passwordHash: "test123",
                            isAdmin: true, isActive: true, isReset: false)
            
            try await user.create(on: app.db)
            try await app.test(
                .POST, "api/auth/login",
                beforeRequest: { req in
                    try req.content.encode(loginDTO)
                },
                afterResponse: { res async in
                    #expect(res.status == .ok)
                })
        }
    }
    
    // MARK: Protected Route Requests
    
    // Create a user, create a token, try to access a protected route using bearer auth
    @Test("Successful Protected Route access")
    func successfulProtectedRoute() async throws {
        try await withApp { app in
            let user = User(username: "test", fullName: "Test McGee",
                            email: "test@test.com", passwordHash: "test123",
                            isAdmin: true, isActive: true, isReset: false)
            try await user.create(on: app.db)
            let (_, accessToken) = try RefreshToken.newTokens(for: user, with: app)
            try await app.test(
                .GET, "api/users/current",
                beforeRequest: { req in
                    let bearerAuth = BearerAuthorization(token: accessToken)
                    req.headers.bearerAuthorization = bearerAuth
                },
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let userResp: User_DTO.V1.Model? = try res.content.decode(User_DTO.V1.Model.self)
                    #expect(userResp != nil)
                })
        }
    }
    
    // Create a user, create a token, try to access a protected route using bearer auth but fail.
    @Test("Failed protected route access")
    func failedProtectedRoute() async throws {
        try await withApp { app in
            let user = User(username: "test", fullName: "Test McGee",
                            email: "test@test.com", passwordHash: "test123",
                            isAdmin: true, isActive: true, isReset: false)
            try await user.create(on: app.db)
            let (_, _) = try RefreshToken.newTokens(for: user, with: app)
            
            try await app.test(
                .GET, "api/users/current",
                beforeRequest: { req in
                    let bearerAuth = BearerAuthorization(token: "2pWS6RQmdZpE0TQ93X")
                    req.headers.bearerAuthorization = bearerAuth
                },
                afterResponse: { res async throws in
                    #expect(res.status == .unauthorized)
                })
        }
    }
    
    // MARK: Token Requests
    // Create a user, token, hit refresh endpoint
    @Test("Succesful refresh token operation")
    func succesfulRefreshTokenRoute() async throws {
        try await withApp { app in
            let user = User(username: "test", fullName: "Test McGee",
                            email: "test@test.com", passwordHash: "test123",
                            isAdmin: true, isActive: true, isReset: false)
            try await user.create(on: app.db)
            let (refreshToken, accessToken) = try RefreshToken.newTokens(for: user, with: app)
            try await refreshToken.create(on: app.db)
            
            try await app.test(
                .POST, "api/auth/refresh",
                beforeRequest: { req in
                    let bearerAuth = BearerAuthorization(token: accessToken)
                    req.headers.bearerAuthorization = bearerAuth
                    let refreshRequest = Auth_DTO.Refresh.Body(refreshToken: refreshToken.token)
                    try req.content.encode(refreshRequest)
                },
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let body = try res.content.decode(Auth_DTO.Token.self)
                    #expect(!body.accessToken.isEmpty)
                })
        }
    }
}

extension Auth_DTO.Refresh.Body: Content {}
