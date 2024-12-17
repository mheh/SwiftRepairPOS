import Fluent

// MARK: - V1

extension BusinessCustomer {
    enum V1 {
        static let schemaName = "customer_business"
        
        static let id =                     FieldKey(stringLiteral: "id")
        static let createdAt =              FieldKey(stringLiteral: "created_at")
        static let updatedAt =              FieldKey(stringLiteral: "updated_at")
        static let deletedAt =              FieldKey(stringLiteral: "deleted_at")
        
        static let businessName =           FieldKey(stringLiteral: "business_name")
        static let businessDefaultTax =     FieldKey(stringLiteral: "business_default_tax")
        
        /// Unique constraint on company name.
        /// Prevent duplicate names in company table.
        static let unique_business_name = "no_duplicate_business_names"
        
        /// Initial business customer table creation
        struct CreateBusinessCustomersMigration: AsyncMigration {
            
            func prepare(on database: Database) async throws {
                try await database.schema(BusinessCustomer.V1.schemaName)
                    .id()
                    
                    .field(BusinessCustomer.V1.createdAt,               .datetime)
                    .field(BusinessCustomer.V1.updatedAt,               .datetime)
                    .field(BusinessCustomer.V1.deletedAt,               .datetime)
                
                    .field(BusinessCustomer.V1.businessName,            .string,    .required)
                    .field(BusinessCustomer.V1.businessDefaultTax,      .uuid,      .references(Tax.V1.schemaName, Tax.V1.id))
                
                    .unique(on: BusinessCustomer.V1.businessName,       name: BusinessCustomer.V1.unique_business_name)
                
                    .create()
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(BusinessCustomer.V1.schemaName)
                    .delete()
            }
        }
    }
}
