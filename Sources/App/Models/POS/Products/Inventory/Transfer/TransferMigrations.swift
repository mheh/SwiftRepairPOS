//
// - TransferMigrations.swift from  in 2023


import Fluent

// MARK: - V1

extension InventoryTransfer {
    enum V1 {
        static let schemaName = "product_inventory_transfer"

        static let id =                     FieldKey(stringLiteral: "id")

        // MARK: DateTracking Protocol
        static let createdAt =              FieldKey(stringLiteral: "created_at")
        static let updatedAt =              FieldKey(stringLiteral: "updated_at")
        static let deletedAt =              FieldKey(stringLiteral: "deleted_at")

        // MARK: Model
        static let type =                   FieldKey(stringLiteral: "type")
        static let fromLocationID =         FieldKey(stringLiteral: "from_product_location_id")
        static let toLocationID =           FieldKey(stringLiteral: "to_product_location_id")
        static let fromIncrementID =        FieldKey(stringLiteral: "from_product_inventory_increment_id")
        static let toIncrementID =          FieldKey(stringLiteral: "to_product_inventory_increment_id")
        
        // TODO: Add multi-store support
        //static let fromMultiStoreID =       FieldKey(stringLiteral: "from_multistore_id")
        //static let toMultiStoreID =         FieldKey(stringLiteral: "to_multistore_id")

        static let userID =                 FieldKey(stringLiteral: "user_id")
        static let notes =                  FieldKey(stringLiteral: "notes")
    
    /// The types of inventory transfers that can be performed
    enum TransferType: String, Codable {
        case transfer = "location_transfer"
        case adjustment = "adjustment"
        case multiStoreTransfer = "multistore_transfer"
    }

    /// Initial Inventory Transfers table creation
    struct CreateInventoryTransfersDatabase: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema(InventoryTransfer.V1.schemaName)
                .field(InventoryTransfer.V1.id,                     .int,   .identifier(auto: true))

            // MARK: DateTracking Protocol
                .field(InventoryTransfer.V1.createdAt,              .datetime)
                .field(InventoryTransfer.V1.updatedAt,              .datetime)
                .field(InventoryTransfer.V1.deletedAt,              .datetime)

            // MARK: Model
                .field(InventoryTransfer.V1.type,                   .string, .required)
                .field(InventoryTransfer.V1.fromLocationID,         .uuid, .references(InventoryLocation.V1.schemaName, "id"))
                .field(InventoryTransfer.V1.toLocationID,           .uuid, .references(InventoryLocation.V1.schemaName, "id"),   .required)
                .field(InventoryTransfer.V1.fromIncrementID,        .int, .references(InventoryIncrement.V1.schemaName, "id"))
                .field(InventoryTransfer.V1.toIncrementID,          .int, .references(InventoryIncrement.V1.schemaName, "id"), .required)
                
            
                // TODO: Add multi-store support
                //.field(InventoryTransfer.V1.fromMultiStoreID,      .uuid)
                //.field(InventoryTransfer.V1.toMultiStoreID,        .uuid)
                
                .field(InventoryTransfer.V1.userID,                 .uuid, .references(User.V1.schemaName, "id"),                .required)
                .field(InventoryTransfer.V1.notes,                  .string, .required)

                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(InventoryTransfer.V1.schemaName).delete()
        }
    }
    }
}
