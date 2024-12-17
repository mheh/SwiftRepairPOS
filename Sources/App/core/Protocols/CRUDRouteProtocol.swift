import Vapor
import FluentKit
import MWServerModels

/// Routes for repeatable CRUD operations on a model
public protocol CRUDRouteProtocol {
    
    
    // MARK: Model and associated DTO
    
    /// The primary model for this routes' implementation
    associatedtype PrimaryModel: Model, ModelDateTrackingProtocol
    
    // TODO: associatedtype DTO: MWDTO_CRUDModel
    // associatedtype DTO: MWDTO_CRUDModel
    
    // MARK: Endpoint handlers
    
    /// The response for creating a new model
    associatedtype CreateResponse: Content
    /// Create a new instance of the `PrimaryModel` unless otherwise implemented
    func create(_ req: Request) async throws -> CreateResponse
 
    /// The response for a search request
    associatedtype SearchResponseModel: Content
    /// Advanced searching of the`PrimaryModel` type
    func searchAll(_ req: Request) async throws -> SearchResponseModel
    
    /// The response for reading a single model.
    /// This should have most foreign relations loaded
    associatedtype GetSingleModel: Content
    /// Return the `PrimaryModel` with eager loading.
    /// This endpoint is used primarily for opening a document in the frontend
    func getSingle(_ req: Request) async throws -> GetSingleModel
    
    /// The response when updating a model at the server
    associatedtype UpdateResponse: Content
    /// Change the model at the server with new information
    func updateModel(_ req: Request) async throws -> UpdateResponse
    
    /// Try to delete this model at the server/
    func delete(_ req: Request) async throws -> HTTPStatus
    
    
    // MARK: MWSearchURLQueryTerms Handler
    /// Return a new query to the database based on the decoded search request body
    func handleAdvancedSearch(s: MWSearchURLQueryTerms, _ db: Database) throws -> QueryBuilder<PrimaryModel>
}

extension CRUDRouteProtocol {
    // TODO: This func is missing my .advancedSearchNotReady error implementation?
    /*
    /// `Default Implementation`: don't handle all advanced search features. Offer basic fiiltering operations
    func handleAdvancedSearch(s: MWSearchURLQueryTerms, _ db: Database) throws -> QueryBuilder<PrimaryModel> {
        let query = PrimaryModel.query(on: db)
        
        // if the fields are populated don't progress further.
        guard !s.fields.isEmpty else {
            throw CRUDError<PrimaryModel>.advancedSearchNotReady
        }
        
        // TODO: handle basic global search through ModelDateProtocol
        if let _ = s.createdStartDate {
        }
        
        if let _ = s.createdEndDate {
            
        }
        
        return query
    }
*/
}
