import Foundation

public protocol RequestInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest
    // Future: func retry(...)
}

// Default implementation
public extension RequestInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        return request
    }
}
