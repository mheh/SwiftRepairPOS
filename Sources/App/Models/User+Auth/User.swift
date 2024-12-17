import Vapor
import Fluent
import MWServerModels

/// A user in the system. Can login, receive token, perform actions through protected routes.
final class User: Model, @unchecked Sendable {
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

extension User_DTO.V1.Model {
    init(with user: User) throws {
        self.init(
            id: try user.requireID(),
            username: user.username,
            fullname: user.fullName,
            email: user.email,
            isAdmin: user.isAdmin,
            isActive: user.isActive,
            isReset: user.isReset)
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

// MARK: Error

enum UserError: AppError {
    
    // Login Route
    case passwordsDontMatch
    case emailAlreadyExists
    case invalidEmailOrPassword
    
    // Database lookup
    case userNotFound
    
    // Model booleans
    case userNotAdmin
    case userNotActive
    case userNotReset
    case userIsReset
    
}

extension UserError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
            
            // Login route
        case .passwordsDontMatch:
            return .badRequest
        case .emailAlreadyExists:
            return .badRequest
        case .invalidEmailOrPassword:
            return .badRequest
            
            // Database lookup
        case .userNotFound:
            return .notFound
            
            // Model booleans
        case .userNotAdmin:
            return .unauthorized
        case .userNotActive:
            return .unauthorized
        case .userNotReset:
            return .unauthorized
        case .userIsReset:
            return .unauthorized
        }
    }
    
    var reason: String {
        switch self {
            
            // Login route
        case .passwordsDontMatch:
            return "Passwords did not match."
        case .emailAlreadyExists:
            return "A user with that email already exists."
        case .invalidEmailOrPassword:
            return "Email or password was incorrect."
            
            // Database lookup
        case .userNotFound:
            return "User was not found."
            
            // Model booleans
        case .userNotAdmin:
            return "User is not an administrator."
        case .userNotActive:
            return "User is not active."
        case .userNotReset:
            return "User is not reset."
        case .userIsReset:
            return "User is reset."
        }
    }
    
    var identifier: String {
        switch self {
            
            // Login route
        case .passwordsDontMatch:
            return "passwords_dont_match"
        case .emailAlreadyExists:
            return "email_already_exists"
        case .invalidEmailOrPassword:
            return "invalid_email_or_password"
            
            // Database lookup
        case .userNotFound:
            return "user_not_found"
            
            // Model booleans
        case .userNotAdmin:
            return "user_not_admin"
        case .userNotActive:
            return "user_not_active"
        case .userNotReset:
            return "user_not_reset"
        case .userIsReset:
            return "user_is_reset"
        }
    }
}

