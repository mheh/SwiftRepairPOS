//
//  migrations.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/5/24.
//
import Vapor

func migrations(_ app: Application) throws {
    // Pass in app for app.environment here
    app.migrations.add(User.V1.CreateUser(app: app))
    app.migrations.add(RefreshToken.V1.CreateRefreshToken())
}
