import Fluent

// MARK: - V1

extension Currency {
    /// Initial model
    enum V1 {
        static let schemaName =     "settings_currency"
        
        static let id =             FieldKey(stringLiteral: "id")
        static let createdAt =      FieldKey(stringLiteral: "created_at")
        static let updatedAt =      FieldKey(stringLiteral: "updated_at")
        static let deletedAt =      FieldKey(stringLiteral: "deleted_at")
        
        static let name =           FieldKey(stringLiteral: "name")
        static let code =           FieldKey(stringLiteral: "code")
        static let exchangeRate =   FieldKey(stringLiteral: "exchange_rate")
        static let isDefault =      FieldKey(stringLiteral: "is_default")
        
        static let unique_name = "no_duplicate_currency_names"
        
        /// Initial currency table creation
        struct CreateCurrencyDatabase: AsyncMigration {
            /// Preload USD as default currency
            func prepare(on database: FluentKit.Database) async throws {
                try await database.schema(Currency.V1.schemaName)
                    .id()
                    .field(Currency.V1.createdAt,       .datetime)
                    .field(Currency.V1.updatedAt,       .datetime)
                    .field(Currency.V1.deletedAt,       .datetime)
                
                    .field(Currency.V1.name,            .string,                        .required)
                    .field(Currency.V1.code,            .string,                        .required)
                    .field(Currency.V1.exchangeRate,    .custom("NUMERIC(19,4)"),       .required)
                    .field(Currency.V1.isDefault,       .bool,                          .required)
                
                    .unique(on: Currency.V1.name,   name: Currency.V1.unique_name)
                
                    .create()
                
                let defaultCurrency = Currency(name: "US", exchangeRate: 1.00, code: .USD, isDefault: true)
                try await defaultCurrency.create(on: database)
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(Currency.V1.schemaName)
                    .delete()
            }
            
        }
    }
}
