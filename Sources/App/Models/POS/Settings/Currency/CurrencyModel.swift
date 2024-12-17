import Foundation
import Vapor
import Fluent

import MWServerModels


// MARK: - Model Definition

/// `ISO4217 Currency Information` with user defined `Exchange Rate`
/// This model saves a `CurrencyAlphabeticCode` string in the database and an exchange rate.
/// The user can update the exchange rate as needed. The currency conversion is scoped to a `Payable Document`.
/// This means the document saves it's own exchange rate on itself. If the `Currency` exchange rate changes in the future, the document isn't affected.
final class Currency: Model, ModelDateTrackingProtocol {
    static let schema = Currency.V1.schemaName
    
    @ID                                                     var id: UUID?
    
    // MARK: DateTracking Protocol
    @Timestamp(key: Currency.V1.createdAt, on: .create)     var createdAt: Date?
    @Timestamp(key: Currency.V1.updatedAt, on: .update)     var updatedAt: Date?
    @Timestamp(key: Currency.V1.deletedAt, on: .delete)     var deletedAt: Date?
    
    
    // MARK: Model
    
    /// User defined name for this currency
    @Field(key:     Currency.V1.name)                       var name: String
    
    /// Three digit currency code (USD, CAN, EUR)
    @Field(key:     Currency.V1.code)                       var code: Currency_DTO.V1.CurrencyCodes
    
    /// Exchange rate in comparison to the default currency
    /// This is stored on a `Payable Document` at the document creation time, or from an existing document we're transitioning from.
    @Field(key:     Currency.V1.exchangeRate)               var exchangeRate: Decimal
    
    /// There can only be one.
    @Field(key:     Currency.V1.isDefault)                  var isDefault: Bool
    
    /// `Tax` models associated with this currency
    @Children(for: \Tax.$currency)                          var taxes: [Tax]
    
    
    // MARK: Vars
    
    /// Formatter for currency
    var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = self.code.rawValue
        return formatter
    }
    
    
    
    // MARK: Initializers
    
    init() {}
    
    /// Default initializer
    init (
        id: UUID? = nil,
        name: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        exchangeRate: Decimal,
        code: Currency_DTO.V1.CurrencyCodes,
        isDefault: Bool
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.exchangeRate = exchangeRate
        self.code = code
        self.isDefault = isDefault
    }
    
    /// Init from SharedModel
    init(from shared: Currency_DTO.V1.CreateRequestModel) {
        self.name = shared.name
        self.code = shared.code
        self.exchangeRate = shared.exchangeRate
        self.isDefault = shared.isDefault
    }
    
    
    
    // MARK: Model Methods
    
    /// Find the default `Currency` and `Tax` model
    static func findDefault(on db: Database) async throws -> (Currency, Tax) {
        guard let currency = try await Currency.query(on: db)
            .filter(\.$isDefault == true)
            .with(\.$taxes)
            .first()
        else {
            throw Currency.Error.defaultCurrencyNotFound
        }
        
        guard let tax = currency.taxes.first(where: { $0.defaultTax == true }) else {
            throw Tax.Error.defaultTaxNotFound
        }
        
        return (currency, tax)
    }
    
    /// Determine if the provided `ID` values are a vallid combination
    static func isValid(currencyID: UUID, taxID: UUID, on db: Database) async throws -> (Currency, Tax) {
        guard let currency = try await Currency
            .find(currencyID, on: db)
        else {
            throw Currency.Error.invalidCurrencyID
        }
        let taxes = try await currency.$taxes.get(on: db)
        guard let tax = taxes.first(where: { $0.id! == taxID}) else {
            throw Tax.Error.invalidTaxID
        }
        
        return (currency, tax)
    }
}


// MARK: - Shared Models Initializers

extension Currency_DTO.V1.Model: Content {}
extension Currency_DTO.V1.Model {
    init(from currency: Currency) throws {
        self.init(
            id: try currency.requireID(),
            name: currency.name,
            createdAt: currency.createdAt ?? Date().failedOptional(),
            updatedAt: currency.updatedAt ?? Date().failedOptional(),
            deletedAt: currency.deletedAt,
            exchangeRate: currency.exchangeRate,
            code: currency.code,
            isDefault: currency.isDefault
        )
    }
}

extension Currency {
    /// Update model from request data
    func updateModel(rData: Currency_DTO.V1.UpdateRequestModel) {
        self.name = rData.name ?? self.name
        self.code = rData.code ?? self.code
        self.exchangeRate = rData.exchangeRate ?? self.exchangeRate
        self.isDefault = rData.isDefault ?? self.isDefault
    }
}


// MARK: - Errors
extension Currency {
    enum Error: AppError {
        /// Couldn't find a default currency in the system
        case defaultCurrencyNotFound
        
        /// The provided currency ID is invalid
        case invalidCurrencyID
        
        var status: HTTPResponseStatus {
            switch self {
            case .defaultCurrencyNotFound:
                return .internalServerError
            case .invalidCurrencyID:
                return .badRequest
            }
        }
        
        var reason: String {
            switch self {
            case .defaultCurrencyNotFound:
                return "Default currency not found"
            case .invalidCurrencyID:
                return "Invalid currency ID"
            }
        }
        
        var identifier: String {
            switch self {
            case .defaultCurrencyNotFound:
                return "CE-001"
            case .invalidCurrencyID:
                return "CE-002"
            }
        }
    }
}
