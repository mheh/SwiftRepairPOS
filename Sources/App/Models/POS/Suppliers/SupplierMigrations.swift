import Fluent

// MARK: - V1

extension Supplier {
    enum V1 {
        static let schemaName = "supplier"
        
        static let id =                 FieldKey(stringLiteral: "id")
        static let createdAt =          FieldKey(stringLiteral: "created_at")
        static let updatedAt =          FieldKey(stringLiteral: "updated_at")
        static let deletedAt =          FieldKey(stringLiteral: "deleted_at")
        
        static let supplierName =       FieldKey(stringLiteral: "supplier_name")
        static let firstName =          FieldKey(stringLiteral: "first_name")
        static let lastName =           FieldKey(stringLiteral: "last_name")
        
        static let homepage =           FieldKey(stringLiteral: "homepage")

        static let supplierDefaultTax = FieldKey(stringLiteral: "supplier_default_tax")
        static let lightspeedImportID = FieldKey(stringLiteral: "imported_lightspeed_id")
        
        static let unique_supplier_name = "no_duplicate_suppliers"
        static let uniqueLightspeedImportID: String = "unique_supplier_lightspeed_import_id"
        
        
        /// Initial Suppliers table creation
        struct CreateSupplierDatabase: AsyncMigration {
            
            func prepare(on database: Database) async throws {
                try await database.schema(Supplier.V1.schemaName)
                // ID
                    .field(Supplier.V1.id,                  .int,       .identifier(auto: true))
                    
                    .field(Supplier.V1.createdAt,           .datetime)
                    .field(Supplier.V1.updatedAt,           .datetime)
                    .field(Supplier.V1.deletedAt,           .datetime)
                
                // Model
                    .field(Supplier.V1.supplierName,        .string,    .required)
                    .field(Supplier.V1.firstName,           .string,    .required)
                    .field(Supplier.V1.lastName,            .string,    .required)
                
                    .field(Supplier.V1.homepage,            .string,    .required)
                
                    .field(Supplier.V1.supplierDefaultTax,  .uuid,      .references(Tax.V1.schemaName, Tax.V1.id))
                    .field(Supplier.V1.lightspeedImportID,  .int)
                
                
                // Unique
                    .unique(on: Supplier.V1.supplierName,   name: Supplier.V1.unique_supplier_name)
                    .unique(on: Supplier.V1.lightspeedImportID, name: Supplier.V1.uniqueLightspeedImportID)
                
                    .create()
                
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(Supplier.V1.schemaName)
                    .delete()
            }
        }

    }
    
}
