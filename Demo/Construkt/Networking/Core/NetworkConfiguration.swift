import Foundation

public struct NetworkConfiguration {
    public let baseURL: URL
    public let defaultHeaders: [String: String]
    
    public init(baseURL: URL, defaultHeaders: [String: String] = [:]) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
    }
    
    // Default configuration for the Demo
    public static var `default`: NetworkConfiguration {
        // Placeholder URL, will be overridden by specific endpoints or staging configs
        return NetworkConfiguration(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
    }
}
