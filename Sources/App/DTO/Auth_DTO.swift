//
//  Auth_DTO.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/6/24.
//
import Foundation

/// Models for authentication with MWServer
public struct Auth_DTO {}


// MARK: - Token Model
extension Auth_DTO {
    /// JWT Token returned from server
    public struct Token: Codable {
        /// The access token
        public var accessToken: String
        /// Access token expiration date
        public var accessTokenExpiration: String
        /// The refresh token
        public var refreshToken: String
        /// Refresh token expiration date
        public var refreshTokenExpiration: String
        
        public init(accessToken: String, accessExpiration: String, refreshToken: String, refreshExpiration: String) {
            self.accessToken = accessToken
            self.accessTokenExpiration = accessExpiration
            self.refreshToken = refreshToken
            self.refreshTokenExpiration = refreshExpiration
        }
    }
}

// MARK: - DTO models
extension Auth_DTO {
    /// Login Request
    public struct Login /*: MWRequestProtocol*/ {
//        public var path: String = "auth/login"
//        public var urlQueryParams: [String : String] = [:]
//        public var addAuthorizationToken: Bool = false
//        public var requestType: MWRequest_HTTPType = .POST
//
//        public var body: Encodable?
//        public var response: Decodable.Type? = Response.self
//
//
//        public init(body: Body) {
//            self.body = body
//        }
        
        //
        // MARK: Login Request/Response
        //
        
        /// Login request to server
        public struct Body: Codable {
            /// Email, validated as format xx@xx.xx
            public var email: String
            /// Password, validated as !.empty
            public var password: String
            
            public init(email: String, password: String) {
                self.email = email
                self.password = password
            }
        }
        
        /// Login response from server
        public struct Response: Codable {
            /// Token information
            public var token: Token
            /// User who has access to this token
            public var user: User_DTO.V1.Model
            
            public init(token: Token, user: User_DTO.V1.Model) {
                self.token = token
                self.user = user
            }
        }
    }
}

// MARK: - Refresh Request
extension Auth_DTO {
    /// Refresh Token Request
    public struct Refresh: DTORequestProtocol {
        public var path: String =                          "auth/refresh"
        public var urlQueryParams: [String : String] = [:]
        public var requestType: DTORequest_HTTPType =       .POST
        public var addAuthorizationToken: Bool =           false
        
        public var body: Encodable?
        public var response: Decodable.Type? =             Response.self
        
        public init (body: Body) {
            self.body = body
        }
        
        /// Refresh token request to server
        public struct Body: Codable {
            /// Refresh token to refresh
            public var refreshToken: String
            public var deviceID: UUID
            
            public init(refreshToken: String, deviceID: UUID) {
                self.refreshToken = refreshToken
                self.deviceID = deviceID
            }
        }
        
        /// Refresh token response from server
        public typealias Response = Token
    }
}
