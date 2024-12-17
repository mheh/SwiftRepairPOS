//
//  RefreshToken.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/5/24.
//

import Vapor
import Fluent

// MARK: - Model Definition

/// The token sent with a `Payload` model to the user after a successful login attempt.
/// This token allows the user to request a new `access token` after expiration.
final class RefreshToken: Model, @unchecked Sendable {
    static let schema = RefreshToken.V1.schemaName
    
    @ID var id: UUID?
    
    /// Date created
    @Field(key: RefreshToken.V1.issuedAt)
    var issuedAt: Date
    
    /// The token to authorize with
    @Field(key: RefreshToken.V1.token)
    var token: String
    
    /// User registered to this refresh token
    @Parent(key: RefreshToken.V1.userID)
    var user: User
    
    /// Expiration date
    @Field(key: RefreshToken.V1.expiresAt)
    var expiresAt: Date
    
    init() {}
    
    init(
        id:         UUID? = nil,
        token:      String,
        userID:     UUID,
        expiresAt:  Date = Date().addingTimeInterval(CONSTANT_TOKEN_REFRESH_LIFETIME),
        issuedAt:   Date = Date()
    ) {
        self.id = id
        self.token = token
        self.$user.id = userID
        self.expiresAt = expiresAt
        self.issuedAt = issuedAt
    }
    
    /// Return a new `RefreshToken` and `accessToken` string
    static func newTokens(for user: User, with app: Application) throws -> (RefreshToken, String) {
        let token = app.random.generate(bits: 256)
        let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())
        let payload = try Payload(user: user)
        let accessToken = try app.jwt.signers.sign(payload)
        return (refreshToken, accessToken)
    }
}

