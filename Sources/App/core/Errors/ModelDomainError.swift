import Foundation
import Vapor
import Fluent

/// Generic errors related to Vapor/Fluent issues that are unrelated to model defined issues
enum ModelDomainError<T: Model>: AppError {
    /// An eager loading error
    /// MDE1
    case notLoaded(field: String)
    
    var status: HTTPResponseStatus {
        switch self {
        case .notLoaded:
            return .internalServerError
        }
    }
    
    var reason: String {
        switch self {
        case .notLoaded(let field):
            return "Error loading \(field) for \(T.self)"
        }
    }
    
    var identifier: String {
        switch self {
        case .notLoaded:
            return "MDE1"
        }
    }
}
