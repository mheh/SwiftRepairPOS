import Fluent

extension Tax {
    enum V1 {
        static let schemaName = "settings_tax"
        
        static let id =         FieldKey(stringLiteral: "id")
        static let createdAt =  FieldKey(stringLiteral: "created_at")
        static let updatedAt =  FieldKey(stringLiteral: "updated_at")
        static let deletedAt =  FieldKey(stringLiteral: "deleted_at")
        
        static let currencyID = FieldKey(stringLiteral: "currency_id")
        static let taxCode =    FieldKey(stringLiteral: "tax_code")
        static let taxRate =    FieldKey(stringLiteral: "tax_rate")
        static let defaultTax = FieldKey(stringLiteral: "default")
        static let removable =  FieldKey(stringLiteral: "removable")
        
        /// Unique constraint on tax_code
        /// Prevent duplicate tax codes.
        static let unique_tax_code = "no_duplicate_tax_codes"
        
        
        /// Initial Tax table creation
        struct CreateTaxDatabase: AsyncMigration {
            /// Migrate
            func prepare(on database: Database) async throws {
                try await database.schema(Tax.V1.schemaName)
                    .id()
                    .field(Tax.V1.createdAt,        .datetime)
                    .field(Tax.V1.updatedAt,        .datetime)
                    .field(Tax.V1.deletedAt,        .datetime)
                
                    .field(Tax.V1.currencyID,       .uuid,                      .required,      .references(Currency.V1.schemaName, "id"))
                    .field(Tax.V1.taxCode,          .string,                    .required)
                    .field(Tax.V1.taxRate,          .custom("NUMERIC(19,4)"),   .required)
                    .field(Tax.V1.defaultTax,       .bool,                      .required)
                
                    .field(Tax.V1.removable,        .bool,                      .required, .custom("DEFAULT TRUE"))
                    .unique(on: Tax.V1.taxCode,     name: Tax.V1.unique_tax_code)
                
                    .create()
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(Tax.V1.schemaName)
                    .delete()
            }
        }
    }
}
