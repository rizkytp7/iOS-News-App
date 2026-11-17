import Foundation

/// Typed errors surfaced from the networking layer.
enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case unauthorized          // 401
    case forbidden             // 403
    case notFound              // 404
    case rateLimited           // 429
    case serverError(Int)      // 5xx
    case decodingError(String)
    case noInternet
    case timeout
    case unknown(String)

    // MARK: - User-facing description

    var userMessage: String {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .unauthorized:
            return "Invalid API key. Please check your configuration."
        case .forbidden:
            return "Access denied. Your API key may not have permission for this request."
        case .notFound:
            return "The requested resource was not found."
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .decodingError:
            return "The app received unexpected data from the server."
        case .noInternet:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "The request timed out. Please try again."
        case .unknown(let message):
            return message.isEmpty ? "An unexpected error occurred." : message
        }
    }
}
