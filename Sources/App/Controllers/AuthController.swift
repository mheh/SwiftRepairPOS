//
//  AuthController.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/6/24.
//

import Vapor
import Fluent

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("auth") { auth in
            
            auth.post("login",              use: login)
            auth.post("refresh",            use: refreshToken)
            
            // auth required
            let protected = auth.grouped(
                UserAuthenticator(),
                Payload.guardMiddleware())
            protected.post("logout", use: logout)
        }
    }
    
    @Sendable private func login(_ req: Request) async throws -> Response {
        throw Abort(.notImplemented)
    }
    
    @Sendable private func refreshToken(_ req: Request) async throws -> Response {
        throw Abort(.notImplemented)
    }
    
    @Sendable private func logout(_ req: Request) async throws -> Response {
        throw Abort(.notImplemented)
    }
}
