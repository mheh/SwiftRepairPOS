import Fluent

// MARK: - V1

extension InventoryLocation {
    enum V1 {
        static let schemaName = "product_inventory_location"

        // static let id =                 FieldKey(stringLiteral: "id")

        // MARK: DateTracking Protocol
        static let createdAt =          FieldKey(stringLiteral: "created_at")
        static let updatedAt =          FieldKey(stringLiteral: "updated_at")
        static let deletedAt =          FieldKey(stringLiteral: "deleted_at")

        // MARK: Model
        static let name =               FieldKey(stringLiteral: "name")
        static let defaultLocation =    FieldKey(stringLiteral: "default_location")
        static let systemUseOnly =      FieldKey(stringLiteral: "system_use_only")
        static let canBeRemoved =       FieldKey(stringLiteral: "can_be_removed")

        // MARK: - System Use Only
        /// Locations that are informational in nature and cannot be removed. 
        /// Do not show these results in search queries for user to designate a location.
        ///     If a user sells a product, they don't have access to the location anymore
        ///     If a user transfers a product out, the inventory move transaction is targeted to "transfer out"
        ///     If a user receives a purchase order, the inventory move transaction originated from "purchase order receive"
        ///     If a user returns a purchase order, the inventory move transaction is targeted to "purchase order return"
        ///     If we lose track of where to put a product, we can put it in "unknown"
        enum SystemUseOnlyLocation {
            /// The location is progressing to another store location
            static let inTransit = "In Transit"
            /// The location of this inventory has successfully reached another store location
            static let transferredOut = "Transferred Out"
            /// The location of this inventory has successfully reached this store location
            static let transferredIn = "Transferred In"
            
            /// The location of this inventory is in "stock"
            static let stock = "Stock"
            /// The location of this inventory has been sold and is no longer here.
            static let sold = "Sold"
            /// The location of this inventory has been returned and is awaiting management
            static let returned = "Returned"
            
            
            /// The location of this inventory was created by a purchase order
            static let poReceive = "Purchase Order Receive"
            /// The location of this inventory has been returned by a purchase order
            static let poReturn = "Purchase Order Return"
            
            
            /// Catchall, we don't know what to do here.
            /// If we get things here, we have a problem and we're losing inventory somehow.
            static let unknown = "Unknown"
        }

        /// Initial InventoryLocation table creation
        struct CreateInventoryLocationDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(InventoryLocation.V1.schemaName)
                    .id()

                // MARK: DateTracking Protocol
                    .field(InventoryLocation.V1.createdAt,              .datetime)
                    .field(InventoryLocation.V1.updatedAt,              .datetime)
                    .field(InventoryLocation.V1.deletedAt,              .datetime)

                // MARK: Model
                    .field(InventoryLocation.V1.name,                   .string,  .required)
                    .field(InventoryLocation.V1.defaultLocation,        .bool,    .required)
                    .field(InventoryLocation.V1.systemUseOnly,          .bool,    .required)
                    .field(InventoryLocation.V1.canBeRemoved,           .bool,    .required)
                        
                    .create()

                // MARK: - Create System Use Only Locations
                // NOTE: try to match formatting in enum for the system locations (please)
                try await InventoryLocation(name: InventoryLocation.V1.SystemUseOnlyLocation.inTransit, defaultLocation: false, systemUseOnly: true, canBeRemoved: false)
                    .save(on: database)
                try await InventoryLocation(name: InventoryLocation.V1.SystemUseOnlyLocation.transferredOut, defaultLocation: false, systemUseOnly: true, canBeRemoved: false)
                    .save(on: database)
                try await InventoryLocation(name: InventoryLocation.V1.SystemUseOnlyLocation.transferredIn, defaultLocation: false, systemUseOnly: true, canBeRemoved: false)
                    .save(on: database)
                
                
                try await InventoryLocation(name: InventoryLocation.V1.SystemUseOnlyLocation.stock, defaultLocation: false, systemUseOnly: true, canBeRemoved: false)
                    .save(on: database)
                try await InventoryLocation(name: InventoryLocation.V1.SystemUseOnlyLocation.sold, defaultLocation: false, systemUseOnly: true, canBeRemoved: false)
                    .save(on: database)
                try await InventoryLocation(name: InventoryLocation.V1.SystemUseOnlyLocation.returned, defaultLocation: false, systemUseOnly: true, canBeRemoved: false)
                    .save(on: database)
                
                
                try await InventoryLocation(name: InventoryLocation.V1.SystemUseOnlyLocation.poReceive, defaultLocation: false, systemUseOnly: true, canBeRemoved: false)
                    .save(on: database)
                try await InventoryLocation(name: InventoryLocation.V1.SystemUseOnlyLocation.poReturn, defaultLocation: false, systemUseOnly: true, canBeRemoved: false)
                    .save(on: database)
                
                
                try await InventoryLocation(name: InventoryLocation.V1.SystemUseOnlyLocation.unknown, defaultLocation: false, systemUseOnly: true, canBeRemoved: false)
                    .save(on: database)

                
                // MARK: - Create Default Location
                try await InventoryLocation(name: "Stock", defaultLocation: true, systemUseOnly: false, canBeRemoved: false)
                    .save(on: database)
            }

            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(InventoryLocation.V1.schemaName).delete()
            }
        }
    }
}
