import Vapor
import Fluent

// MARK: - Phone Pivot Model Definition
/// Pivot model to track `Supplier` phone numbers
final class SupplierPhonePivot: Model, @unchecked Sendable {
    static let schema = SupplierPhonePivot.V1.schemaName
    
    @ID var id: UUID?
    @Parent(key: SupplierPhonePivot.V1.supplierID)              var supplierID: Supplier
    @Parent(key: SupplierPhonePivot.V1.contactPhoneNumberID)    var contactPhoneNumberID: PhoneNumber
    
    init () {}
    
    enum V1 {
        // MARK: FieldKeys
        static let schemaName = "supplier+contact_phone_number"
        
        static let supplierID =             FieldKey(stringLiteral: "supplier_id")
        static let contactPhoneNumberID =   FieldKey(stringLiteral: "contact_phone_number_id")
        
        // MARK: Migraiton
        struct CreateSupplierPhoneNumberPivotDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(SupplierPhonePivot.V1.schemaName)
                    .id()
                
                    .field(SupplierPhonePivot.V1.supplierID,            .int,
                           .references(Supplier.V1.schemaName, "id"),       .required)
                
                    .field(SupplierPhonePivot.V1.contactPhoneNumberID,  .uuid,
                           .references(PhoneNumber.V1.schemaName, "id"),    .required)
                
                    .create()
            }
            func revert(on database: Database) async throws {
                try await database.schema(SupplierPhonePivot.V1.schemaName)
                    .delete()
            }
        }
    }
}


// MARK: - Email Address Model Definition
/// Pivot model to track `Supplier` email addresses
final class SupplierEmailAddressPivot: Model {
    static let schema = SupplierEmailAddressPivot.V1.schemaName
    
    @ID var id: UUID?
    @Parent(key: SupplierEmailAddressPivot.V1.supplierID)               var supplierID: Supplier
    @Parent(key: SupplierEmailAddressPivot.V1.contactEmailAddressID)    var emailAddressID: EmailAddress
    
    init() {}
    
    enum V1 {
        // MARK: FieldKeys
        static let schemaName = "supplier+contact_email_address"
        
        static let supplierID =         FieldKey(stringLiteral: "supplier_id")
        static let contactEmailAddressID = FieldKey(stringLiteral: "contact_email_address_id")
        
        // MARK: Migration
        struct CreateSupplierEmailAddressPivotDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(SupplierEmailAddressPivot.V1.schemaName)
                    .id()
                
                    .field(SupplierEmailAddressPivot.V1.supplierID,             .int,
                           .references(Supplier.V1.schemaName, "id"),       .required)
                    .field(SupplierEmailAddressPivot.V1.contactEmailAddressID,  .uuid,
                           .references(EmailAddress.V1.schemaName, "id"),   .required)
                
                    .create()
            }
            func revert(on database: Database) async throws {
                try await database.schema(SupplierEmailAddressPivot.V1.schemaName)
                    .delete()
            }
        }
        
    }
}

// MARK: - Street Address Model Definition
/// Pivot model to track `Supplier` street addresses
final class SupplierStreetAddressPivot: Model {
    static let schema: String = SupplierStreetAddressPivot.V1.schemaName
    
    @ID var id: UUID?
    
    @Parent(key: SupplierStreetAddressPivot.V1.supplierID)              var supplierID: Supplier
    @Parent(key: SupplierStreetAddressPivot.V1.contactStreetAddress)    var streetAddressID: StreetAddress
    
    init () {}
    
    enum V1 {
        // MARK: FieldKeys
        static let schemaName = "supplier+contact_street_address"
        
        static let supplierID =             FieldKey(stringLiteral: "supplier_id")
        static let contactStreetAddress =   FieldKey(stringLiteral: "contact_street_address_id")
        
        struct CreateSupplierStreetAddressPivotDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(SupplierStreetAddressPivot.V1.schemaName)
                    .id()
                
                    .field(SupplierStreetAddressPivot.V1.supplierID,             .int,
                           .references(Supplier.V1.schemaName, "id"),       .required)
                    .field(SupplierStreetAddressPivot.V1.contactStreetAddress,  .uuid,
                           .references(StreetAddress.V1.schemaName, "id"),  .required)
                
                
                    .create()
            }
            func revert(on database: Database) async throws {
                try await database.schema(SupplierStreetAddressPivot.V1.schemaName)
                    .delete()
            }
        }
    }
}

// MARK: - Entity Log Model Definition
/// Pivot model to track `Supplier` logs
final class SupplierLogPivot: Model, EntityLogPivotModelProtocol {
    static let schema: String = SupplierLogPivot.V1.schemaName
    
    @ID var id: UUID?
    
    @Parent(key: SupplierLogPivot.V1.supplierID)    var modelID: Supplier
    @Parent(key: SupplierLogPivot.V1.entityLogID)   var entityLogID: EntityLog

    init () {}
    
    enum V1 {
        // MARK: FieldKeys
        static let schemaName = "supplier+log"
        
        static let supplierID =             FieldKey(stringLiteral: "supplier_id")
        static let entityLogID =            FieldKey(stringLiteral: "entity_log_id")
        
        struct CreateSupplierLogPivotDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(SupplierLogPivot.V1.schemaName)
                    .id()
                
                    .field(SupplierLogPivot.V1.supplierID,             .int,
                           .references(Supplier.V1.schemaName, "id"),       .required)
                    .field(SupplierLogPivot.V1.entityLogID,  .uuid,
                           .references(EntityLog.V1.schemaName, "id"),  .required)
                
                
                    .create()
            }
            func revert(on database: Database) async throws {
                try await database.schema(SupplierLogPivot.V1.schemaName)
                    .delete()
            }
        }
    }
}
