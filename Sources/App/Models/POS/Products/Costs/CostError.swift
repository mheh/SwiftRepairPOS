import Vapor

enum ProductCostError: AppError {
    /// The product cost productID does not match the productID supplied in URL request
    case mismatchProductID
}

extension ProductCostError: AbortError {
    var status: HTTPStatus {
        switch self {
        case .mismatchProductID:
            return .badRequest
        }
    }
    
    var reason: String {
        switch self {
        case .mismatchProductID:
            return "Requested product cost is not for this product"
        }
    }
    
    var identifier: String {
        switch self {
        case .mismatchProductID:
            return "productcosts_mismatched_productID"
        }
    }
}
