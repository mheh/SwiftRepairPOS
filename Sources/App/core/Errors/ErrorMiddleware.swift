import Vapor
import PostgresNIO

struct ErrorResponse: Codable {
    var error: Bool
    var reason: String
    var errorCode: String?
}

extension ErrorMiddleware {
    static func `custom`(environment: Environment) -> ErrorMiddleware {
        return .init { req, error in
            let status: HTTPResponseStatus
            let reason: String
            let headers: HTTPHeaders
            let errorCode: String?
            
            switch error {
                // Custom error format
            case let appError as AppError:
                reason = appError.reason
                status = appError.status
                headers = appError.headers
                errorCode = appError.identifier
                
                
                // Error is an Abort error
            case let abort as AbortError:
                reason = abort.reason
                status = abort.status
                headers = abort.headers
                errorCode = nil
                
                
                // if not release mode, and error is debuggable, provide debug
                // info directly to the developer
            case let error as LocalizedError where !environment.isRelease:
                reason = error.localizedDescription
                status = .internalServerError
                headers = [:]
                errorCode = nil
                
                
                // Need to cast as String(reflecting: error) for debug and testing
            case let error as PSQLError:
                reason = String(reflecting: error)
                status = .internalServerError
                headers = [:]
                errorCode = nil
                break
                
                
                // not an abort error, and not debuggable or in dev mode
                // just deliver a generic 500 to avoid exposing any sensitive error info
            default:
                reason = "Something went wrong."
                status = .internalServerError
                headers = [:]
                errorCode = nil
            }
            
            // Report the error to logger.
            req.logger.report(error: error)
            
            // create a Response with appropriate status
            let response = Response(status: status, headers: headers)
            
            // attempt to serialize the error to json
            do {
                let errorResponse = ErrorResponse(error: true, reason: reason, errorCode: errorCode)
                response.body = try .init(data: JSONEncoder().encode(errorResponse))
                response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                response.body = .init(string: "Oops: \(error)")
                response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return response
        }
    }
}
