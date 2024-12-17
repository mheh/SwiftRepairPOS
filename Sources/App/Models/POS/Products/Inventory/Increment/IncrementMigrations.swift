import Vapor
import Fluent
import FluentSQL

// MARK: - V1

extension InventoryIncrement {
    enum V1 {
        static let schemaName = "product_inventory_increment"
        
        static let id =                 FieldKey(stringLiteral: "id")
        
        // MARK: DateTracking Protocol
        static let createdAt =          FieldKey(stringLiteral: "created_at")
        static let updatedAt =          FieldKey(stringLiteral: "updated_at")
        static let deletedAt =          FieldKey(stringLiteral: "deleted_at")
        
        // MARK: Model
        static let productID =          FieldKey(stringLiteral: "product_id")
        static let locationID =         FieldKey(stringLiteral: "product_location_id")
        static let amount =             FieldKey(stringLiteral: "amount")
        
        /// Initial InventoryIncrement table creation
        struct CreateInventoryIncrementDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(InventoryIncrement.V1.schemaName)
                    .field(InventoryIncrement.V1.id,                        .int,   .identifier(auto: true))
                
                // MARK: DateTracking Protocol
                    .field(InventoryIncrement.V1.createdAt,                 .datetime)
                    .field(InventoryIncrement.V1.updatedAt,                 .datetime)
                    .field(InventoryIncrement.V1.deletedAt,                 .datetime)
                
                // MARK: Model
                    .field(InventoryIncrement.V1.productID,                 .int,   .references(Product.V1.schemaName, "id"),               .required)
                    .field(InventoryIncrement.V1.locationID,                .uuid,  .references(InventoryLocation.V1.schemaName, "id"),     .required)
                    .field(InventoryIncrement.V1.amount,                    .int,                                                           .required)
                
                    .create()
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(InventoryIncrement.V1.schemaName).delete()
            }
        }
    }
}
