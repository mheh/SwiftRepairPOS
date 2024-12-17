import Fluent
import Vapor
import MWServerModels

fileprivate typealias DTO = BusinessCustomer_DTO
// MARK: - Model Definition

/// Business model for customer grouping in system
final class BusinessCustomer: Model, Content, ModelDateTrackingProtocol {
    static let schema = BusinessCustomer.V1.schemaName
    
    @ID(key: .id)                                                               var id: UUID?
    
    // MARK: DateTracking Protocol
    @Timestamp(key:         BusinessCustomer.V1.createdAt, on: .create)         var createdAt: Date?
    @Timestamp(key:         BusinessCustomer.V1.updatedAt, on: .update)         var updatedAt: Date?
    @Timestamp(key:         BusinessCustomer.V1.deletedAt, on: .delete)         var deletedAt: Date?
    
    // MARK: Model
    /// The name of this business
    @Field(key:             BusinessCustomer.V1.businessName)                   var businessName: String
    /// Optional default tax to use with this business
    @OptionalParent(key:    BusinessCustomer.V1.businessDefaultTax)             var defaultTax: Tax?
    
    /// Customer models with this optional parent
    @Children(for: \.$business)                                                 var customers: [Customer]
    
    
    // MARK: Initializers
    
    /// Empty init for fluent
    init() {}
    
    
    /// Default init
    init(
        id: UUID? = nil,
        businessName: String,
        defaultTax: Tax.IDValue? = nil
    ) {
        self.id = id
        self.businessName = businessName
        self.$defaultTax.id = defaultTax
    }
    
    
    /// Init from `BusinessCustomer_DTO.V2.CreateRequest`
    init(from dto: BusinessCustomer_DTO.V2.CreateRequestModel) {
        self.businessName = dto.businessName
        if let tax = dto.defaultTax {
            self.$defaultTax.id = tax
        }
    }
    
    // MARK: Model Methods
    
    /// Find a `BusinessCustomer` through the provided name. If one isn't found, a new model is created.
    /// Try to pass a database `Transaction` to prevent failed requests generating excessive models
    static func findOrCreateNew(_ name: String, on transaction: Database) async throws -> BusinessCustomer {
        let found = try await self.query(on: transaction)
            .filter(\.$businessName, .custom("ILIKE"), name)
            .first()
        if let found {
            return found
        }
        // we didn't find one
        let newBusinessCustomer = BusinessCustomer(businessName: name)
        try await newBusinessCustomer.create(on: transaction)
        return newBusinessCustomer
    }
    
}

// MARK: - DTO Initializers
// V2
extension DTO.V2.CreateRequestModel: Content {}
extension DTO.V2.Model: Content {}

extension DTO.V2.Model {
    /// Transfer model to client
    init(from businessCustomer: BusinessCustomer) throws {
        self.init(
            id: try businessCustomer.requireID(),
            createdAt: businessCustomer.createdAt ?? Date().failedOptional(),
            updatedAt: businessCustomer.updatedAt ?? Date().failedOptional(),
            businessName: businessCustomer.businessName,
            defaultTax: try {
                if let tax = businessCustomer.defaultTax {
                    return try Tax_DTO.V1.Model(from: tax)
                } else {
                    return nil
                }
            }(),
            customers: try {
                if businessCustomer.$customers.value != nil {
                    return try businessCustomer.customers.map { try Customer_DTO.V2.Model(from: $0)}
                } else {
                    return []
                }
            }()
        )
    }
}

// MARK: - Model Methods
extension BusinessCustomer {
    /// Perform model specific updates from a PUT request
    func updateModel(rData: BusinessCustomer_DTO.V2.UpdateRequestModel) {
        self.businessName = rData.businessName
        if let tax = rData.defaultTax {
            self.$defaultTax.id = tax
        }
    }
}
