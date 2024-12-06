//
//  User.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/5/24.
//
import Vapor
import Fluent

/// A user in the system. Can login, receive token, perform actions through protected routes.
final class User: Model {
    static let schema = User.V1.schemaName
    
    @ID(key: .id)
    var id: UUID?
    
    @Timestamp(key: User.V1.createdAt, on: .create)
    var createdAt: Date?
    
    @Timestamp(key: User.V1.updatedAt, on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: User.V1.deletedAt, on: .delete)
    var deletedAt: Date?
    
    // contact
    
    /// Presentable username
    @Field(key:     User.V1.username)
    var username: String
    
    /// Full name of user (ex: John Appleseed)
    @Field(key:     User.V1.fullName)
    var fullName: String
    
    /// Email address of user
    @Field(key:     User.V1.email)
    var email: String
    
    /// Hashed password
    @Field(key:     User.V1.passwordHash)
    var passwordHash: String
    
    // bools
    
    /// Whether user is able to administrate the whole system
    @Field(key:     User.V1.isAdmin)
    var isAdmin: Bool
    
    /// Is not disabled
    @Field(key:     User.V1.isActive)
    var isActive: Bool
    
    /// Reset to be unlocked by administrator
    @Field(key:     User.V1.isReset)
    var isReset: Bool
    
    init() { }
    
    init(
        username: String,
        fullName: String,
        email: String,
        passwordHash: String,
        isAdmin: Bool,
        isActive: Bool,
        isReset: Bool
    ) {
        self.username = username
        self.fullName = fullName
        self.email = email
        self.passwordHash = passwordHash
        self.isAdmin = isAdmin
        self.isActive = isActive
        self.isReset = isReset
    }
}


// MARK: V1

extension User {
    enum V1 {
        static let schemaName =     "user"
        
        static let createdAt =      FieldKey(stringLiteral: "created_at")
        static let updatedAt =      FieldKey(stringLiteral: "updated_at")
        static let deletedAt =      FieldKey(stringLiteral: "deleted_at")
        
        static let username =       FieldKey(stringLiteral: "user_name")
        static let fullName =       FieldKey(stringLiteral: "full_name")
        static let email =          FieldKey(stringLiteral: "email")
        static let passwordHash =   FieldKey(stringLiteral: "password_hash")
        
        static let isAdmin =        FieldKey(stringLiteral: "is_admin")
        static let isActive =       FieldKey(stringLiteral: "is_active")
        static let isReset =        FieldKey(stringLiteral: "is_reset")
        
        // Unique constraints
        static let unique_user_email =  "no_duplicate_user_emails"
        static let unique_username =    "no_duplicate_usernames"
        
        
        /// Initial User table creation.
        struct CreateUser: AsyncMigration {
            var app: Application
            
            /// Preloaded admin@admin.com with password "password"
            func prepare(on database: Database) async throws {
                try await database.schema(User.V1.schemaName)
                    .id()
                    .field(User.V1.createdAt,       .datetime)
                    .field(User.V1.updatedAt,       .datetime)
                    .field(User.V1.deletedAt,       .datetime)
                
                    .field(User.V1.username,        .string,    .required)
                    .field(User.V1.fullName,        .string,    .required)
                    .field(User.V1.email,           .string,    .required)
                    .field(User.V1.passwordHash,    .string,    .required)
                
                    .field(User.V1.isAdmin,         .bool,      .required, .custom("DEFAULT FALSE"))
                    .field(User.V1.isReset,         .bool,      .required, .custom("DEFAULT FALSE"))
                    .field(User.V1.isActive,        .bool,      .required, .custom("DEFAULT FALSE"))
                
                    .unique(on: User.V1.username,   name: User.V1.unique_username)
                    .unique(on: User.V1.email,      name: User.V1.unique_user_email)
                
                    .create()
            
                // create a demo admin user on first migration
                if app.environment != .testing {
                    try await User(
                        username: "admin",
                        fullName: "Administrator",
                        email: "admin@admin.com",
                        passwordHash: try Bcrypt.hash("password"),
                        isAdmin: true,
                        isActive: true,
                        isReset: false)
                    .create(on: database)
                }
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(User.V1.schemaName)
                    .delete()
            }
        }
    }
}
