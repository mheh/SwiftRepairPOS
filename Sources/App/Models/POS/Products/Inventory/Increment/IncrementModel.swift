import Fluent
import Vapor

import MWServerModels

// MARK: - Model Definition

/// This model keeps track of the inventory amounts for a product at a given location.
/// When an InventoryTransfer is processed the amount is negated from the current location and added to the new location
/// Serial numbers are tied here via the pivot model
final class InventoryIncrement: Model, Content, ModelDateTrackingProtocol, @unchecked Sendable {
    static let schema = InventoryIncrement.V1.schemaName

    @ID(custom: InventoryIncrement.V1.id, generatedBy: .database)   var id: Int?

    // MARK: DateTracking Protocol
    @Timestamp(key: InventoryIncrement.V1.createdAt, on: .create)   var createdAt: Date?
    @Timestamp(key: InventoryIncrement.V1.updatedAt, on: .update)   var updatedAt: Date?
    @Timestamp(key: InventoryIncrement.V1.deletedAt, on: .delete)   var deletedAt: Date?

    // MARK: Model
    /// Tracked product for this increment amount
    @Parent(key: InventoryIncrement.V1.productID)                   var productID: Product
    /// The location that we're adjusting totals for
    @Parent(key: InventoryIncrement.V1.locationID)                  var locationID: InventoryLocation
    /// The product quantity value to adjust for the location (add/subtract quantity level)
    @Field(key: InventoryIncrement.V1.amount)                       var amount: Int
    
    /// If serial numbers are tracked with this increment, they should be linked here
    @Siblings(through: IncrementSerialPivot.self,
              from: \IncrementSerialPivot.$increment,
              to: \IncrementSerialPivot.$serialNumber) var serials: [ProductSerialNumber]

    // MARK: - Initializers

    /// Empty initializer for fluent
    init() { }

    /// Basic initializer
    init(productID: Product.IDValue, locationID: InventoryLocation.IDValue, amount: Int) {
        self.$productID.id = productID
        self.$locationID.id = locationID
        self.amount = amount
    }
}

fileprivate typealias DTO = ProductIncrement_DTO.V1
extension DTO.Model: Content {}
extension DTO.Model {
    init(from increment: InventoryIncrement) throws {
        self.init(
            id: try increment.requireID(),
            createdAt: increment.createdAt ?? Date().failedOptional(),
            updatedAt: increment.updatedAt ?? Date().failedOptional(),
            deletedAt: increment.deletedAt,
            
            productID: increment.$productID.id,
            product: try {
                if let product = increment.$productID.value {
                    return try .init(from: product)
                }
                return nil
            }(),
            
            locationID: increment.$locationID.id,
            location: try {
                if let location = increment.$locationID.value {
                    return try .init(from: location)
                }
                return nil
            }(),
            
            amount: increment.amount,
            serials: try {
                if let serials = increment.$serials.value {
                    return try serials.map { return try .init(from: $0) }
                }
                return []
            }()
        )
    }
}
