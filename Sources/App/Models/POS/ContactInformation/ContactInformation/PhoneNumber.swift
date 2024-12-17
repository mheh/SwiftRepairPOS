import Fluent
import Vapor

import MWServerModels

// MARK: - Model Definition

/// Phone number model for pivots to contacts
final class PhoneNumber: Model, Content, ContactCommunicationProtocol, @unchecked Sendable {
    
    static let schema = PhoneNumber.V1.schemaName
    
    @ID                                         var id: UUID?
    
    /// The type of phone number being saved
    @Field(key: PhoneNumber.V1.phoneType)       var phoneType: PhoneNumber.V1.PhoneType
    /// The actual number without formatting
    @Field(key: PhoneNumber.V1.number)          var number: String
    
    /// Whether this phone is the primary phone
    @Field(key: PhoneNumber.V1.primary)         var primary: Bool
    /// Whether this person has authorized this phone with us
    @Field(key: PhoneNumber.V1.authorized)      var authed: Bool
    /// Whether this person has authorized communication about stuff pertaining to them
    @Field(key: PhoneNumber.V1.authorizedCommunication)       var authed_communication: Bool
    /// Whether this person has authorized receiving marketing deals
    @Field(key: PhoneNumber.V1.authorizedMarketing)   var authed_marketing: Bool
    
    init () {}
    
    /// Create a new phone that's not authorized
    init(primary: Bool = true, phoneType: PhoneNumber.V1.PhoneType, number: String) {
        self.primary = primary
        self.phoneType = phoneType
        self.number = number
        self.authed = false
        self.authed_communication = false
        self.authed_marketing = false
    }
    
    /// Init from a create request
    /// Not authed for anything
    init(from mwphone: PhoneNumber_DTO.V1.CreateRequest) {
        self.phoneType = mwphone.phoneType
        self.number = mwphone.number
        self.primary = false
        self.authed = false
        self.authed_communication = false
        self.authed_marketing = false
    }
}

// MARK: - Migrations
extension PhoneNumber {
    enum V1 {
        // MARK: FieldKeys
        static let schemaName = "contact_phone_number"
        
        static let primary =                    FieldKey(stringLiteral: "primary")
        static let phoneType =                  FieldKey(stringLiteral: "phone_type")
        static let number =                     FieldKey(stringLiteral: "phone_number")
        
        static let authorized =                 FieldKey(stringLiteral: "phone_authorized")
        static let authorizedCommunication =    FieldKey(stringLiteral: "phone_authorized_communication")
        static let authorizedMarketing =        FieldKey(stringLiteral: "phone_authorized_marketing")
        
        
        typealias PhoneType = PhoneNumber_DTO.V1.PhoneType
        
        // MARK: Migration
        /// Initial PhoneNumber table creation
        struct CreatePhoneNumberDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(PhoneNumber.V1.schemaName)
                    .id()
                
                    .field(PhoneNumber.V1.primary,          .bool,      .required)
                
                    .field(PhoneNumber.V1.phoneType,        .string,    .required)
                    .field(PhoneNumber.V1.number,           .string,       .required)
                
                    .field(PhoneNumber.V1.authorized,       .bool,      .required)
                    .field(PhoneNumber.V1.authorizedCommunication,        .bool,      .required)
                    .field(PhoneNumber.V1.authorizedMarketing,    .bool,      .required)
                
                    .create()
            }
            func revert(on database: Database) async throws {
                try await database.schema(PhoneNumber.V1.schemaName)
                    .delete()
            }
        }
    }
}

// MARK: - MWModels Initializer Extension
extension PhoneNumber_DTO.V1.Model {
    /// Transfer model to client
    init(from phone: PhoneNumber) throws {
        self.init(
            id: try phone.requireID(),
            phoneType: phone.phoneType,
            number: phone.number,
            primaryCommunicationMethod: phone.primary,
            authed: phone.authed,
            authComms: phone.authed_communication,
            authMarketing: phone.authed_marketing)
    }
}

extension PhoneNumber {
    /// Update the phone number with `PhoneNumber_DTO.V1.UpdateRequest`
    func updateModel(_ request: PhoneNumber_DTO.V1.UpdateRequest) {
        if let phoneType = request.phoneType {
            self.phoneType = phoneType
        }
        if let number = request.number {
            self.number = number
        }
        
        if let primaryCommunication = request.primaryCommunicationMethod {
            self.primary = primaryCommunication
        }
        if let authed = request.authed {
            self.authed = authed
        }
        if let authComms = request.authComms {
            self.authed_communication = authComms
        }
        if let authMarketing = request.authMarketing {
            self.authed_marketing = authMarketing
        }
    }
}

