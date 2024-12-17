import Fluent
import Vapor

import MWServerModels

// MARK: - Model Definition

/// An email address for communication
final class EmailAddress: Model, Content, AuthCommunicationProtocol, @unchecked Sendable {
    static let schema = EmailAddress.V1.schemaName
    
    @ID var id: UUID?
    
    @Field(key: EmailAddress.V1.primary)            var primaryCommunicationMethod: Bool
    /// The email address being stored
    @Field(key: EmailAddress.V1.emailAddress)       var emailAddress: String
    /// Whether this person has authorized this email with us
    @Field(key: EmailAddress.V1.authorized)         var authed: Bool
    /// Whether this person has authorized communication about stuff pertaining to them
    @Field(key: EmailAddress.V1.authComms)          var authComms: Bool
    /// Whether this person has authroizeid receiving marketing deals
    @Field(key: EmailAddress.V1.authMarketing)      var authMarketing: Bool
    
    
    // MARK: Initializers
    init () {}
    
    /// Creates a new email address that's not authorized
    init(primary: Bool = true, emailAddress: String) {
        self.primaryCommunicationMethod = primary
        self.emailAddress = emailAddress
        self.authed = false
        self.authComms = false
        self.authMarketing = false
    }
    
    /// Init from a CreateRequest
    /// Not primary communicatiion, not authed for anything.
    init(from mwemail: EmailAddress_DTO.V1.CreateRequest) {
        self.emailAddress = mwemail.emailAddress
        self.primaryCommunicationMethod = false
        self.authed = false
        self.authComms = false
        self.authMarketing = false
    }
    
    
    // MARK: Model Methods
    
    /// Provide a comma-delimited string of email addresses to generate multiple `EmailAddress` models
    /// Expected input: `someone@me.org, noone@else.com, something@nothing.edu`
    static func createEmails(_ string: String) -> [EmailAddress] {
        var emails: [EmailAddress] = []
        let stringArray = string.components(separatedBy: ",")
        for (index, email) in stringArray.enumerated() {
            emails.append(.init(
                primary: index > 0 ? false : true, // only the first is primary
                emailAddress: email
            ))
        }
        debugPrint("EmailAddress.createEmails(): importing emails: \(stringArray)")
        return emails
    }
}

extension EmailAddress {
    enum V1 {
        // MARK: FieldKeys
        static let schemaName = "contact_email_address"
        
        static let primary = FieldKey(stringLiteral: "primary")
        static let emailAddress = FieldKey(stringLiteral: "email_address")
        static let authorized = FieldKey(stringLiteral: "email_authorized")
        static let authComms = FieldKey(stringLiteral: "email_authorized_communication")
        static let authMarketing = FieldKey(stringLiteral: "email_authroized_marketing")
        
        // MARK: Migration
        
        struct CreateEmailAddressDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(EmailAddress.V1.schemaName)
                    .id()
                
                    .field(EmailAddress.V1.primary,             .bool,          .required)
                    .field(EmailAddress.V1.emailAddress,        .string,        .required)
                    .field(EmailAddress.V1.authorized,          .bool,          .required)
                    .field(EmailAddress.V1.authComms,           .bool,          .required)
                    .field(EmailAddress.V1.authMarketing,       .bool,          .required)
                
                    .create()
            }
            func revert(on database: Database) async throws {
                try await database.schema(EmailAddress.V1.schemaName)
                    .delete()
            }
        }
    }
}

// MARK: - MWModels Initializer Extension
extension EmailAddress_DTO.V1.Model {
    /// Transfer model to client
    init(from email: EmailAddress) throws {
        self.init(
            id: try email.requireID(),
            primaryCommunicationMethod: email.primaryCommunicationMethod,
            emailAddress: email.emailAddress,
            authed: email.authed,
            authComms: email.authComms,
            authMarketing: email.authMarketing)
    }
}

extension EmailAddress {
    /// Update the model from a `EmailAddress_DTO.V1.UpdateRequest`
    func updateModel(_ request: EmailAddress_DTO.V1.UpdateRequest) {
        if let emailAddress = request.emailAddress {
            self.emailAddress = emailAddress
        }
        if let primaryCommunication = request.primary {
            self.primaryCommunicationMethod = primaryCommunication
        }
        if let authed = request.authed {
            self.authed = authed
        }
        if let authComms = request.authed_communication {
            self.authComms = authComms
        }
        if let authMarketing = request.authed_marketing {
            self.authMarketing = authMarketing
        }
    }
}
