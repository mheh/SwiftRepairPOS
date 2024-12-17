//
// - ProductSerialNumber.swift from  in 2023


import Fluent
import Vapor
import MWServerModels

/// A tracked serial number in the system
///
/// - Can be located somewhere
/// - Can be sold
/// - Unique on serial number and product to prevent duplicates
final class ProductSerialNumber: Model, Content, ModelDateTrackingProtocol, @unchecked Sendable {
    
    static let schema = ProductSerialNumber.V1.schemaName
    
    @ID(custom: V1.id)                                                  var id: Int?
    
    
    // MARK: DateTracking Protocol
    @Timestamp(key: ProductSerialNumber.V1.createdAt, on: .create)      var createdAt: Date?
    @Timestamp(key: ProductSerialNumber.V1.updatedAt, on: .update)      var updatedAt: Date?
    @Timestamp(key: ProductSerialNumber.V1.deletedAt, on: .delete)      var deletedAt: Date?
    
    
    
    
    
    
    // MARK: Model
    
    /// The serial number
    @Field(key: ProductSerialNumber.V1.serialNumber)                    var serialNumber: String
    
    /// The product this serial number belongs to
    @Parent(key: ProductSerialNumber.V1.productID)                      var productID: Product
    
    /// Where this serial number is currently located
    @Parent(key: ProductSerialNumber.V1.locationID)                     var locationID: InventoryLocation
    
    /// If this serial number is sold
    @Field(key: ProductSerialNumber.V1.isSold)                          var isSold: Bool
    
    
    
    /// Linked InventoryIncrements for this serial number
    @Siblings(through: IncrementSerialPivot.self,
              from: \IncrementSerialPivot.$serialNumber,
              to: \IncrementSerialPivot.$increment) var increments: [InventoryIncrement]
    
    
    
    
    
    
    // MARK: Initializers
    
    init() { }
    
    init(serialNumber: String, productID: Product.IDValue, locationID: InventoryLocation.IDValue, isSold: Bool = false) {
        self.serialNumber = serialNumber
        self.$productID.id = productID
        self.$locationID.id = locationID
        self.isSold = isSold
    }
    
    
    
    
    
    // MARK: Methods
    
    /// Lookup a serial number for a product
    static func find(_ serialNumber: String, for product: Product.IDValue, on database: Database) async throws -> ProductSerialNumber? {
        return try await ProductSerialNumber.query(on: database)
            .filter(\.$serialNumber == serialNumber)
            .filter(\.$productID.$id == product)
            .first()
    }
}






// MARK: - SharedModels Initializers
extension SerialNumber_DTO.V1.Model: Content {}


extension SerialNumber_DTO.V1.Model {
    init (from serial: ProductSerialNumber) throws {
        self.init(
            id: try serial.requireID(),
            createdAt: serial.createdAt ?? Date().failedOptional(),
            updatedAt: serial.updatedAt ?? Date().failedOptional(),
            serialNumber: serial.serialNumber,
            productID: try Product_DTO.V1.Model(from: serial.productID),
            locationID: try ProductLocation_DTO.Model(from: serial.locationID),
            isSold: serial.isSold,
            increments: [])
    }
}






// MARK: - Migrations

extension ProductSerialNumber {
    enum V1 {
        static let schemaName = "product_serial_number"

        static let id =                 FieldKey(stringLiteral: "id")

        // MARK: DateTracking Protocol
        static let createdAt =          FieldKey(stringLiteral: "created_at")
        static let updatedAt =          FieldKey(stringLiteral: "updated_at")
        static let deletedAt =          FieldKey(stringLiteral: "deleted_at")

        // MARK: Model
        static let serialNumber =       FieldKey(stringLiteral: "serial_number")
        static let productID =          FieldKey(stringLiteral: "product_id")
        static let locationID =         FieldKey(stringLiteral: "location_id")
        static let isSold =             FieldKey(stringLiteral: "is_sold")

        static let unique_on_serial_and_product = "unique_on_serial_and_product"

        /// Initial ProductSerialNumber table creation
        struct CreateProductSerialNumberDatabase: AsyncMigration {
            func prepare(on database: Database) async throws {
                try await database.schema(ProductSerialNumber.V1.schemaName)
                    .field(ProductSerialNumber.V1.id,                   .int,           .identifier(auto: false))

                // MARK: DateTracking Protocol
                    .field(ProductSerialNumber.V1.createdAt,            .datetime)
                    .field(ProductSerialNumber.V1.updatedAt,            .datetime)
                    .field(ProductSerialNumber.V1.deletedAt,            .datetime)

                // MARK: Model
                    .field(ProductSerialNumber.V1.serialNumber,     .string,            .required)
                    .field(ProductSerialNumber.V1.productID,        .int,               .required, 
                        .references(Product.V1.schemaName, .id))
                    .field(ProductSerialNumber.V1.locationID,       .uuid,              .required, 
                        .references(InventoryLocation.V1.schemaName, .id))
                    .field(ProductSerialNumber.V1.isSold,           .bool,              .required)

                    .unique(on: ProductSerialNumber.V1.serialNumber, ProductSerialNumber.V1.productID, name: ProductSerialNumber.V1.unique_on_serial_and_product)

                    .create()
            }

            /// Try to delete the table
            func revert(on database: Database) async throws {
                try await database.schema(ProductSerialNumber.V1.schemaName).delete()
            }
        }
    
    }
}

