//
// - TransferModel.swift from  in 2023


import Fluent
import Vapor
import MWServerModels

/// This is the tracker for transferring SINGULAR inventory amounts from one location to another
/// It utilizes the InventoryIncrement model to track the inventory changes
/// Various options here include:
/// - Transfer from a location to a location (Transfer) - Label: T-xxxx
/// - Adjustment of inventory (Adjustment) - Label: A-xxxx
/// - Transfer to a different store location (Multi-Store Transfer) - Label: MST-xxxx
final class InventoryTransfer: Model, Content, ModelDateTrackingProtocol, @unchecked Sendable {
    static let schema = InventoryTransfer.V1.schemaName

    @ID(custom: InventoryTransfer.V1.id, generatedBy: .database)    var id: Int?

    // MARK: DateTracking Protocol
    @Timestamp(key: InventoryTransfer.V1.createdAt, on: .create)    var createdAt: Date?
    @Timestamp(key: InventoryTransfer.V1.updatedAt, on: .update)    var updatedAt: Date?
    @Timestamp(key: InventoryTransfer.V1.deletedAt, on: .delete)    var deletedAt: Date?

    // MARK: Model
    /// The type of transfer (enum string stored in db)
    @Field(key: InventoryTransfer.V1.type)                          var type: InventoryTransfer.V1.TransferType.RawValue
    /// Optionally, where are we transferring this inventory from
    @OptionalParent(key: InventoryTransfer.V1.fromLocationID)       var fromLocationID: InventoryLocation?
    /// Where is this inventory going to?
    @Parent(key: InventoryTransfer.V1.toLocationID)                 var toLocationID: InventoryLocation
    
    /// Optionally, where are we transferring this inventory from
    @OptionalParent(key: InventoryTransfer.V1.fromIncrementID)      var fromIncrementID: InventoryIncrement?
    /// Where is this inventory going to?
    @Parent(key: InventoryTransfer.V1.toIncrementID)                var toIncrementID: InventoryIncrement
    
    // TODO: Implement Multi-Store
    //@OptionalParent(key: InventoryTransfer.V1.fromMultiStoreID)             var fromMultiStoreID: UUID?
    //@OptionalParent(key: InventoryTransfer.V1.toMultiStoreID)               var toMultiStoreID: UUID?

    @Parent(key: InventoryTransfer.V1.userID)                       var userID: User
    @Field(key: InventoryTransfer.V1.notes)                         var notes: String
    
    /// Empty init for Fluent
    init() {}
    
    /// Adjustment Init for Product Sub Controller
    init(type: InventoryTransfer.V1.TransferType, toLocation: InventoryLocation.IDValue, toIncrement: InventoryIncrement.IDValue, userID: User.IDValue) {
        self.type =                 type.rawValue
        self.$fromLocationID.id =   nil
        self.$toLocationID.id =     toLocation
        self.$fromIncrementID.id =  nil
        self.$toIncrementID.id =    toIncrement
        self.$userID.id =           userID
        self.notes =                    ""
    }
}

// MARK: - SharedModels Initializers

extension ProductInventoryTransfer_DTO.Model: Content {}
/*
extension ProductInventoryTransfer_DTO.model {
    init(from transfer: InventoryTransfer) throws {
    }
}
*/
