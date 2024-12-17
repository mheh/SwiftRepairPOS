//
// - ProductError.swift from  in 2023


import Vapor

enum ProductError: AppError {
    case lightspeedImport_fieldError(String)
    case lightspeedImport_notFound(String?)
    
}

extension ProductError: AbortError {
    var status: HTTPStatus {
        switch self {
        case .lightspeedImport_fieldError:
            return .badRequest
        case .lightspeedImport_notFound:
            return .notFound
        }
    }
    
    var reason: String {
        switch self {
        case .lightspeedImport_fieldError(let reason):
            return "Unable to import this product from Lightspeed. Missing field \(reason)"
        case .lightspeedImport_notFound(let lsID):
            if let lsID {
                return "Cannot find Lightspeed Product ID: \(lsID)"
            } else {
                return "Missing ID for Lightspeed Product ID"
            }
        }
    }
    
    var identifier: String {
        switch self {
        case .lightspeedImport_fieldError:
            return "PE-LIE-1"
        case .lightspeedImport_notFound:
            return "PE-LIE-2"
        }
    }
}
