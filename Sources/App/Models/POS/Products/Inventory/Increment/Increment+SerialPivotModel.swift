import Fluent
import Vapor

import MWServerModels

// MARK: - Model Definition

/// This model is used for inventory adjustments with InventoryIncrement, to keep track of serial numbers created through adjustments
final class IncrementSerialPivot: Model, Content, ModelDateTrackingProtocol, @unchecked Sendable {
    static let schema = IncrementSerialPivot.V1.schemaName
    
    @ID var id: UUID?
    
    // MARK: DateTracking Protocol
    @Timestamp(key: IncrementSerialPivot.V1.createdAt, on: .create)  var createdAt: Date?
    @Timestamp(key: IncrementSerialPivot.V1.updatedAt, on: .update)  var updatedAt: Date?
    @Timestamp(key: IncrementSerialPivot.V1.deletedAt, on: .delete)  var deletedAt: Date?
    
    /// The associated increment that created this serial number adjustment
    @Parent(key: IncrementSerialPivot.V1.increment)                  var increment: InventoryIncrement
    /// The serial number created through an increment adjustment
    @Parent(key: IncrementSerialPivot.V1.serialNumber)               var serialNumber: ProductSerialNumber
    
    init () { }
    
    init(incrementID: InventoryIncrement.IDValue, serialNumberID: ProductSerialNumber.IDValue) {
        self.$increment.id = incrementID
        self.$serialNumber.id = serialNumberID
        
    }
}

extension IncrementSerialPivot {
    enum V1 {
        static let schemaName = "product_inventory_increment+serial_number"
        
        // MARK: DateTracking Protocol
        static let createdAt =              FieldKey(stringLiteral: "created_at")
        static let updatedAt =              FieldKey(stringLiteral: "updated_at")
        static let deletedAt =              FieldKey(stringLiteral: "deleted_at")
        
        // MARK: Model
        static let increment =              FieldKey(stringLiteral: "product_inventory_increment_id")
        static let serialNumber =           FieldKey(stringLiteral: "product_serial_number_id")
        
        
        /// Initial creation of pivot table between InventoryIncrement and ProductSerialNumber
        struct CreateIncrementSerialNumberPivot: AsyncMigration {
            func prepare(on database: FluentKit.Database) async throws {
                try await database.schema(IncrementSerialPivot.V1.schemaName)
                    .id()
                
                // MARK: DateTracking Protocol
                    .field(IncrementSerialPivot.V1.createdAt,       .datetime)
                    .field(IncrementSerialPivot.V1.updatedAt,       .datetime)
                    .field(IncrementSerialPivot.V1.deletedAt,       .datetime)
                
                // MARK: Model
                    .field(IncrementSerialPivot.V1.increment,       .int,
                           .references(InventoryIncrement.V1.schemaName, InventoryIncrement.V1.id),    .required)
                    .field(IncrementSerialPivot.V1.serialNumber,    .int,
                           .references(ProductSerialNumber.V1.schemaName, ProductSerialNumber.V1.id),  .required)
                
                    .create()
            }
            
            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(IncrementSerialPivot.V1.schemaName).delete()
            }
        }
    }
}
