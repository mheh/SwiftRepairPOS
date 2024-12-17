//
// - ProductMigrations.swift from  in 2023


import Fluent

// MARK: - V1

extension Product {
    enum V1 {
        static let schemaName = "product"
        
        static let id =                 FieldKey(stringLiteral: "id")
        static let lightspeedImportID = FieldKey(stringLiteral: "lightspeed_import_id")
        
        // MARK: DateTracking Protocol
        static let createdAt =          FieldKey(stringLiteral: "created_at")
        static let updatedAt =          FieldKey(stringLiteral: "updated_at")
        static let deletedAt =          FieldKey(stringLiteral: "deleted_at")
        
        // MARK: Model
        static let code =               FieldKey(stringLiteral: "code")
        static let upc =                FieldKey(stringLiteral: "upc")
        static let productDescription = FieldKey(stringLiteral: "product_description")
        static let sellPrice =          FieldKey(stringLiteral: "sell_price")
        
        static let taxable =            FieldKey(stringLiteral: "taxable")
        static let inventoried =        FieldKey(stringLiteral: "inventoried")
        static let serialized =         FieldKey(stringLiteral: "serialized")
        static let commissionID =       FieldKey(stringLiteral: "product_commissionable_id")
        
        static let manufacturer =       FieldKey(stringLiteral: "manufacturer")
        static let manufacturerType =   FieldKey(stringLiteral: "manufacturer_type")
        static let manufacturerModel =  FieldKey(stringLiteral: "manufacturer_model")
        
        static let unique_on_code =     "Unique product codes only"
        
        
        /// Initial Products table creation
        struct CreateProductsDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(Product.V1.schemaName)
                    .field(Product.V1.id,                   .int,   .identifier(auto: true))
                    .field(Product.V1.lightspeedImportID,   .int)
                
                // MARK: DateTracking Protocol
                    .field(Product.V1.createdAt,            .datetime)
                    .field(Product.V1.updatedAt,            .datetime)
                    .field(Product.V1.deletedAt,            .datetime)
                
                // MARK: Model
                    .field(Product.V1.code,                 .string, .required)
                    .field(Product.V1.upc,                  .string, .required)
                    .field(Product.V1.productDescription,   .string, .required)
                
                    .field(Product.V1.sellPrice,            .custom("NUMERIC(19,4)"), .required)
                
                    .field(Product.V1.taxable,              .bool, .required)
                    .field(Product.V1.inventoried,          .bool, .required)
                    .field(Product.V1.serialized,           .bool, .required)
                    .field(Product.V1.commissionID,         .uuid,
                        .references(Product_CommissionableInformation.V1.schemaName, "id"))
                
                    .field(Product.V1.manufacturer,         .string, .required)
                    .field(Product.V1.manufacturerType,     .string, .required)
                    .field(Product.V1.manufacturerModel,    .string, .required)
                
                    .unique(on: Product.V1.code, name: Product.V1.unique_on_code)
                    .create()
                
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(Product.V1.schemaName)
                    .delete()
            }
        }
    }
}

// MARK: - V2
extension Product {
    
    /// More fields to `Product` related to costs and bools
    ///     - `defaultCostID`: optional relation to a favored `ProductCost` model that should be used when recording `reference` information on line items.
    ///     - `averageCost`: any time a new `ProductCost` is added for this product, update the average cost field
    ///     - `editableSellPrice`: if a sell price is editable when being used as a lline item
    enum V2 {
    
        // MARK: New Fields
        static let defaultCostID =      FieldKey(stringLiteral: "default_cost_id")
        static let averageCost =        FieldKey(stringLiteral: "average_cost")
        static let editableSellPrice =  FieldKey(stringLiteral: "editable_sell_price")
            
        /// Add or remove `defaultCostID` and `averageCost` fields from the `Product` database schema
        struct ProductV2_AddCostInformation: AsyncMigration {
            
            func prepare(on database: Database) async throws {
                try await database.schema(Product.V1.schemaName)
                
                    .field(Product.V2.defaultCostID,
                           .uuid,
                           .references(ProductCost.V1.schemaName, "id")
                    )
                
                    .field(Product.V2.averageCost,
                           .custom("NUMERIC(19,4)"),
                           .required,
                        .sql(.default("0.00"))
                    )
                
                    .field(Product.V2.editableSellPrice, .bool, .required, .sql(.default(true)))
                    .update()
            }
            
            func revert(on database: Database) async throws {
                try await database.schema(Product.V1.schemaName)
                
                    .deleteField(Product.V2.defaultCostID)
                    .deleteField(Product.V2.averageCost)
                    .deleteField(Product.V2.editableSellPrice)
                
                    .update()
            }
            
        }
    }
}
