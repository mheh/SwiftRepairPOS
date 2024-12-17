import Fluent
import Vapor
import MWServerModels


/// Street address model for pivots to contacts
final class StreetAddress: Model, Content, ContactCommunicationProtocol, @unchecked Sendable {
    static let schema = StreetAddress.V1.schemaName
    
    typealias DTO = StreetAddress_DTO.V1
    
    @ID var id: UUID?
    
    /// Whether this address is the primary
    @Field(key: StreetAddress.V1.primary)                       var primary: Bool
    /// Billing or shipping address
    @Field(key: StreetAddress.V1.addressType)                   var addressType: DTO.StreetAddressType
    
    /// The first line of the address
    @Field(key: StreetAddress.V1.address1)                      var address1: String
    /// The second line of the address
    @Field(key: StreetAddress.V1.address2)                      var address2: String
    /// The city
    @Field(key: StreetAddress.V1.city)                          var city: String
    /// The state
    @Field(key: StreetAddress.V1.state)                         var state: String
    /// The zip code
    @Field(key: StreetAddress.V1.zip)                           var zip: String
    /// The country code
    @Field(key: StreetAddress.V1.country)                       var country: DTO.CountryCodes_Alpha2
    
    /// Whether this address has been authorized by the customer
    @Field(key: StreetAddress.V1.authorized)                    var authed: Bool
    /// Whether this address has been authorized for communication
    @Field(key: StreetAddress.V1.authorizedCommunication)       var authed_communication: Bool
    /// Whether this address has been authorized for marketing
    @Field(key: StreetAddress.V1.authorizedMarketing)           var authed_marketing: Bool
    
    init() {}
    
    /// Create a new street address entry that's not authorized
    init(
        primary: Bool = false,
        addressType: DTO.StreetAddressType,
        address1: String, address2: String,
        city: String, state: String, zip: String, country: DTO.CountryCodes_Alpha2
    ) {
        self.primary = primary
        self.addressType = addressType
        
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        
        self.authed = false
        self.authed_communication = false
        self.authed_marketing = false
    }
    
    /// Init from StreetAddress_DTO
    init(from address: StreetAddress_DTO.V1.CreateRequest) {
        self.primary = address.primary
        self.addressType = address.addressType
        
        self.address1 = address.address1
        self.address2 = address.address2
        self.city = address.city
        self.state = address.state
        self.zip = address.zip
        self.country = address.country
        
        self.authed = address.authed
        self.authed_communication = address.authed_communication
        self.authed_marketing = address.authed_marketing
    }
}


// MARK: - Migrations
extension StreetAddress {
    enum V1 {
        // MARK: FieldKeys
        static let schemaName = "contact_street_address"
        
        static let primary =                    FieldKey(stringLiteral: "primary")
        static let addressType =                FieldKey(stringLiteral: "address_type")
        
        static let address1 =                   FieldKey(stringLiteral: "address_1")
        static let address2 =                   FieldKey(stringLiteral: "address_2")
        static let city =                       FieldKey(stringLiteral: "city")
        static let state =                      FieldKey(stringLiteral: "state")
        static let zip =                        FieldKey(stringLiteral: "zip")
        static let country =                    FieldKey(stringLiteral: "country")
        
        
        static let authorized =                 FieldKey(stringLiteral: "email_authorized")
        static let authorizedCommunication =    FieldKey(stringLiteral: "email_authorized_communication")
        static let authorizedMarketing =        FieldKey(stringLiteral: "email_authroized_marketing")
        
        // MARK: Migration
        struct CreateStreetAddressDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(StreetAddress.V1.schemaName)
                    .id()
                    
                    .field(StreetAddress.V1.primary,                    .bool,          .required)
                    .field(StreetAddress.V1.addressType,                .string,        .required)
                
                    .field(StreetAddress.V1.address1,                   .string,        .required)
                    .field(StreetAddress.V1.address2,                   .string,        .required)
                    .field(StreetAddress.V1.city,                       .string,        .required)
                    .field(StreetAddress.V1.state,                      .string,        .required)
                    .field(StreetAddress.V1.zip,                        .string,        .required)
                    .field(StreetAddress.V1.country,                    .string,        .required)
                
                    .field(StreetAddress.V1.authorized,                 .bool,          .required)
                    .field(StreetAddress.V1.authorizedCommunication,    .bool,          .required)
                    .field(StreetAddress.V1.authorizedMarketing,        .bool,          .required)
                
                    .create()
            }
            func revert(on database: Database) async throws {
                try await database.schema(StreetAddress.V1.schemaName)
                    .delete()
            }
        }
    }
}

// MARK: - MWModels Intializer Extension
extension StreetAddress_DTO.V1.Model {
    /// Transfer model to client
    init(from address: StreetAddress) throws {
        self.init(
            id: try address.requireID(),
            addressType: address.addressType,
            address1: address.address1,
            address2: address.address2,
            city: address.city,
            state: address.state,
            zip: address.zip,
            country: address.country,
            
            primary: address.primary,
            authed: address.authed,
            authed_communication: address.authed_communication,
            authed_marketing: address.authed_marketing
        )
    }
}

extension StreetAddress {
    /// Update this model from a `StreetAddress_DTO.V1.UpdateRequest` model
    func updateModel(_ request: StreetAddress_DTO.V1.UpdateRequest) {
        if let primary = request.primary {
            self.primary = primary
        }
        if let addressType = request.addressType {
            self.addressType = addressType
        }
        
        if let address1 = request.address1 {
            self.address1 = address1
        }
        if let address2 = request.address2 {
            self.address2 = address2
        }
        if let city = request.city {
            self.city = city
        }
        if let state = request.state {
            self.state = state
        }
        if let zip = request.zip {
            self.zip = zip
        }
        if let country = request.country {
            self.country = country
        }
        
        if let authed = request.authed {
            self.authed = authed
        }
        if let authComms = request.authed_communication {
            self.authed_communication = authComms
        }
        if let authMarketing = request.authed_marketing {
            self.authed_marketing = authMarketing
        }
    }
}

