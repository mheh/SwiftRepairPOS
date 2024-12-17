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
            permissions: .init(), // FIXME: PLACEHOLDER BECAUSE NO PERMISSIONS IMPLEMENTED YET
            isAdmin: user.isAdmin,
            isActive: user.isActive,
            isReset: user.isReset)
    }
}

