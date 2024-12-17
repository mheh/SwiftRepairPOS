import Vapor
import Fluent

// MARK: - Phone Pivot Model Definition
/// Pivot model to track customer phone numbers
final class CustomerPhonePivot: Model {
    static let schema = CustomerPhonePivot.V1.schemaName
    
    @ID var id: UUID?
    @Parent(key: CustomerPhonePivot.V1.customerID)              var customerID: Customer
    @Parent(key: CustomerPhonePivot.V1.contactPhoneNumberID)    var contactPhoneNumberID: PhoneNumber
    
    init () {}
    
    enum V1 {
        // MARK: FieldKeys
        static let schemaName = "customer+contact_phone_number"
        
        static let customerID =             FieldKey(stringLiteral: "customer_id")
        static let contactPhoneNumberID =   FieldKey(stringLiteral: "contact_phone_number_id")
        
        // MARK: Migraiton
        struct CreateCustomerPhoneNumberPivotDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(CustomerPhonePivot.V1.schemaName)
                    .id()
                
                    .field(CustomerPhonePivot.V1.customerID,            .int,
                           .references(Customer.V1.schemaName, "id"),       .required)
                
                    .field(CustomerPhonePivot.V1.contactPhoneNumberID,  .uuid,
                           .references(PhoneNumber.V1.schemaName, "id"),    .required)
                
                    .create()
            }
            func revert(on database: Database) async throws {
                try await database.schema(CustomerPhonePivot.V1.schemaName)
                    .delete()
            }
        }
    }
}


// MARK: - Email Address Model Definition
/// Pivot model to track customer email addresses
final class CustomerEmailAddressPivot: Model {
    static let schema = CustomerEmailAddressPivot.V1.schemaName
    
    @ID var id: UUID?
    @Parent(key: CustomerEmailAddressPivot.V1.customerID)               var customerID: Customer
    @Parent(key: CustomerEmailAddressPivot.V1.contactEmailAddressID)    var emailAddressID: EmailAddress
    
    init() {}
    
    enum V1 {
        // MARK: FieldKeys
        static let schemaName = "customer+contact_email_address"
        
        static let customerID =         FieldKey(stringLiteral: "customer_id")
        static let contactEmailAddressID = FieldKey(stringLiteral: "contact_email_address_id")
        
        // MARK: Migration
        struct CreateCustomerEmailAddressPivotDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(CustomerEmailAddressPivot.V1.schemaName)
                    .id()
                
                    .field(CustomerEmailAddressPivot.V1.customerID,             .int,
                           .references(Customer.V1.schemaName, "id"),       .required)
                    .field(CustomerEmailAddressPivot.V1.contactEmailAddressID,  .uuid,
                           .references(EmailAddress.V1.schemaName, "id"),   .required)
                
                    .create()
            }
            func revert(on database: Database) async throws {
                try await database.schema(CustomerEmailAddressPivot.V1.schemaName)
                    .delete()
            }
        }
        
    }
}

// MARK: - Street Address Model Definition
/// Pivot model to track customer street addresses
final class CustomerStreetAddressPivot: Model {
    static let schema: String = CustomerStreetAddressPivot.V1.schemaName
    
    @ID var id: UUID?
    
    @Parent(key: CustomerStreetAddressPivot.V1.customerID)              var customerID: Customer
    @Parent(key: CustomerStreetAddressPivot.V1.contactStreetAddress)    var streetAddressID: StreetAddress
    
    init () {}
    
    enum V1 {
        // MARK: FieldKeys
        static let schemaName = "customer+contact_street_address"
        
        static let customerID =             FieldKey(stringLiteral: "customer_id")
        static let contactStreetAddress =   FieldKey(stringLiteral: "contact_street_address_id")
        
        struct CreateCustomerStreetAddressPivotDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(CustomerStreetAddressPivot.V1.schemaName)
                    .id()
                
                    .field(CustomerStreetAddressPivot.V1.customerID,             .int,
                           .references(Customer.V1.schemaName, "id"),       .required)
                    .field(CustomerStreetAddressPivot.V1.contactStreetAddress,  .uuid,
                           .references(StreetAddress.V1.schemaName, "id"),  .required)
                
                
                    .create()
            }
            func revert(on database: Database) async throws {
                try await database.schema(CustomerStreetAddressPivot.V1.schemaName)
                    .delete()
            }
        }
    }
}

// MARK: - Loggable Model Definition
/// Pivot model to track customer logs
final class CustomerLog: Model, EntityLogPivotModelProtocol {
    static var schema: String = "\(Customer.schema)_log"
    
    @ID var id: UUID?
    @Parent(key: "entity_log_id") var entityLogID: EntityLog
    @Parent(key: "customer_id") var modelID: Customer
    
    init() {}
}
