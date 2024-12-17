import Fluent

/// On `MonetaryDocumentProtocol` models, these fields keep track of customer information.
protocol DocumentCustomerFieldsProtocol: Model {
    
    /// Assign a customer to this document
    var customerID: Customer? { get set }
    
    // MARK: Name
    
    /// Optional business name
    var businessName: String? { get set }
    
    /// Customer.firstName
    var firstName: String { get set }
    
    /// Customer.lastName
    var lastName: String { get set }
    
    /// Customer full name
    var fullName: String { get set }
    
    
    // MARK: Contact Mediums
    
    /// Phone numbers associated with this document
    var phones: [PhoneNumber] { get set }
    
    /// Emails associated with this document
    var emails: [EmailAddress] { get set }
    
    /// Addresses associated with this document
    var addresses: [StreetAddress] { get set }
    
    
}
