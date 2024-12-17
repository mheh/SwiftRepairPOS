//
// - CommissionProductMigrations.swift from  in 2023


import Vapor
import Fluent

extension Product_CommissionableInformation {
    enum V1 {
        static let schemaName = "product_commissionable"
        
        // MARK: DateTracking Protocol
        static let createdAt =          FieldKey(stringLiteral: "created_at")
        static let updatedAt =          FieldKey(stringLiteral: "updated_at")
        static let deletedAt =          FieldKey(stringLiteral: "deleted_at")
        
        // MARK: Descriptors
        static let title =              FieldKey(stringLiteral: "title")
        static let commDescription =    FieldKey(stringLiteral: "description")
        
        // MARK: Model
        static let commissionType =     FieldKey(stringLiteral: "type")
        static let amount =             FieldKey(stringLiteral: "amount")
        
        /// What type of commission is available for this sale?
        enum CommissionType: String, Codable {
            /// A set amount for each sale
            case flatAmount
            /// A percentage based off the sell price
            case percentageSell
            /// A percentage based off the margin available
            case percentageMargin
        }
        
        
        struct CreateProductComissionableDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(Product_CommissionableInformation.V1.schemaName)
                    .id()
                
                // MARK: DateTracking Protocol
                    .field(Product_CommissionableInformation.V1.createdAt,            .datetime)
                    .field(Product_CommissionableInformation.V1.updatedAt,            .datetime)
                    .field(Product_CommissionableInformation.V1.deletedAt,            .datetime)
                
                // MARK: Descriptors
                    .field(Product_CommissionableInformation.V1.title,                 .string,                    .required)
                    .field(Product_CommissionableInformation.V1.commissionType,        .string,                    .required)
                    .field(Product_CommissionableInformation.V1.amount,                .custom("NUMERIC(19,4)"),   .required)
                
                    .create()
                
            }
            
            func revert(on database: Database) async throws {
                try await database.schema(Product_CommissionableInformation.V1.schemaName)
                    .delete()
            }
        }
    }
    
}

