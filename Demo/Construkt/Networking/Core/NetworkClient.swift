import Foundation
import ConstruktKit

public protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

public actor NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let requestBuilder: RequestBuilder
    private var interceptors: [RequestInterceptor]
    
    public init(configuration: NetworkConfiguration = .default,
                session: URLSession = .shared,
                interceptors: [RequestInterceptor] = []) {
        self.session = session
        self.requestBuilder = RequestBuilder(configuration: configuration)
        self.interceptors = interceptors
        
        // Ensure Logger is present if debugging, or let generic interceptors handle it.
        // For this demo, we can just append if not present or rely on injection.
    }
    
    public func addInterceptor(_ interceptor: RequestInterceptor) {
        interceptors.append(interceptor)
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // 1. Build Request
        var request = try requestBuilder.build(from: endpoint)
        
        // 2. Run Interceptors (Adapt)
        for interceptor in interceptors {
            request = try await interceptor.adapt(request)
        }
        
        // 3. Execute
        let (data, response) = try await session.data(for: request)
        
        // 4. Validate Response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
        }
        
        // 5. Decode
        do {
            let decoder = JSONDecoder()
            // Optional: decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        } catch {
            print("❌ [Network] Decoding Error: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
}
