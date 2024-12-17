import Vapor
import Fluent

final class EntityLog: Model, Content, ModelDateTrackingProtocol, @unchecked Sendable {
    static let schema = EntityLog.V1.schemaName
    
    @ID var id: UUID?
    @Timestamp(key: EntityLog.V1.createdAt, on: .create)    var createdAt: Date?
    @Timestamp(key: EntityLog.V1.updatedAt, on: .update)    var updatedAt: Date?
    @Timestamp(key: EntityLog.V1.deletedAt, on: .delete)    var deletedAt: Date?
    
    @OptionalParent(key: EntityLog.V1.userID)               var userID: User?
    @Field(key: EntityLog.V1.userNote)                      var userNote: String
    @Field(key: EntityLog.V1.systemNote)                    var systemNote: String
    
    init() { }
    
    /// New log from user
    init(userID: User.IDValue, userNote: String) {
        self.$userID.id = userID
        self.userNote = userNote
        self.systemNote = ""
    }
    
    /// New system note
    init(systemNote: String) {
        self.$userID.id = nil
        self.userNote = ""
        self.systemNote = systemNote
    }
}

extension EntityLog {
    enum V1 {
        static let schemaName = "entity_log"
        
        // MARK: DateTracking Protocol
        static let createdAt =          FieldKey(stringLiteral: "created_at")
        static let updatedAt =          FieldKey(stringLiteral: "updated_at")
        static let deletedAt =          FieldKey(stringLiteral: "deleted_at")
        
        // MARK: Model
        static let userID =             FieldKey(stringLiteral: "user_id")
        static let userNote =               FieldKey(stringLiteral: "user_note")
        static let systemNote =         FieldKey(stringLiteral: "system_note")
        
        /// Initial InventoryIncrement table creation
        struct CreateEntityLogDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(EntityLog.V1.schemaName)
                    .id()
                
                // MARK: DateTracking Protocol
                    .field(EntityLog.V1.createdAt,                          .datetime)
                    .field(EntityLog.V1.updatedAt,                          .datetime)
                    .field(EntityLog.V1.deletedAt,                          .datetime)
                
                // MARK: Model
                    .field(EntityLog.V1.userID,                             .uuid,      .references(User.V1.schemaName, "id"))
                    .field(EntityLog.V1.userNote,                           .string,    .required)
                    .field(EntityLog.V1.systemNote,                         .string,    .required)
                
                    .create()
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(EntityLog.V1.schemaName).delete()
            }
        }
    }
}
