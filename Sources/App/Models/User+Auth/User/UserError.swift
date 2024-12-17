import Vapor

enum UserError: AppError {
    
    // Login Route
    case passwordsDontMatch
    case emailAlreadyExists
    case invalidEmailOrPassword
    
    // Database lookup
    case userNotFound
    
    // Model booleans
    case userNotAdmin
    case userNotActive
    case userNotReset
    case userIsReset
    
}

extension UserError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
            
            // Login route
        case .passwordsDontMatch:
            return .badRequest
        case .emailAlreadyExists:
            return .badRequest
        case .invalidEmailOrPassword:
            return .badRequest
            
            // Database lookup
        case .userNotFound:
            return .notFound
            
            // Model booleans
        case .userNotAdmin:
            return .unauthorized
        case .userNotActive:
            return .unauthorized
        case .userNotReset:
            return .unauthorized
        case .userIsReset:
            return .unauthorized
        }
    }
    
    var reason: String {
        switch self {
            
            // Login route
        case .passwordsDontMatch:
            return "Passwords did not match."
        case .emailAlreadyExists:
            return "A user with that email already exists."
        case .invalidEmailOrPassword:
            return "Email or password was incorrect."
            
            // Database lookup
        case .userNotFound:
            return "User was not found."
            
            // Model booleans
        case .userNotAdmin:
            return "User is not an administrator."
        case .userNotActive:
            return "User is not active."
        case .userNotReset:
            return "User is not reset."
        case .userIsReset:
            return "User is reset."
        }
    }
    
    var identifier: String {
        switch self {
            
            // Login route
        case .passwordsDontMatch:
            return "passwords_dont_match"
        case .emailAlreadyExists:
            return "email_already_exists"
        case .invalidEmailOrPassword:
            return "invalid_email_or_password"
            
            // Database lookup
        case .userNotFound:
            return "user_not_found"
            
            // Model booleans
        case .userNotAdmin:
            return "user_not_admin"
        case .userNotActive:
            return "user_not_active"
        case .userNotReset:
            return "user_not_reset"
        case .userIsReset:
            return "user_is_reset"
        }
    }
}

