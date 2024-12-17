import Foundation
import Vapor
import Fluent

import MWServerModels

// MARK: - Model Definition

/// Rate of taxation
final class Tax: Model, Content, ModelDateTrackingProtocol {
    static let schema = Tax.V1.schemaName
    
    @ID(key: .id) var id: UUID?
    
    // MARK: DateTracking Protocol
    @Timestamp(key: Tax.V1.createdAt, on: .create)      var createdAt:  Date?
    @Timestamp(key: Tax.V1.updatedAt, on: .update)      var updatedAt:  Date?
    @Timestamp(key: Tax.V1.deletedAt, on: .delete)      var deletedAt: Date?
    
    // MARK: Model
    /// The `Currency` this `Tax` is linked to
    @Parent(key: Tax.V1.currencyID)                     var currency: Currency
    
    /// Tax Code
    /// `US-TX`
    @Field(key: Tax.V1.taxCode)                         var taxCode: String
    
    /// The rate of taxation
    /// `0.0825`
    @Field(key: Tax.V1.taxRate)                         var taxRate: Decimal
    
    /// Make this the default tax for documents
    @Field(key: Tax.V1.defaultTax)                      var defaultTax: Bool
    
    /// Is this tax removable?
    @Field(key: Tax.V1.removable)                       var removable: Bool
    
    init() {}
    
    /// Default init
    init(
        id:         UUID? = nil,
        currency: Currency,
        defaultTax: Bool = false,
        taxCode:    String,
        taxRate:    Decimal,
        removable:  Bool
    ) throws {
        self.id = id
        self.$currency.id = try currency.requireID()
        self.defaultTax = defaultTax
        self.taxCode = taxCode
        self.taxRate = taxRate
        self.removable = removable
    }
    
    /// Init from SharedModel
    init(from shared: Tax_DTO.V1.CreateRequestModel) {
        self.defaultTax = shared.defaultTax
        self.$currency.id = shared.currencyID
        self.taxCode = shared.taxCode
        self.taxRate = shared.taxRate
        self.removable = true
    }
}


// MARK: - SharedModels Initializers

extension Tax_DTO.V1.Model: Content {}
extension Tax_DTO.V1.Model {
    /// Convert backend tax to DTO
    init(from tax: Tax) throws {
        guard tax.$currency.value != nil else {
            throw ModelDomainError<Tax>.notLoaded(field: "tax.$currency.value")
        }
        self.init(
            id: try tax.requireID(),
            createdAt: tax.createdAt ?? Date().failedOptional(),
            updatedAt: tax.updatedAt ?? Date().failedOptional(),
            currency: try .init(from: tax.currency),
            taxCode: tax.taxCode,
            taxRate: tax.taxRate,
            defaultTax: tax.defaultTax,
            removable: tax.removable)
    }
}


// MARK: - Error

extension Tax {
    enum Error: AppError {
        /// Couldn't find a default tax in the system
        case defaultTaxNotFound
        
        /// The provided taxID is invalid
        case invalidTaxID
        
        var status: HTTPResponseStatus {
            switch self {
            case .defaultTaxNotFound:
                return .internalServerError
            case .invalidTaxID:
                return .badRequest
            }
        }
        
        var reason: String {
            switch self {
            case .defaultTaxNotFound:
                return "Default tax not found"
            case .invalidTaxID:
                return "Invalid Tax ID"
            }
        }
        
        var identifier: String {
            switch self {
            case .defaultTaxNotFound:
                return "TE-001"
            case .invalidTaxID:
                return "TE-002"
            }
        }
    }
}
