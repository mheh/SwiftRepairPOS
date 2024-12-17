import Foundation
import Fluent
import MWServerModels

/// These are the requird fields for documents that track payment information
protocol MonetaryDocumentProtocol: ModelDateTrackingProtocol {
    
    
    // MARK: - Currencies
    
    /// The assigned `Currency` if we're using something other than the default
    var currencyID: Currency { get set }
    
    /// The assigned currency code pulled form the `defaultCurrency` or `currencyID`
    var currencyCode: Currency_DTO.V1.CurrencyCodes { get set }
    
    /// The rate of currency to apply for this document. Pull the default currency if there is no `currencyID` set.
    var currencyRate: Decimal { get set }
    
    
    
    // MARK: - Taxes
    
    /// The assigned `Tax` if we're using something other than the default
    var taxID: Tax { get set }
    
    /// The rate of taxation to apply for this document. Pull the default tax rate if there is no `taxID` set.
    var taxRate: Decimal { get set }
    
    /// The set tax code for this document
    var taxCode: String { get set }
    
    
    
    // MARK: - Totals
    
    var total_subTotal: Decimal { get set }
    
    var total_discountAmount: Decimal { get set }
    
    // !---------------------------------!
    
    var total_costTotal: Decimal { get set }
    
    var total_profitMarginTotal: Decimal { get set }
    
    // !---------------------------------!
    
    var total_taxAmount: Decimal { get set }
    
    var total: Decimal { get set }
    
    
    
    // MARK: Line Item relation
    
    /// The type of line items for this document. Must conform to `MonetaryLineItemFields`
    associatedtype LineItems: LineItemProtocol
    /// The line items relation
    var lineItems: [LineItems] { get set }
}

extension MonetaryDocumentProtocol {
    func calculateTotals() {
        // Calculate the subTotal
        total_subTotal = lineItems.reduce(0) { $0 + $1.total_subTotal }
        
        // Calculate the discount
        total_discountAmount = lineItems.reduce(0) { $0 + $1.total_discountAmount }
        
        // Calculate the cost
        total_costTotal = lineItems.reduce(0) { $0 + $1.total_costTotal }
        
        // Calculate the profit
        total_profitMarginTotal = lineItems.reduce(0) { $0 + $1.total_profitMarginTotal }
        
        // Calculate the tax
        total_taxAmount = lineItems.reduce(0) { $0 + $1.total_taxAmount }
        
        // Calculate the total
        total = lineItems.reduce(0) { $0 + $1.total }
    }
}
