//
//  routes.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/6/24.
//

import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.routes.register(collection: AuthController())
}
