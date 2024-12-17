import Foundation
import Vapor
import Fluent



// MARK: - ReferenceMonetaryFieldsProtocol

/// These are the fields that are required for keeping track of exchange rate and tax information at the time of this protocol usage.
/// If the default `Currency` or `Tax` models change, these fields will let us see the historical data.
protocol ReferenceMonetaryFieldsProtocol: Model {
    
    
    // MARK: Currency
    
    /// `Currency.id` as a string
    var reference_currencyID: Currency.IDValue { get set }
    
    /// `Currency.name` from `currencyID`
    var reference_currencyName: String { get set }
    
    /// `Currency.code` from `currencyID`
    var reference_currencyCode: String { get set }
    
    /// `Currency.currencyRate` from `currencyID`
    var reference_currencyRate: Decimal { get set }
    
    
    
    
    // MARK: Optional reference to a default currency
    // If the default currency for the system has an exchange rate other than 1.000, keep track of the currency that has an exchange rate of 1.00 so we can compare to it.
    
    /// `Currency.id`
    var reference_defaultCurrencyID: Currency.IDValue? { get set }
    
    /// `Currency.name` from `reference_defaultCurrencyID`
    var reference_defaultCurrencyName: String? { get set }
    
    /// `Currency.code` from `reference_defaultCurrencyID`
    var reference_defaultCurrencyCode: String? { get set }
    
    /// `Currency.currencyRate` from `reference_defaultCurrencyID`
    var reference_defaultCurrencyRate: Decimal? { get set }
    
    
    
    
    // MARK: Tax
    
    /// `Tax.id` as a string
    var reference_taxID: Tax.IDValue { get set }
    
    /// `Tax.taxCode` from the original tax type
    var reference_taxCode: String { get set }
    
    /// `Tax.taxRate`
    var reference_taxRate: Decimal { get set }
    
    
    // MARK: Tax Currency Information
    // This is the currency information for this tax at this time, if it ever changes in the future
    
    /// `Tax.currencyID.name`
    var reference_taxCurrencyName: String { get set }
    
    /// `Tax.currencyID.code`
    var reference_taxCurrencyCode: String { get set }
    
    /// `Tax.currencyID.currencyRate`
    var reference_taxCurrencyRate: Decimal { get set }
    
    /// The initializer for this protocol
    init(on database: Database) async throws
}



// MARK: - ReferenceMonetaryFieldsProtocol Implementation Example


/// This model is to exemplify the `ReferenceMonetaryFieldsProtocol` use
fileprivate final class TestReferenceMonetaryFieldsModel: ReferenceMonetaryFieldsProtocol, @unchecked Sendable {
    static let schema: String = "test_reference_monetary_fields"
    
    @ID var id: UUID?
    
    
    
    // MARK: Default Currency
    
    @Field(key: "reference_currencyIDKey") var reference_currencyID: Currency.IDValue
    
    @Field(key: "reference_currencyNameKey") var reference_currencyName: String
    
    @Field(key: "reference_currencyCodeKey") var reference_currencyCode: String
    
    @Field(key: "reference_currencyRateKey") var reference_currencyRate: Decimal
    
    
    
    // MARK: Optional Default Exchange Rate currency
    
    @Field(key: "reference_defaultCurrencyIDKey") var reference_defaultCurrencyID: Currency.IDValue?
    
    @Field(key: "reference_defaultCurrencyNameKey") var reference_defaultCurrencyName: String?
    
    @Field(key: "reference_defaultCurrencyCodeKey") var reference_defaultCurrencyCode: String?
    
    @Field(key: "reference_defaultCurrencyRateKey") var reference_defaultCurrencyRate: Decimal?
    
    
    
    // MARK: Tax
    
    @Field(key: "reference_taxIDKey") var reference_taxID: Tax.IDValue
    
    @Field(key: "reference_taxCodeKey") var reference_taxCode: String
    
    @Field(key: "reference_taxRateKey") var reference_taxRate: Decimal
    
    @Field(key: "reference_taxCurrencyNameKey") var reference_taxCurrencyName: String
    
    @Field(key: "reference_taxCurrencyCodeKey") var reference_taxCurrencyCode: String
    
    @Field(key: "reference_taxCurrencyRateKey") var reference_taxCurrencyRate: Decimal
    
    init() {}
    
    /// How to implement the initialization process for the `ReferenceMonetaryFieldsProtocol`
    convenience init(db: Database) async throws {
        try await self.init(on: db)
    }
}


// MARK: - Default Implementation

extension ReferenceMonetaryFieldsProtocol {
    /// Initialize the `ReferenceMonetaryFieldsProtocol` fields
    init(on database: Database) async throws {
        self.init()
        
        // Find the default currency with taxes
        guard let defaultCurrency = try await Currency
            .query(on: database)
            .filter(\.$isDefault == true)
            .with(\.$taxes)
            .first()
        else {
            throw Abort(.internalServerError, reason: "ReferenceMonetaryFieldsProtocol: Default currency not found")
        }
        self.reference_currencyID = try defaultCurrency.requireID()
        self.reference_currencyName = defaultCurrency.name
        self.reference_currencyCode = defaultCurrency.code.rawValue
        self.reference_currencyRate = defaultCurrency.exchangeRate
        
        // Find the default tax for the default currency
        guard let defaultTax = defaultCurrency.taxes.first(where: { $0.defaultTax }) else {
            throw Abort(.internalServerError, reason: "ReferenceMonetaryFieldsProtocol: Default tax not found")
        }
        self.reference_taxID = try defaultTax.requireID()
        self.reference_taxCode = defaultTax.taxCode
        self.reference_taxRate = defaultTax.taxRate
        self.reference_taxCurrencyName = defaultCurrency.name
        self.reference_taxCurrencyCode = defaultCurrency.code.rawValue
        self.reference_taxCurrencyRate = defaultCurrency.exchangeRate
        
        // Make sure our default currency has an exchange rate of 1.0000. Otherwise go find the currency that has an exchange rate of 1.000
        if defaultCurrency.exchangeRate != 1.0000 {
            guard let defaultExchangeRateCurrency = try await Currency
                .query(on: database)
                .filter(\.$exchangeRate == 1.0000)
                .first()
            else {
                throw Abort(.internalServerError, reason: "ReferenceMonetaryFieldsProtocol: Default exchange rate currency not found")
            }
            self.reference_defaultCurrencyID = try defaultExchangeRateCurrency.requireID()
            self.reference_defaultCurrencyName = defaultExchangeRateCurrency.name
            self.reference_defaultCurrencyCode = defaultExchangeRateCurrency.code.rawValue
            self.reference_defaultCurrencyRate = defaultExchangeRateCurrency.exchangeRate
        }
    }
    
}
