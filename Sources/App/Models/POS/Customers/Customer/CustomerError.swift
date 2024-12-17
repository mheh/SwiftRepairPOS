import Vapor

/// An error specific to customer model
enum CustomerError: AppError {
    case lightspeedImport_fieldError(String)
    case lightspeedImport_notFound(String?)
    
    case eagerLoading(field: String)

}

extension CustomerError: AbortError {
    var status: HTTPStatus {
        switch self {
        case .lightspeedImport_fieldError:
            return .badRequest
        case .lightspeedImport_notFound:
            return .notFound
            
        case .eagerLoading:
            return .internalServerError
        }
    }
    
    var reason: String {
        switch self {
        case .lightspeedImport_fieldError(let reason):
            return "Unable to import this product from Lightspeed. Missing field \(reason)"
        case .lightspeedImport_notFound(let lsID):
            if let lsID {
                return "Cannot find Lightspeed Customer ID: \(lsID)"
            } else {
                return "Missing ID for Lightspeed Customer ID"
            }
        case .eagerLoading(let field):
            return "Error reading information from customer field: \(field)"
        }
    }
    
    var identifier: String {
        switch self {
        case .lightspeedImport_fieldError:
            return "CE-LIE-1"
        case .lightspeedImport_notFound:
            return "CE-LIE-2"
        case .eagerLoading:
            return "CE-EL-1"
        }
    }
}
