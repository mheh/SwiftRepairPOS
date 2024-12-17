import Fluent
import Vapor

import MWServerModels

// MARK: - Model Definition

/// supplier contact information in system
final class Supplier: Model, Content, ModelDateTrackingProtocol, LoggableEntityProtocol, @unchecked Sendable {
    static let schema = Supplier.V1.schemaName
    
    /// The numeric `ID` of the system's `Supplier`
    @ID(custom: Supplier.V1.id)                                         var id: Int?
    /// Return a string identifier of this supplier's `ID` field.
    func idString() throws -> String { return try "S-\(self.requireID())"}
    
    
    // MARK: DateTracking Protocol
    @Timestamp(key:         Supplier.V1.createdAt, on: .create)         var createdAt: Date?
    @Timestamp(key:         Supplier.V1.updatedAt, on: .update)         var updatedAt: Date?
    @Timestamp(key:         Supplier.V1.deletedAt, on: .delete)         var deletedAt: Date?
    
    // MARK: Model
    /// The name of the supplier
    /// `Apple, Inc`
    @Field(key:             Supplier.V1.supplierName)                   var supplierName: String
    
    /// supplier first name
    /// `Craig`
    @Field(key:             Supplier.V1.firstName)                      var firstName: String
    
    /// supplier last name
    /// `Federicki`
    @Field(key:             Supplier.V1.lastName)                       var lastName: String
    
    /// supplier website
    /// `www.apple.com`
    @Field(key:             Supplier.V1.homepage)                       var homepage: String
    
    /// Optional default tax to use with this supplier
    @OptionalParent(key:    Supplier.V1.supplierDefaultTax)             var defaultTax: Tax?
    
    
    // MARK: Lightspeed Import ID
    /// If this supplier was imported, this is the ID from the lightspeed Supplier
    @OptionalField(key: Supplier.V1.lightspeedImportID)                 var lightspeedImportID: Int?
    
    
    // MARK: Contact Pivot model
    /// Phone numbers associated with this `Supplier` model
    @Siblings(through: SupplierPhonePivot.self,
              from: \SupplierPhonePivot.$supplierID,
              to: \SupplierPhonePivot.$contactPhoneNumberID)            var phoneNumbers: [PhoneNumber]
    
    
    /// Email addresses associated with this `Supplier` model
    @Siblings(through: SupplierEmailAddressPivot.self ,
              from: \SupplierEmailAddressPivot.$supplierID,
              to: \SupplierEmailAddressPivot.$emailAddressID)           var emailAddresses: [EmailAddress]
    
    
    /// Street addresses associated with this `Supplier` model
    @Siblings(through: SupplierStreetAddressPivot.self,
              from: \SupplierStreetAddressPivot.$supplierID,
              to: \SupplierStreetAddressPivot.$streetAddressID)         var streetAddresses: [StreetAddress]
    
    
    
    // MARK: LoggableEntityProtocol
    /// Direct pivot access for `var log: [EntityLog]`
    @Children(for: \SupplierLogPivot.$modelID)                          var pivot: [SupplierLogPivot]
    
    /// Log files associated with this `Supplier` model
    @Siblings(through:   SupplierLogPivot.self,
              from:     \SupplierLogPivot.$modelID,
              to:       \SupplierLogPivot.$entityLogID)                 var log: [EntityLog]
    
    init() { }
    
    
    /// Default initializer
    init(
        supplierName: String,
        firstName: String,
        lastName: String,
        homepage: String,
        defaultTax: Tax? = nil
    ) {
        self.supplierName = supplierName
        self.firstName = firstName
        self.lastName = lastName
        self.homepage = homepage
        if let defaultTax = defaultTax {
            do {
                self.$defaultTax.id = try defaultTax.requireID()
            } catch {
                self.$defaultTax.id = nil
            }
        }
    }
    
    /// Init from Supplier_DTO.Request
    init(from mwsupp: Supplier_DTO.V1.CreateRequestModel) {
        self.supplierName = mwsupp.supplierName
        self.firstName = mwsupp.firstName
        self.lastName = mwsupp.lastName
        self.homepage = mwsupp.homepage
        if let tax = mwsupp.defaultTax {
            self.$defaultTax.id = tax
        }
    }
}


// MARK: - MWServerModels Initializers
extension Supplier_DTO.V1.CreateRequestModel: Content {}
extension Supplier_DTO.V1.UpdateRequestModel: Content {}

extension Supplier_DTO.V1.Model: Content {}
extension Supplier_DTO.V1.Model {
    /// Transfer model to client
    init(from supp: Supplier) throws {
        var phones: [PhoneNumber] = []
        if let loadedPhones = supp.$phoneNumbers.value {
            phones = loadedPhones
        }
        
        var emails: [EmailAddress] = []
        if let loadedEmails = supp.$emailAddresses.value {
            emails = loadedEmails
        }
        
        var addresses: [StreetAddress] = []
        if let loadedAddresses = supp.$streetAddresses.value {
            addresses = loadedAddresses
        }
        
        self.init(
            id: try supp.requireID(),
            createdAt: supp.createdAt ?? Date().failedOptional(),
            updatedAt: supp.updatedAt ?? Date().failedOptional(),
            supplierName: supp.supplierName,
            firstName: supp.firstName,
            lastName: supp.lastName,
            homepage: supp.homepage,
            phoneNumbers: try phones.map { try .init(from: $0) },
            emailAddresses: try emails.map { try .init(from: $0) },
            streetAddresses: try addresses.map { try .init(from: $0) },
            defaultTax: try {
                if supp.$defaultTax.value != nil, let tax = supp.defaultTax {
                    return try Tax_DTO.V1.Model(from: tax)
                } else {
                    return nil
                }
            }(),
            lightspeedImportID: supp.lightspeedImportID
        )
    }
}

// MARK: - Model Methods
extension Supplier {
    /// Sets `firstName` `lastName` `businessCustomer` `homepage` and `defaultTax`
    func updateModel(rData: Supplier_DTO.V1.UpdateRequestModel) {
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
            self.$defaultTax.id = tax
        }
        if rData.removeDefaultTax != nil {
            self.$defaultTax.id = nil
        }
    }
}
