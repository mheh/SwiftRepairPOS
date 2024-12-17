
import Fluent

// MARK: - V1

extension ProductCost {
    enum V1 {
        static let schemaName = "product_costs"
        
        // static let id =                 FieldKey(stringLiteral: "id")
        
        // MARK: DateTracking Protocol
        static let createdAt =          FieldKey(stringLiteral: "created_at")
        static let updatedAt =          FieldKey(stringLiteral: "updated_at")
        static let deletedAt =          FieldKey(stringLiteral: "deleted_at")
        
        // MARK: Model
        static let productID =          FieldKey(stringLiteral: "product_id")
        static let supplierID =         FieldKey(stringLiteral: "supplier_id") // Optional
        
        static let defaultCost =        FieldKey(stringLiteral: "default_cost")
        static let cost =               FieldKey(stringLiteral: "cost")
        static let supplierCode =       FieldKey(stringLiteral: "supplier_code")
        
        /// Initial ProductCosts table creation
        struct CreateProductCostsDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(ProductCost.V1.schemaName)
                    .id()
                
                // MARK: DateTracking Protocol
                    .field(ProductCost.V1.createdAt,            .datetime)
                    .field(ProductCost.V1.updatedAt,            .datetime)
                    .field(ProductCost.V1.deletedAt,            .datetime)
                
                // MARK: Model
                    .field(ProductCost.V1.productID,            .int, .references(Product.V1.schemaName, "id"),    .required)
                    .field(ProductCost.V1.supplierID,           .int, .references(Supplier.V1.schemaName, "id"))   // Optional
                
                    .field(ProductCost.V1.defaultCost,          .bool,                                              .required)
                    .field(ProductCost.V1.cost,                 .custom("NUMERIC(19,4)"),                           .required)
                    .field(ProductCost.V1.supplierCode,         .string,                                            .required)
                
                    .create()
                
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(ProductCost.V1.schemaName)
                    .delete()
            }
        }

    }
    
}
