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
final class RefreshToken: Model {
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
}

// MARK: V1
extension RefreshToken {
    enum V1 {
        static let schemaName = "user_refresh_token"
        
        static let id =         FieldKey(stringLiteral: "id")
        static let token =      FieldKey(stringLiteral: "token")
        static let userID =     FieldKey(stringLiteral: "user_id")
        static let expiresAt =  FieldKey(stringLiteral: "expires_at")
        static let issuedAt =   FieldKey(stringLiteral: "issued_at")
        
        struct CreateRefreshToken: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(RefreshToken.V1.schemaName)
                    .id()
                    .field(RefreshToken.V1.token,       .string,        .required)
                    .field(RefreshToken.V1.userID,      .uuid,          .references(User.V1.schemaName, "id"), .required)
                    .field(RefreshToken.V1.expiresAt,   .datetime,      .required)
                    .field(RefreshToken.V1.issuedAt,    .datetime,      .required)
                    .create()
            }
            
            func revert(on database: Database) async throws {
                try await database.schema(RefreshToken.V1.schemaName).delete()
            }
        }
    }
}

