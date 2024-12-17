import Fluent

// MARK: - V1

extension Customer {
    enum V1 {
        static let schemaName = "customer"
        
        static let id =                 FieldKey(stringLiteral: "id")
        static let createdAt =          FieldKey(stringLiteral: "created_at")
        static let updatedAt =          FieldKey(stringLiteral: "updated_at")
        static let deletedAt =          FieldKey(stringLiteral: "deleted_at")
        
        static let firstName =          FieldKey(stringLiteral: "first_name")
        static let lastName =           FieldKey(stringLiteral: "last_name")
        
        static let business =           FieldKey(stringLiteral: "business")
        static let homepage =           FieldKey(stringLiteral: "homepage")
        
        static let lightspeedImportID = FieldKey(stringLiteral: "imported_lightspeed_id")
        static let uniqueLightspeedImportID: String =   "unique_customer_lightspeed_import_id"
        
        static let customerDefaultTax = FieldKey(stringLiteral: "customer_default_tax")
        
        
        /// Initial Customers table creation
        struct CreateCustomersDatabase: AsyncMigration {
            
            func prepare(on database: Database) async throws {
                try await database.schema(Customer.V1.schemaName)
                    
                    .field(Customer.V1.id,                  .int,       .identifier(auto: true))
                
                    .field(Customer.V1.createdAt,           .datetime)
                    .field(Customer.V1.updatedAt,           .datetime)
                    .field(Customer.V1.deletedAt,           .datetime)
                
                    .field(Customer.V1.firstName,           .string,    .required)
                    .field(Customer.V1.lastName,            .string,    .required)
                
                    .field(Customer.V1.business,             .uuid,     .references(BusinessCustomer.V1.schemaName, BusinessCustomer.V1.id))
                    .field(Customer.V1.homepage,            .string,    .required)
                
                
                    .field(Customer.V1.lightspeedImportID, .int)
                    .unique(on: Customer.V1.lightspeedImportID, name: Customer.V1.uniqueLightspeedImportID)
                
                    .field(Customer.V1.customerDefaultTax,  .uuid,      .references(Tax.V1.schemaName, Tax.V1.id))
                    .create()
                
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(Customer.V1.schemaName)
                    .delete()
            }
        }
        
    }
    
    /*
    /// Add reference to the `Customer_StripeLink` model
    enum V03_07_2024 {
        static let stripeCustomerID = FieldKey(stringLiteral: "stripe_customer_id")
        
        /// Add optional relation of `Customer_StripeLink` to the `Customer` model
        struct AddStripeCustomerID: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(Customer.V1.schemaName)
                    .field(Customer.V03_07_2024.stripeCustomerID, .int,
                           .references(Stripe_CustomerLink.V1.schemaName, Stripe_CustomerLink.V1.id)
                        )
                    .update()
            }
            
            func revert(on database: Database) async throws {
                try await database.schema(Customer.V1.schemaName)
                    .deleteField(Customer.V03_07_2024.stripeCustomerID)
                    .update()
            }
        }
    }
     */
    
}
