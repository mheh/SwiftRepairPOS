import Vapor

enum SupplierError: AppError {
}

extension SupplierError: AbortError {
    var status: HTTPStatus {
        switch self {
        }
    }
    
    var reason: String {
        switch self {
        }
    }
    
    var identifier: String {
        switch self {
        }
    }
}
