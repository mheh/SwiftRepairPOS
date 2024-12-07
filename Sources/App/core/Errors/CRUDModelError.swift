//
//  CRUDModelError.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/6/24.
//

import Foundation
import Vapor
import Fluent

/// Vapor Model errors for database lookup
enum CRUDError<T: Model>: AppError {
    /// A model was not found in the database
    case notFound
    /// The ID was not provided in the path
    case missingID(path: String)
    
    public var status: HTTPResponseStatus {
        switch self {
        case .notFound:
            return .notFound
        case .missingID:
            return .badRequest
        }
    }
    
    public var reason: String {
        switch self {
        case .notFound:
            return "\(T.self) not found"
        case .missingID(let path):
            return "Missing ID in '\(path)' for \(T.self)"
        }
    }
    
    public var identifier: String {
        switch self {
        case .notFound:
            return "\(T.schema)_not_found"
        case .missingID:
            return "\(T.schema)_missing_id"
        }
    }
}
