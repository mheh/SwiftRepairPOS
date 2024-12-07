//
//  User_DTO.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/6/24.
//

import Foundation

/// User models and interaction requests
public struct User_DTO {
    public enum V1 {}
}
fileprivate typealias V1 = User_DTO.V1

extension V1 {
    // MARK: Models
    /// User model returned from server
    public struct Model: Codable, Identifiable {
        /// System user's UUID
        public var id: UUID
        
        /// System user's username
        public var username: String

        /// System user's name
        public var fullname: String

        /// System user's email
        public var email: String
        
        /// System user's admin ability
        public var isAdmin: Bool
        
        /// Whether this user can login or not
        public var isActive: Bool

        /// Whether this user has been reset
        public var isReset: Bool

        public init (id: UUID, username: String, fullname: String, email: String, isAdmin: Bool, isActive: Bool, isReset: Bool) {
            self.id = id
            self.username = username
            self.fullname = fullname
            self.email = email
            self.isAdmin = isAdmin
            self.isActive = isActive
            self.isReset = isReset
        }
    }
    
    
    /// The model to create a new user on the server
    /// The returned `Model` will be a reset user
    public struct CreateRequestModel: Codable {
        /// Username
        public var username: String
        /// Full name of the user
        public var fullname: String
        /// Email address of user
        public var email: String
        /// password
        public var password: String
        /// confirm password
        public var confirmPassword: String
        
        public init (username: String, fullname: String, email: String, password: String, confirmPassword: String) {
            self.username = username
            self.fullname = fullname
            self.email = email
            self.password = password
            self.confirmPassword = confirmPassword
        }
    }
    
    
    /// The model to perform update requests on a user
    public struct UpdateRequestModel: Codable {
        /// Changing their username?
        public var username: String?
        /// Changing their name?
        public var fullname: String?
        /// Users email address
        public var email: String?
        /// Are we trying to make them an admin?
        public var isAdmin: Bool?
        /// Are we trying to reset the user?
        public var isReset: Bool?
        /// Is the user currently active?
        public var isActive: Bool?
        /// The users password
        public var password: String?
        /// Retype for insurance purposes
        public var confirmPassword: String?
        
        public init (
            username: String? = nil,
        fullname: String? = nil,
        email: String? = nil,
        isAdmin: Bool? = nil,
        isReset: Bool? = nil,
        isActive: Bool? = nil,
        password: String? = nil,
        confirmPassword: String? = nil
        ) {
            self.username = username
            self.fullname = fullname
            self.email = email
            self.isAdmin = isAdmin
            self.isReset = isReset
            self.isActive = isActive
            self.password = password
            self.confirmPassword = confirmPassword
        }
    }
}
//
//// MARK: - MWRequestProtocol
//
//// MARK: Create Request Model
//extension V1 {
//    /// Create request for new user
//    public struct CreateRequest: MWRequestProtocol {
//        public var path: String = "users"
//        public var urlQueryParams: [String : String] = [:]
//        public var requestType: MWRequest_HTTPType = .POST
//        public var addAuthorizationToken: Bool = true
//        
//        public var body: Encodable?
//        public var response: Decodable.Type? = nil
//        public init (body: CreateRequestModel) {
//            self.body = body
//        }
//    }
//}
//
//// MARK: Current
//extension V1 {
//    /// Who is the current user??
//    public struct CurrentUserRequest: MWRequestProtocol {
//        public var path: String = "users/current"
//        public var urlQueryParams: [String : String] = [:]
//        public var requestType: MWRequest_HTTPType = .GET
//        
//        public var body: Encodable? = nil
//        public var response: Decodable.Type? = Model.self
//        
//        public init() {}
//    }
//}
//
//// MARK: Get All Request
//extension V1 {
//    /// Get a list of all users
//    public struct GetAllRequest: MWRequestProtocol {
//        public var path: String = "users"
//        public var urlQueryParams: [String : String] = [:]
//        public var requestType: MWRequest_HTTPType = .GET
//        public var response: Decodable.Type? = [Model].self
//        
//        public init() {}
//    }
//}
//
//// MARK: Get Single Request
//extension V1 {
//    /// Get a singleuser
//    public struct GetSingleRequest: MWRequestProtocol {
//        public var path: String
//        public var urlQueryParams: [String : String] = [:]
//        public var requestType: MWRequest_HTTPType = .GET
//        public var response: Decodable.Type? = Model.self
//        
//        public init(id: UUID) {
//            self.path = "users/\(id)"
//        }
//    }
//}
//
//// MARK: Update Request
//extension V1 {
//    /// Try to update an existing user
//    public struct UpdateRequest: MWRequestProtocol {
//        public var path: String
//        public var urlQueryParams: [String : String] = [:]
//        public var requestType: MWRequest_HTTPType = .PUT
//        public var response: Decodable.Type? = Model.self
//        
//        public var body: Encodable?
//        
//        public init(id: UUID, body: UpdateRequestModel) {
//            self.path = "users/\(id)"
//            self.body = body
//        }
//    }
//}
//
//// MARK: Delete Request
//extension V1 {
//    /// Try to delete an existing user
//    public struct DeleteRequest: MWRequestProtocol {
//        public var path: String
//        public var urlQueryParams: [String : String] = [:]
//        public var requestType: MWRequest_HTTPType = .DELETE
//        
//        public var body: Encodable? = nil
//        public var response: Decodable.Type? = nil
//        
//        public init(id: UUID) {
//            self.path = "users/\(id)"
//        }
//    }
//        
//}
