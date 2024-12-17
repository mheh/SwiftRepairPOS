import Fluent
import Vapor
import MWServerModels

/// Product information in system
final class Product: Model, Content, ModelDateTrackingProtocol, @unchecked Sendable {
    static let schema = Product.V1.schemaName
    
    /// The numeric `ID` of the system's `Product`
    @ID(custom: Product.V1.id)                                          var id: Int?
    /// Return a string identifier of this product's `ID` field
    func idString() throws -> String { return try "P-\(self.requireID())" }
    
    // MARK: DateTracking Protocol
    @Timestamp(key:         Product.V1.createdAt, on: .create)          var createdAt: Date?
    @Timestamp(key:         Product.V1.updatedAt, on: .update)          var updatedAt: Date?
    @Timestamp(key:         Product.V1.deletedAt, on: .delete)          var deletedAt: Date?
    
    
    
    // MARK: Identifiers
    
    /// Product Code
    /// ex: "MD101LL/A"
    @Field(key: Product.V1.code)                                        var code: String
    
    /// UPC Code
    @Field(key: Product.V1.upc)                                         var upc: String
    
    /// Description of product
    @Field(key: Product.V1.productDescription)                          var productDescription: String
    
    /// The global sell price of the product
    @Field(key: Product.V1.sellPrice)                                   var sellPrice: Decimal
    
    
    // MARK: Costs
    
    /// Assigned default cost information for this product.
    /// This is for tracking line item costs. When this is changed, all future line items will start use this cost information
    @OptionalParent(key: Product.V2.defaultCostID)                      var defaultCostID: ProductCost?
    
    /// The average cost for this product, should be updated when new `ProductCost` models are created for this `Product`
    /// Default is `0.00` set by the database
    @Field(key: Product.V2.averageCost)                                 var averageCost: Decimal
    
    /// `ProductCost` models associated to this `Product` model;
    @Children(for: \.$productID)                                        var costs: [ProductCost]

    
    
    // MARK: Booleans
    
    /// Is this product taxable?
    @Field(key: Product.V1.taxable)                                     var taxable: Bool
    
    /// Are quantities tracked for this product?
    @Field(key: Product.V1.inventoried)                                 var inventoried: Bool
    
    /// Are serial numbers required for this product?
    @Field(key: Product.V1.serialized)                                  var serialized: Bool
    
    /// Whether this product has an editable sell price or not.
    @Field(key: Product.V2.editableSellPrice)                           var editableSellPrice: Bool
    
    /// If this product is commissionable we have the commission information assigned here
    @OptionalParent(key: Product.V1.commissionID)                       var commissionID: Product_CommissionableInformation?
    
    
    
    // MARK: Lightspeed Import ID
    
    /// Optional Lightspeed Product ID associated with this product model.
    @OptionalField(key: Product.V1.lightspeedImportID)                  var lightspeedImportID: Int?
    
    
    
    // MARK: Descriptors
    /// Identification by manufacturer name
    ///     `Apple` or `Samsung`
    ///
    /// This is just the name of the manufacturer
    @Field(key: Product.V1.manufacturer)                                var manufacturer: String
    
    /// Identification by product type
    ///     `Laptop` or `Desktop`
    ///
    /// Least amount of information to group this type
    @Field(key: Product.V1.manufacturerType)                            var manufacturerType: String
    
    /// Identification by manufacturer model
    ///     `MacBook Pro`
    ///
    /// This should be the absolute least possible amount of information to define the model
    @Field(key: Product.V1.manufacturerModel)                           var manufacturerModel: String
    
    
    
    // MARK: Foreign fields

    /// Product Inventory tied to this product ID
    /// Passthrough to InventoryIncrement
    @Children(for: \.$productID)                                        var inventory: [InventoryIncrement]
    
    
    // MARK: Helper Methods
    
    /// Update the `Product.averageCost` field from `ProductCost` models assigned to this model.
    func updateAverageCostField(on database: Database) async throws {
        let costs = try await self.$costs.get(reload: true, on: database)
        guard costs.count > 0 else {
            self.averageCost = 0.00
            return try await self.update(on: database)
        }
        
        self.averageCost = costs.map { $0.cost }.sum()
        return try await self.update(on: database)
    }
    
    
    // MARK: Initializers
    
    /// Blank Initializer for Fluent
    init() { }
    
    /// Full initializer
    /// Does not include `importedLightspeedID`
    init(id: Int? = nil,
         code: String,
         upc: String,
         productDescription: String,
         sellPrice: Decimal,
         defaultCostID: ProductCost.IDValue? = nil,
         averageCost: Decimal = 0.00,
         taxable: Bool = true,
         inventoried: Bool,
         serialized: Bool = false,
         editableSellPrice: Bool = true,
         commissionableID: Product_CommissionableInformation.IDValue? = nil,
         manufacturer: String = "",
         manufacturerType: String = "",
         manufacturerModel: String = ""
    ) {
        self.id = id
        self.code = code.trimmingCharacters(in: .whitespacesAndNewlines)
        self.upc = upc.trimmingCharacters(in: .whitespacesAndNewlines)
        self.productDescription = productDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.sellPrice = sellPrice
        
        self.$defaultCostID.id = defaultCostID
        self.averageCost = averageCost
        
        self.taxable = taxable
        self.inventoried = inventoried
        self.serialized = serialized
        self.editableSellPrice = editableSellPrice
        self.$commissionID.id = commissionableID
        
        self.manufacturer = manufacturer
        self.manufacturerType = manufacturerType
        self.manufacturerModel = manufacturerModel
    }

    /// `CreateRequestModel`
    init(from mwprod: Product_DTO.V1.CreateRequestModel) {
        self.code = mwprod.code.trimmingCharacters(in: .whitespacesAndNewlines)
        self.upc = mwprod.upc.trimmingCharacters(in: .whitespacesAndNewlines)
        self.productDescription = mwprod.productDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.sellPrice = mwprod.sellPrice
        
        // TODO: self.$defaultCostID.id = mwprod.defaultCostID
        // TODO: self.averageCost = mwprod.averageCost
        
        self.taxable = mwprod.taxable
        self.inventoried = mwprod.inventoried
        self.serialized = mwprod.serialized
        // self.editableSellPrice = mwprod.editableSellPrice
        
        self.manufacturer = mwprod.manufacturer
        self.manufacturerType = mwprod.manufacturerType
        self.manufacturerModel = mwprod.manufacturerModel
    }
    
}

// MARK: - SharedModels Initializers

extension Product_DTO.V1.CreateRequestModel: Content {}
extension Product_DTO.V1.UpdateRequestModel: Content {}
extension Product_DTO.V1.Model: Content {}
extension Product_DTO.V1.Model {
    /// Transfer model to client
    init(from prod: Product) throws {
        self.init(
            id: try prod.requireID(),
            createdAt: prod.createdAt ?? Date().failedOptional(),
            updatedAt: prod.updatedAt ?? Date().failedOptional(),
            code: prod.code,
            upc: prod.upc,
            productDescription: prod.productDescription,
            sellPrice: prod.sellPrice,
            taxable: prod.taxable,
            inventoried: prod.inventoried,
            serialized: prod.serialized,
            lightspeedImportID: prod.lightspeedImportID,
            manufacturer: prod.manufacturer,
            manufacturerType: prod.manufacturerType,
            manufacturerModel: prod.manufacturerModel
        )
    }
}

// MARK: - Model Methods
extension Product {
    /// Perform model specific updates from a PUT request
    func updateModel(rData: Product_DTO.V1.UpdateRequestModel) {
        if let code = rData.code {
            self.code = code.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let upc = rData.upc {
            self.upc = upc.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let productDescription = rData.productDescription {
            self.productDescription = productDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let sellPrice = rData.sellPrice {
            self.sellPrice = sellPrice
        }
        if let taxable = rData.taxable {
            self.taxable = taxable
        }
        if let inventoried = rData.inventoried {
            self.inventoried = inventoried
        }
        if let serialized = rData.serialized {
            self.serialized = serialized
        }
        if let manufacturer = rData.manufacturer {
            self.manufacturer = manufacturer
        }
        if let manufacturerType = rData.manufacturerType {
            self.manufacturerType = manufacturerType
        }
        if let manufacturerModel = rData.manufacturerModel {
            self.manufacturerModel = manufacturerModel
        }
    }
}
