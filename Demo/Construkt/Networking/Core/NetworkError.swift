import Foundation

public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case serializationError(Error)
    case requestFailed(Error)
    case invalidResponse
    case serverError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .serializationError(let error):
            return "Failed to serialize the request body: \(error.localizedDescription)"
        case .requestFailed(let error):
            return "The network request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .serverError(let statusCode, _):
            return "Server returned an error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
