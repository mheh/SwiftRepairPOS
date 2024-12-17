// 
// - InventoryLocationModel.swift from  in 2023


import Fluent
import Vapor

import MWServerModels

// MARK: - Model Definition

/// An inventory location for a product
/// These models can be generated and removed by the client.
/// The systemUseOnly enum models cannot be removed by the client and do not show up in search queries as options
final class InventoryLocation: Model, Content, ModelDateTrackingProtocol, @unchecked Sendable {
    static let schema = InventoryLocation.V1.schemaName

    @ID var id: UUID?

    // MARK: DateTracking Protocol
    @Timestamp(key: InventoryLocation.V1.createdAt, on: .create)    var createdAt: Date?
    @Timestamp(key: InventoryLocation.V1.updatedAt, on: .update)    var updatedAt: Date?
    @Timestamp(key: InventoryLocation.V1.deletedAt, on: .delete)    var deletedAt: Date?

    // MARK: Model
    /// The name of this location
    @Field(key: InventoryLocation.V1.name)                          var name: String
    /// Is this the default location for this product?
    @Field(key: InventoryLocation.V1.defaultLocation)               var defaultLocation: Bool
    /// Does this appear in search results as an option for the user to select?
    @Field(key: InventoryLocation.V1.systemUseOnly)                 var systemUseOnly: Bool
    /// Whether this location can be removed
    @Field(key: InventoryLocation.V1.canBeRemoved)                  var canBeRemoved: Bool
    
    // MARK: Computed fields
    /// The current quantity of this product in this location
    /// Passthrough to InventoryIncrement
    @Children(for: \.$locationID)                                    var increments: [InventoryIncrement]

    // MARK: - Initializers

    /// Empty initializer for fluent
    init() { }

    /// Basic initializer
    /// systemUserOnly is false by default
    init (name: String, defaultLocation: Bool, systemUseOnly: Bool = false, canBeRemoved: Bool = true) {
        self.name = name
        self.defaultLocation = defaultLocation
        self.systemUseOnly = systemUseOnly
        self.canBeRemoved = canBeRemoved
    }
}

extension ProductLocation_DTO.Model: Content {}

extension ProductLocation_DTO.Model {
    init(from loc: InventoryLocation) throws {
        self.init(
            id: loc.id,
            name: loc.name,
            defaultLocation: loc.defaultLocation,
            systemUseOnly: loc.systemUseOnly,
            canBeRemoved: loc.canBeRemoved,
            increments: try {
                guard loc.$increments.value != nil else {
                    throw Abort(.internalServerError, reason: "Increments not loaded for MWProductLocation model")
                }
                return try loc.increments.map { try .init(from: $0) }
            }()
        )
    }
}

