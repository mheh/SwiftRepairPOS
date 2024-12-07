//
//  routes.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/6/24.
//

import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.group("api") { api in
        try! api.register(collection: AuthController())
        
        // Payload protected routes
        let protected = api.grouped(UserAuthenticator(), Payload.guardMiddleware())
        try! protected.register(collection: UserController())
    }
}
