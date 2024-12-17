import Vapor

enum RefreshTokenError: AppError {
    /// The token or user was not found during lookup
    case refreshTokenOrUserNotFound
    /// The token has expired
    case refreshTokenHasExpired
}

extension RefreshTokenError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .refreshTokenHasExpired:
            return .notFound
        case .refreshTokenOrUserNotFound:
            return .notFound
        }
    }
    
    var reason: String {
        switch self {
        case .refreshTokenHasExpired:
            return "Refresh token has expired"
        case .refreshTokenOrUserNotFound:
            return "User or refresh token was not found."
        }
    }
    
    var identifier: String {
        switch self {
        case .refreshTokenOrUserNotFound:
            return "refreshtoken_notfound"
        case .refreshTokenHasExpired:
            return "refreshtoken_expired"
        }
    }
}
