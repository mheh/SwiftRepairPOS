//
//  CRUDProtocol.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/16/24.
//
import Fluent

/// This requires any DTO model in this package to have consistent models for CRUD operations
public protocol DTO_CRUDModel {
    /// The path appended to `https://serveraddress:port/api/`
    /// Example: `customers` which will be referred to in the associated `DTORequest` objects
    static var path: String { get }
    
    // MARK: DTO Models
    
    /// A full implementation of the model when everything is returned by the server
    associatedtype Model: Codable, Identifiable, Hashable
    /// An array of either `Model` or `MinimumModel` with metadata
    associatedtype GetAllModel: DTO_CRUDModel_GetAllModelProtocol
    /// The model used for a CreateRequest
    associatedtype CreateRequestModel: Codable
    /// The model for updating information at the server
    associatedtype UpdateRequestModel: Codable


    // MARK: Request Models
    
    /// The request for creating a new model at the server
    associatedtype CreateRequest: DTORequest_CreateRequestProtocol
    /// The request for reading a single model from the server
    associatedtype ReadRequest: DTORequest_ReadRequestProtocol
    /// The request for reading all models from the server
    associatedtype ReadAllRequest: DTORequest_ReadAllRequestProtocol
    /// The request for updating a single model at the server
    associatedtype UpdateRequest: DTORequest_UpdateRequestProtocol
    /// The request for deleting amodel at the server
    associatedtype DeleteRequest: DTORequest_DeleteRequestProtocol
}

extension DTO_CRUDModel {
    // MARK: Models
    public typealias GetAllModel = DTO_CRUDModel_GetAllModel<Self>
    // MARK: Requests
    public typealias CreateRequest = DTORequest_CreateRequest<Self>
    public typealias ReadRequest = DTORequest_ReadRequest<Self>
    public typealias ReadAllRequest = DTORequest_ReadAllRequest<Self>
    public typealias UpdateRequest = DTORequest_UpdateRequest<Self>
    public typealias DeleteRequest = DTORequest_DeleteRequest<Self>
}


/// Requirements for the `GetAllModel` associated with `MWDTO_CRUDModel`
public protocol DTO_CRUDModel_GetAllModelProtocol<DTO>: Codable {
    associatedtype DTO: DTO_CRUDModel
    /// The paginated items returned from the server
    var items: [DTO.Model] { get set }
    /// Pagination information from the server
    var metaData: PageMetadata { get set }
}

/// Requirements for a `GetAllModel` from the server.
public struct DTO_CRUDModel_GetAllModel<DTO: DTO_CRUDModel>: DTO_CRUDModel_GetAllModelProtocol {
    public var items: [DTO.Model]
    public var metaData: PageMetadata
    
    public init(items: [DTO.Model], metaData: PageMetadata) {
        self.items = items
        self.metaData = metaData
    }
}
