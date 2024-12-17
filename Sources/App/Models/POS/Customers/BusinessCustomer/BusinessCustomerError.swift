import Vapor

enum BusinessCustomerError: AppError {
}

extension BusinessCustomerError: AbortError {
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
