//
// - Product_Commissionable.swift from  in 2023


import Fluent
import Vapor
import MWServerModels

// MARK: - Model Definition

/// If a product is marked as commissionable, this stores information about how it is commissionable
final class Product_CommissionableInformation: Model, ModelDateTrackingProtocol, @unchecked Sendable {
    
    static let schema = Product_CommissionableInformation.V1.schemaName
    
    @ID                                                                 var id: UUID?
    
    // MARK: DateTracking Protocol
    
    @Timestamp(key:         Product_CommissionableInformation.V1.createdAt, on: .create)          var createdAt: Date?
    @Timestamp(key:         Product_CommissionableInformation.V1.updatedAt, on: .update)          var updatedAt: Date?
    @Timestamp(key:         Product_CommissionableInformation.V1.deletedAt, on: .delete)          var deletedAt: Date?
    
    
    
    // MARK: Descriptors
    
    /// The title for this commission: `Used Computers` or `In-Store Support`
    @Field(key: Product_CommissionableInformation.V1.title)                        var title: String
    
    /// The description for this commission: `For every used computer sale you can make $50`
    @Field(key: Product_CommissionableInformation.V1.commDescription)              var commDescription: String
    
    
    
    // MARK: Model
    
    typealias CommissionType = Product_CommissionableInformation.V1.CommissionType
    typealias CommissionTypeDTO = MWServerModels.ProductCommissionableInfo_DTO.V1.CommissionType_DTO
    
    /// What type of commission this is
    @Field(key: Product_CommissionableInformation.V1.commissionType)               var commissionType: Product_CommissionableInformation.V1.CommissionType
    
    /// Convert `DTO` to `CommissionType`
    func mapCommissionTypeDTOToType(_ type: CommissionTypeDTO) -> CommissionType {
        switch type {
        case .flatAmount:
            return .flatAmount
        case .percentageSell:
            return .percentageSell
        case .percentageMargin:
            return .percentageMargin
        }
    }
    /// Convert `CommissionType` to `DTO`
    func mapCommissionTypeToDTO(_ type: CommissionType) -> CommissionTypeDTO {
        switch type {
        case .flatAmount:
            return .flatAmount
        case .percentageSell:
            return .percentageSell
        case .percentageMargin:
            return .percentageMargin
        }
    }
    
    
    /// The amount for the commission type.
    /// For `flatAmount`, `20.00` will be saved.
    /// For `percentage`, `0.1500` will be saved.
    @Field(key: Product_CommissionableInformation.V1.amount)                       var amount: Decimal
    
    
    
    
    // MARK: Intializers
    
    /// Basic initializer
    init(
        id: UUID? = nil,
        createdAt: Date? = nil, updatedAt: Date? = nil, deletedAt: Date? = nil,
        title: String, commDescription: String,
        commissionType: Product_CommissionableInformation.V1.CommissionType, amount: Decimal
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.commDescription = commDescription
        self.commissionType = commissionType
        self.amount = amount
    }
    
    init() {}
    
    /// Init from DTO type
    init(from commissionDTO: ProductCommissionableInfo_DTO.V1.Model) {
        self.title = commissionDTO.title
        self.commDescription = commissionDTO.commDescription
        self.commissionType = self.mapCommissionTypeDTOToType(commissionDTO.commissionType)
        self.amount = commissionDTO.amount
    }
    
}

// MARK: DTO
fileprivate typealias DTO = MWServerModels.ProductCommissionableInfo_DTO.V1

extension DTO.Model: Content {}
extension DTO.CreateRequestModel: Content {}
extension DTO.UpdateRequestModel: Content {}

extension DTO.Model {
    init(from commissionable: Product_CommissionableInformation) throws {
        self.init(
            id: try commissionable.requireID(),
            createdAt: commissionable.createdAt ?? Date().failedOptional(),
            updatedAt: commissionable.updatedAt ?? Date().failedOptional(),
            title: commissionable.title,
            commDescription: commissionable.commDescription,
            commissionType: commissionable.mapCommissionTypeToDTO(commissionable.commissionType),
            amount: commissionable.amount)
    }
}
