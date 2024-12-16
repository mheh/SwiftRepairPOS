//
//  RequestProtocol.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/16/24.
//
import Foundation
import Fluent

/// MWServer Web Request conformance
public protocol DTORequestProtocol {
    /// The path of the request
    var path: String { get }
    /// The query parameters for the request
    /// Defaults to `[:]`
    var urlQueryParams: [String: String] { get set }
    /// The HTTP Method for the request
    /// Example: .GET, .POST, .PUT, .DELETE
    var requestType: DTORequest_HTTPType { get }
    /// The headers for the request
    /// Defaults to `[]`
    var headers: [DTORequest_HeadersKey] { get }
    /// Whether to add the authorization header key
    /// Defaults to `true`
    var addAuthorizationToken: Bool { get }
    /// The body of the request
    /// Defaults to `nil`
    var body: Encodable? { get }
    
    /// Valid responses for a request
    var response: Decodable.Type? { get }
}

// MARK: MWRequestProtocol Default Implementation
extension DTORequestProtocol {
    public var urlQueryParams: [String: String]    { [:] }
    public var headers: [DTORequest_HeadersKey]     { [.contentType(.json) ] }
    public var addAuthorizationToken: Bool         { true }
    public var body: Encodable?                    { nil }
}

/// MWServer accepted types of HTTP requests
public enum DTORequest_HTTPType: String {
    case GET, POST, PUT, DELETE
}

/// MWServer Request Headers
public enum DTORequest_HeadersKey {
    /// Content type of request
    case contentType(DTORequest_ContentType)
}

/// Valid Content Types for MW Server Interaction
public enum DTORequest_ContentType: String {
    case json = "application/json"
    case text = "text/plain"
}

// MARK: - Request Implementations

/// Required initializer for a `CreateRequest`
public protocol DTORequest_CreateRequestProtocol<DTO>: DTORequestProtocol {
    associatedtype DTO: DTO_CRUDModel
    init(model: DTO.CreateRequestModel)
}
public struct DTORequest_CreateRequest<DTO: DTO_CRUDModel>: DTORequest_CreateRequestProtocol {
    public var path: String
    public var urlQueryParams: [String : String] = [:]
    public var requestType: DTORequest_HTTPType = .POST
    public var response: Decodable.Type? = nil
    
    public init(model: DTO.CreateRequestModel) {
        self.path = DTO.path
    }
}


/// Required initializer for a `ReadRequest`
public protocol DTORequest_ReadRequestProtocol<DTO>: DTORequestProtocol {
    associatedtype DTO: DTO_CRUDModel
    init(id: DTO.Model.ID)
}
public struct DTORequest_ReadRequest<DTO: DTO_CRUDModel>: DTORequest_ReadRequestProtocol {
    public var path: String
    public var urlQueryParams: [String : String] = [:]
    public var requestType: DTORequest_HTTPType = .GET
    public var response: Decodable.Type? = nil
    
    public init(id: DTO.Model.ID) {
        self.path = "\(DTO.path)/\(id)"
    }
}


/// Required initiailizer for a `ReadAllRequest`
public protocol DTORequest_ReadAllRequestProtocol<DTO>: DTORequestProtocol {
    associatedtype DTO: DTO_CRUDModel
    init(searchQuery: DTOSearchURLQueryTerms, metaData: PageMetadata)
}
public struct DTORequest_ReadAllRequest<DTO: DTO_CRUDModel>: DTORequest_ReadAllRequestProtocol {
    public var path: String
    public var urlQueryParams: [String : String] = [:]
    public var requestType: DTORequest_HTTPType = .GET
    public var response: Decodable.Type? = nil
    
    public init(searchQuery: DTOSearchURLQueryTerms, metaData: PageMetadata) {
        self.path = DTO.path
        let searchQueries = searchQuery.generateStringDictionary()
        for query in searchQueries {
            self.urlQueryParams[query.key] = query.value
        }
        let metaDataQueries = metaData.generateStringDictionary()
        for query in metaDataQueries {
            self.urlQueryParams[query.key] = query.value
        }
    }
}


/// Required initializer for a `UpdateRequest`
public protocol DTORequest_UpdateRequestProtocol<DTO>: DTORequestProtocol {
    associatedtype DTO: DTO_CRUDModel
    init(id: DTO.Model.ID, body: DTO.UpdateRequestModel)
}
public struct DTORequest_UpdateRequest<DTO: DTO_CRUDModel>: DTORequest_UpdateRequestProtocol {
    public var path: String
    public var urlQueryParams: [String : String] = [:]
    public var requestType: DTORequest_HTTPType = .GET
    public var response: Decodable.Type? = nil
    public var body: Encodable?
    
    public init(id: DTO.Model.ID, body: DTO.UpdateRequestModel) {
        self.path = "\(DTO.path)/\(id)"
        self.body = body
    }
}


/// Required intializer for a `DeleteRequest`
public protocol DTORequest_DeleteRequestProtocol<DTO>: DTORequestProtocol {
    associatedtype DTO: DTO_CRUDModel
    init(id: DTO.Model.ID)
}
public struct DTORequest_DeleteRequest<DTO: DTO_CRUDModel>: DTORequest_DeleteRequestProtocol {
    public var path: String
    public var urlQueryParams: [String : String] = [:]
    public var requestType: DTORequest_HTTPType = .DELETE
    public var response: Decodable.Type? = nil
    
    public init(id: DTO.Model.ID) {
        self.path = "\(DTO.path)/\(id)"
    }
}
