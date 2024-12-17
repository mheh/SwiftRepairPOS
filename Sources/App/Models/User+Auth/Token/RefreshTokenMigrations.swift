import Fluent

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
