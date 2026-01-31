import Foundation

public final class RequestBuilder {
    private let configuration: NetworkConfiguration
    
    public init(configuration: NetworkConfiguration) {
        self.configuration = configuration
    }
    
    public func build(from endpoint: Endpoint) throws -> URLRequest {
        // 1. Construct URL
        guard var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }
        
        // Append path (handling potential slashes)
        let basePath = components.path.trimmingCharacters(in: .init(charactersIn: "/"))
        let endpointPath = endpoint.path.trimmingCharacters(in: .init(charactersIn: "/"))
        let fullPath = basePath.isEmpty ? "/\(endpointPath)" : "/\(basePath)/\(endpointPath)"
        components.path = fullPath
        
        // Add Query Items
        if let queryItems = endpoint.queryItems {
            components.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        // 2. Create Request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // 3. Add Headers
        // Default headers
        configuration.defaultHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        // Endpoint specific headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // 4. Encode Body
        if let body = endpoint.body {
            do {
                let encoder = JSONEncoder()
                // Useful for debugging, formatting output
                // encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(body)
                request.httpBody = data
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw NetworkError.serializationError(error)
            }
        }
        
        return request
    }
}
