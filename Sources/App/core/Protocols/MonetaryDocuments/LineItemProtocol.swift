import Foundation
import Vapor
import Fluent



// MARK: - V4 Final (No tier)

/// These are the fields that are required for tracking monetary information for a `Product` on a line item.
/// The goal of this protocol is to be able to rebuild currency, tax, and product information at the time of line item creation **WITHOUT** available relations.
/// If any of these relations are removed we need to be able to represent this document's original state.
protocol LineItemProtocol: ReferenceMonetaryFieldsProtocol {
    
    // MARK: - Reference Product Information
    
    /// The `Product` model for this line item
    var productID: Product? { get set }
    
    /// `Product.code` at the time of line creation
    var reference_productCode: String { get set }
    
    /// `Product.productDescription` at the time of line item creation
    var reference_productDescription: String { get set }
    
    /// `Product.sellPrice` at the time of line creation
    var reference_productSellPrice: Decimal { get set }
    
    /// Either `Product.defaultCostID` or `Product.averageCost` amount, at the time of line creation
    var reference_productCostAmount: Decimal { get set }
    
    /// `Product.serialized` at the time of line creation
    var reference_productSerialized: Bool { get set }
    
    /// `Product.inventoried` at the time of line creation
    var reference_productInventoried: Bool { get set }
    
    
    
    // MARK: - Monetary Fields
    
    /// The quantity of this line item
    /// **USER EDITABLE**
    var quantity: Decimal { get set }
    
    // !---------------------------------!
    
    /// The sell price of the product on the line.
    /// **USER EDITABLE**
    var unit_sellPrice: Decimal { get set }
    
    /// The amount to discount from the `unit_sellPrice`
    /// **MANAGED**
    var unit_sellPrice_DiscountAmount: Decimal { get set }

    /// The difference of `unit_sellPrice` and `unit_sellPrice_Discounted`
    /// **MANAGED
    var unit_sellPrice_Total: Decimal { get set }
    
    // !---------------------------------!
    
    /// Whether the `line_discountAmount` is a percentage of or total amount to discount.
    /// **USER EDITABLE**
    var unit_discountIsPercentage: Bool { get set }
  
    /// The discount amount: `0.50 = 50%` or `12.50 = $12.50`
    /// **USER EDITABLE**
    var unit_discountAmount: Decimal { get set }
    
    // !---------------------------------!
    
    /// The tax amount per unit based on `unit_sellPrice_Total` and `reference_taxRate`
    /// **MANAGED**
    var unit_taxAmount: Decimal { get set }
    
    /// The profit margin based on `reference_productCost` and the `unit_sellPrice_Total`
    /// **MANAGED**
    var unit_profitMargin: Decimal { get set }
    
    
    
    
    // MARK: Totals
    
    /// `unit_sellPrice_Total * quantity`
    /// This field includes our discount amount but no tax amount
    /// **MANAGED**
    var total_subTotal: Decimal { get set }
    
    /// `unit_sellPrice_Discounted * quantity`
    /// **MANAGED**
    var total_discountAmount: Decimal { get set }
    
    // !---------------------------------!
    
    /// `reference_productCost * quantity`
    /// **MANAGED**
    var total_costTotal: Decimal { get set }
    
    /// `unit_profitMargin * quantity`
    /// **MANAGED**
    var total_profitMarginTotal: Decimal { get set }
    
    // !---------------------------------!
    
    /// `unit_taxAmount * quantity`
    /// **MANAGED**
    var total_taxAmount: Decimal { get set }
    
    /// `total_subTotal + total_taxAmount`
    /// **MANAGED**
    var total: Decimal { get set }
    
    /// The initializer for the `MonetaryLineItemFields` protocol
    init(from productID: Product.IDValue, on db: Database) async throws
}



// MARK: - LineItemProtocol Implementation Example

/// This model is used to exemplify the `LineItemProtocol`use
fileprivate final class TestLineItemModel: LineItemProtocol, @unchecked Sendable {
    
    static let schema = "test_line_item"
    
    @ID var id: UUID?
    
    
    // MARK: LineItemProtocol
    
    // Product
    @OptionalParent(key: "ref_product_id") var productID: Product?
    
    @Field(key: "ref_product_code") var reference_productCode: String
    @Field(key: "ref_product_description") var reference_productDescription: String
    
    @Field(key: "ref_product_sell_price") var reference_productSellPrice: Decimal
    @Field(key: "ref_product_cost_amount") var reference_productCostAmount: Decimal
    
    @Field(key: "ref_product_serialized") var reference_productSerialized: Bool
    @Field(key: "ref_product_inventoried") var reference_productInventoried: Bool
    
    // Monetary Fields
    @Field(key: "quantity") var quantity: Decimal
    
    @Field(key: "unit_sell_price") var unit_sellPrice: Decimal
    @Field(key: "unit_sell_price_discount_amount") var unit_sellPrice_DiscountAmount: Decimal
    @Field(key: "unit_sell_price_total") var unit_sellPrice_Total: Decimal
    
    @Field(key: "unit_discount_is_percentage") var unit_discountIsPercentage: Bool
    @Field(key: "unit_discount_amount") var unit_discountAmount: Decimal
    
    @Field(key: "unit_tax_amount") var unit_taxAmount: Decimal
    @Field(key: "unit_profit_margin") var unit_profitMargin: Decimal
    
    @Field(key: "total_subtotal") var total_subTotal: Decimal
    @Field(key: "total_discount_amount") var total_discountAmount: Decimal
    @Field(key: "total_cost") var total_costTotal: Decimal
    @Field(key: "total_profit_margin") var total_profitMarginTotal: Decimal
    @Field(key: "total_tax") var total_taxAmount: Decimal
    @Field(key: "total") var total: Decimal
    
    // MARK: ReferenceMonetaryFieldsProtocol
    @Field(key: "ref_currency_id") var reference_currencyID: Currency.IDValue
    @Field(key: "ref_currency_name") var reference_currencyName: String
    @Field(key: "ref_currency_code") var reference_currencyCode: String
    @Field(key: "ref_currency_rate") var reference_currencyRate: Decimal
    
    @Field(key: "ref_default_currency_id") var reference_defaultCurrencyID: Currency.IDValue?
    @Field(key: "ref_default_currency_name") var reference_defaultCurrencyName: String?
    @Field(key: "ref_default_currency_code") var reference_defaultCurrencyCode: String?
    @Field(key: "ref_default_currency_rate") var reference_defaultCurrencyRate: Decimal?
    
    @Field(key: "ref_tax_id") var reference_taxID: Tax.IDValue
    @Field(key: "ref_tax_code") var reference_taxCode: String
    @Field(key: "ref_tax_rate") var reference_taxRate: Decimal
    @Field(key: "ref_tax_currency_name") var reference_taxCurrencyName: String
    @Field(key: "ref_tax_currency_code") var reference_taxCurrencyCode: String
    @Field(key: "ref_tax_currency_rate") var reference_taxCurrencyRate: Decimal
    
    init() {}
    
    
    init(from productID: Product.IDValue, on db: FluentKit.Database) async throws {
        
    }
}



// MARK: - Default Implementation

extension LineItemProtocol {
    
    /// If a user edits `unit_sellPrice`  or `unit_discountAmount/unit_discountIsPercentage`, we need to calculate the `unit_sellPrice_Total` field again.
    /// Afterwards determine the totals
    func calculateLineTotal() {
        if self.unit_discountIsPercentage {
            // discount is a percentage so we perform maths
            self.unit_sellPrice_DiscountAmount =    self.unit_sellPrice         *       self.unit_discountAmount
            self.unit_sellPrice_Total =             self.unit_sellPrice         -       self.unit_sellPrice_DiscountAmount
        } else {
            // discount is not a percentage but a total
            self.unit_sellPrice_DiscountAmount =    self.unit_discountAmount
            self.unit_sellPrice_Total =             self.unit_sellPrice         -       self.unit_sellPrice_DiscountAmount
        }
        
        self.unit_taxAmount =                       self.reference_taxRate      *       self.unit_sellPrice_Total
        self.unit_profitMargin =                    self.unit_sellPrice_Total   -       self.reference_productCostAmount

        // Total calculations
        
        self.total_subTotal =                       self.unit_sellPrice_Total   *       self.quantity
        self.total_discountAmount =                 self.unit_sellPrice_DiscountAmount * self.quantity
        
        self.total_costTotal =                      self.reference_productCostAmount  *       self.quantity
        self.total_profitMarginTotal =              self.unit_profitMargin      *       self.quantity
        
        self.total_taxAmount =                      self.unit_taxAmount         *       self.quantity
        self.total =                                self.total_subTotal         +       self.total_taxAmount
    }
}



