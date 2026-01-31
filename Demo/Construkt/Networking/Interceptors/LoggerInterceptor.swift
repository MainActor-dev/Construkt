import Foundation

public struct LoggerInterceptor: RequestInterceptor {
    public init() {}
    
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        print("🚀 [Network] Request: \(request.httpMethod ?? "UNK") \(request.url?.absoluteString ?? "Invalid URL")")
        if let headers = request.allHTTPHeaderFields {
            print("   Headers: \(headers)")
        }
        if let body = request.httpBody, let json = String(data: body, encoding: .utf8) {
            print("   Body: \(json)")
        }
        return request
    }
}
