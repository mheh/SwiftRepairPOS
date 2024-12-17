import Fluent
import Vapor
import MWServerModels

fileprivate typealias DTO = Customer_DTO
// MARK: - Model Definition

/// Customer contact information in system
final class Customer: Model, ModelDateTrackingProtocol, LoggableEntityProtocol {
    static let schema = Customer.V1.schemaName
    
    
    
    
    
    // MARK: Identification
    
    /// The numeric `ID` of the system's `Customer`
    @ID(custom: Customer.V1.id)                                         var id: Int?
    
    /// Return a string identifier of this customer's `ID` field
    func idString() throws -> String { return try "C-\(self.requireID())" }
    
    
    
    
    
    
    // MARK: DateTracking Protocol
    @Timestamp(key:         Customer.V1.createdAt, on: .create)         var createdAt: Date?
    @Timestamp(key:         Customer.V1.updatedAt, on: .update)         var updatedAt: Date?
    @Timestamp(key:         Customer.V1.deletedAt, on: .delete)         var deletedAt: Date?
    
    
    
    
    
    
    // MARK: Model
    
    /// Customer first name
    @Field(key:             Customer.V1.firstName)                      var firstName: String
    
    /// Customer last name
    @Field(key:             Customer.V1.lastName)                       var lastName: String
    
    /// Optional business relation to group businesses employees together
    @OptionalParent(key:    Customer.V1.business)                       var business: BusinessCustomer?
    
    /// Customer website
    @Field(key:             Customer.V1.homepage)                       var homepage: String
    
    /// Optional default tax to use with this customer
    @OptionalParent(key:    Customer.V1.customerDefaultTax)             var defaultTax: Tax?
    
    
    
    
    
    
    // MARK: Lightspeed Import ID
    /// Optional Lightspeed Customer ID associated with this customer model.
    @OptionalField(key: Customer.V1.lightspeedImportID)                 var importedLightspeedID: Int?
    
    
    
    
    
    
    // MARK: Contact Pivot models
    /// Phone numbers associated with this customer model
    @Siblings(through: CustomerPhonePivot.self,
              from: \CustomerPhonePivot.$customerID,
              to: \CustomerPhonePivot.$contactPhoneNumberID)            var phoneNumbers: [PhoneNumber]
    
    
    /// Email addresses associated with this customer model
    @Siblings(through: CustomerEmailAddressPivot.self ,
              from: \CustomerEmailAddressPivot.$customerID,
              to: \CustomerEmailAddressPivot.$emailAddressID)           var emailAddresses: [EmailAddress]
    
    
    /// Street addresses associated with this customer model
    @Siblings(through: CustomerStreetAddressPivot.self,
              from: \CustomerStreetAddressPivot.$customerID,
              to: \CustomerStreetAddressPivot.$streetAddressID)         var streetAddresses: [StreetAddress]
    
    
    
    
    
    
    // MARK: Payment Records
    
    /// The payment records associated with this customer
    //@Children(for: \PaymentRecord.$customerID)                          var paymentRecords: [PaymentRecord]
    
    /// Optional Stripe Customer ID associated with this customer model.
    //@OptionalParent(key: Customer.V03_07_2024.stripeCustomerID)         var stripeCustomerID: Stripe_CustomerLink?
    
    
    
    
    
    
    // MARK: LoggableEntityProtocol
    /// Direct pivot access for `var log: [EntityLog]`
    @Children(for: \CustomerLog.$modelID)                               var pivot: [CustomerLog]
    
    /// Log files associated with this customer model
    @Siblings(through:   CustomerLog.self,
              from:     \CustomerLog.$modelID,
              to:       \CustomerLog.$entityLogID)                      var log: [EntityLog]
    
    
    
    
    
    
    // MARK: Initializers
    
    init() { }
    
    
    /// Default initializer
    init(
        firstName: String,
        lastName: String,
        business: BusinessCustomer? = nil,
        homepage: String,
        defaultTax: Tax? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        if let business = business {
            do {
                self.$business.id = try business.requireID()
            } catch {
                self.$business.id = nil
            }
        }
        self.homepage = homepage
        if let defaultTax = defaultTax {
            do {
                self.$defaultTax.id = try defaultTax.requireID()
            } catch {
                self.$defaultTax.id = nil
            }
        }
    }
    
    /// Init from `Customer_DTO.V2.CreateRequestModel`
    init(from dto: Customer_DTO.V2.CreateRequestModel) {
        self.firstName = dto.firstName
        self.lastName = dto.lastName
        
        self.homepage = dto.homepage
        if let tax = dto.defaultTax {
            self.$defaultTax.id = tax.id
        }
    }
}






// MARK: - Model Methods

extension Customer {
    /// Get the primary `StreetAddress` from this model
    func getPrimaryStreetAddress() throws -> StreetAddress? {
        guard self.$streetAddresses.value != nil else {
            throw CustomerError.eagerLoading(field: "streetAddress")
        }
        return self.streetAddresses.first(where: { $0.primary })
    }
    
    /// Get the primary `PhoneNumber` from this model
    func getPrimaryPhoneNumber() throws -> PhoneNumber? {
        guard self.$phoneNumbers.value != nil else {
            throw CustomerError.eagerLoading(field: "phoneNumbers")
        }
        return self.phoneNumbers.first(where: { $0.primary })
    }
    
    /// Get the primary `EmailAddress` from this model
    func getPrimaryEmailAddress() throws -> EmailAddress? {
        guard self.$emailAddresses.value != nil else {
            throw CustomerError.eagerLoading(field: "emailAddresses")
        }
        return self.emailAddresses.first(where: { $0.primaryCommunicationMethod })
    }
}






// MARK: - DTO Initializers
// V2
extension DTO.V2.Model: Content {}
extension DTO.V2.CreateRequestModel: Content {}
extension DTO.V2.UpdateRequestModel: Content {}

extension DTO.V2.Model {
    /// Transfer model to client
    init(from customer: Customer) throws {
        var phones: [PhoneNumber] = []
        if let loadedPhones = customer.$phoneNumbers.value {
            phones = loadedPhones
        }
        
        var emails: [EmailAddress] = []
        if let loadedEmails = customer.$emailAddresses.value {
            emails = loadedEmails
        }
        
        var addresses: [StreetAddress] = []
        if let loadedAddresses = customer.$streetAddresses.value {
            addresses = loadedAddresses
        }
        
        // I don't  like this one
        var tax: Tax? = nil
        if let loadedTax = customer.$defaultTax.value {
            tax = loadedTax
        }
        
        self.init(
            id: try customer.requireID(),
            createdAt: customer.createdAt,
            updatedAt: customer.deletedAt,
            firstName: customer.firstName,
            lastName: customer.lastName,
            businessCustomer: "",
            homepage: customer.homepage,
            phoneNumbers: try phones.map { try .init(from: $0) },
            emailAddresses: try emails.map { try .init(from: $0) },
            streetAddresses: try addresses.map { try .init(from: $0) },
            defaultTax: tax != nil ? try .init(from: tax!) : nil // I don't like this force unwrap
        )
    }
}


// MARK: - Model Methods
extension Customer {
    /// Sets `firstName` `lastName` `homepage` and `defaultTax`
    func updateModel(rData: Customer_DTO.V2.UpdateRequestModel) {
        if let firstName = rData.firstName {
            self.firstName = firstName
        }
        if let lastName = rData.lastName {
            self.lastName = lastName
        }
        if let homepage = rData.homepage {
            self.homepage = homepage
        }
        
        if let tax = rData.defaultTax {
            self.$defaultTax.id = tax.id
        }
        if rData.removeDefaultTax != nil {
            self.$defaultTax.id = nil
        }
    }
}
