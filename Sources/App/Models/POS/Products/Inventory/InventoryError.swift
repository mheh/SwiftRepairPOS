//

import Vapor

enum InventoryError: AppError {
    /// This product is not inventoried
    case notInventoried
    /// In Inventory SubController, only editing and removing adjustments can be done through the controller
    case onlyAdjustments
    /// When the product ID does not match the inventory increment through route verification
    case mismatchProductID
    /// The serial number query is missing from a new increment creation
    case serialNumberQuery
}

extension InventoryError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .notInventoried:
            return .badRequest
        case .onlyAdjustments:
            return .badRequest
        case .mismatchProductID:
            return .badRequest
        case .serialNumberQuery:
            return .badRequest
        }
    }
    
    var reason: String {
        switch self {
        case .notInventoried:
            return "Product is not inventoried, inventory tracking is not possible until enabled."
        case .onlyAdjustments:
            return "Can only edit/remove inventory adjustments"
        case .mismatchProductID:
            return "Mismatch of ProductID and Inventory Increment in request"
        case .serialNumberQuery:
            return "Error decoding serial number from query"
        }
    }
    
    var identifier: String {
        switch self {
        case .notInventoried:
            return "inventory_product_not_inventoried"
        case .onlyAdjustments:
            return "inventory_edit_remove_adjustments"
        case .mismatchProductID:
            return "inventory_mismatch_productid_increment"
        case .serialNumberQuery:
            return "inventory_serialnumber_query_decode_error"
        }
    }
}
