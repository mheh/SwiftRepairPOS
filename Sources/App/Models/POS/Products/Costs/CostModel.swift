import Fluent
import Vapor

import MWServerModels

fileprivate typealias DTO = ProductCost_DTO.V1

// MARK: - Model Definition

/// Product Cost information in system
/// A single product can have numerous costs for it depending on where it comes from
/// Supplier A sells this product for $12.34 in 2021. In 2023 it is now $15.85 with a different SKU
/// This means we can have multiple costs from the same supplier, but differentiate through supplir SKU
final class ProductCost: Model, Content, ModelDateTrackingProtocol, @unchecked Sendable {
    static let schema = ProductCost.V1.schemaName
    
    @ID                                                                 var id: UUID?
    
    // MARK: DateTracking Protocol
    @Timestamp(key:         ProductCost.V1.createdAt, on: .create)      var createdAt: Date?
    @Timestamp(key:         ProductCost.V1.updatedAt, on: .update)      var updatedAt: Date?
    @Timestamp(key:         ProductCost.V1.deletedAt, on: .delete)      var deletedAt: Date?
    
    // MARK: Model
    /// The parent product of this cost
    @Parent(key: ProductCost.V1.productID)                              var productID: Product
    /// Optionally a saved cost from an existing supplier
    @OptionalParent(key: ProductCost.V1.supplierID)                     var supplierID: Supplier?
    
    /// Whether this cost is the default cost.
    /// There can only be one (per product)
    @Field(key: ProductCost.V1.defaultCost)                             var defaultCost: Bool
    /// The cost amount
    @Field(key: ProductCost.V1.cost)                                    var cost: Decimal
    /// The unique code provided by a supplier for their cost amount.
    /// This doesn't require a supplier to be tied to the cost, it can be used
    /// to keep track of internal costs.
    @Field(key: ProductCost.V1.supplierCode)                            var supplierCode: String
    
    init() { }
    
    /// Default initializer
    init(id: UUID? = nil, productID: Product, defaultCost: Bool = false, cost: Decimal, supplierCode: String) throws {
        self.id = id
        self.$productID.id = try productID.requireID()
        if let supplierID = supplierID {
            self.$supplierID.id = try supplierID.requireID()
        } else { self.$supplierID.id = nil }
        self.defaultCost = defaultCost
        self.cost = cost
        self.supplierCode = supplierCode
    }
    
    /// POST Create method
    init(from mwcost: ProductCost_DTO.V1.CreateUpdateRequest, productID: Int) {
        self.$productID.id = productID
        self.$supplierID.id = mwcost.supplierID
        self.defaultCost = mwcost.defaultCost
        self.cost = mwcost.cost
        self.supplierCode = mwcost.supplierCode
    }
    
    /// Perform model specific updates from a PUT request
    func updateModel(rData: ProductCost_DTO.V1.CreateUpdateRequest) {
        if let supplierID =     rData.supplierID {
            self.$supplierID.id = supplierID
        } else {
            self.$supplierID.id = nil
        }
        self.defaultCost =      rData.defaultCost
        self.cost =             rData.cost
        self.supplierCode =     rData.supplierCode
    }
}

// MARK: - MWServerModels Initializers
extension DTO.Model: Content {}
extension DTO.Model {
    init(from prodcost: ProductCost) throws {
        self.init(
            id: try prodcost.requireID(),
            createdAt: prodcost.createdAt ?? Date().failedOptional(),
            updatedAt: prodcost.updatedAt ?? Date().failedOptional(),
            defaultCost: prodcost.defaultCost,
            cost: prodcost.cost, supplierCode:
                prodcost.supplierCode)
    }
}

extension DTO.minModel: Content {}
extension DTO.minModel {
    init(from cost: ProductCost) {
        self.init(defaultCost: cost.defaultCost, cost: cost.cost, supplierCode: cost.supplierCode)
    }
}


extension DTO.CreateUpdateRequest: Content {}
