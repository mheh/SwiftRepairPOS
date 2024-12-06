//
//  Token.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/5/24.
//

import Vapor
import JWT

/// The `access token` model sent to the frontend.  Not stored in the database.
struct Payload: JWTPayload, Authenticatable {
    /// User ID
    var userID: UUID
    
    var username: String
    
    var fullName: String
    
    var email: String
    
    var isAdmin: Bool
    
    /// When this access token expires
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
    
    /// Create a new `access token` for the provided user
    init(user: User) throws {
        self.userID =       try user.requireID()
        self.username =     user.username
        self.fullName =     user.fullName
        self.email =        user.email
        self.isAdmin =      user.isAdmin
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(CONSTANT_TOKEN_ACCESS_LIFETIME))
    }
}

struct UserAuthenticator: AsyncJWTAuthenticator {
    func authenticate(jwt: Payload, for request: Vapor.Request) async throws {
        request.auth.login(jwt)
    }
}
