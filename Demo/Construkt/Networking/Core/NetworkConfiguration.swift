import Foundation
import ConstruktKit

public struct NetworkConfiguration {
    public let baseURL: URL
    public let defaultHeaders: [String: String]
    
    public init(baseURL: URL, defaultHeaders: [String: String] = [:]) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
    }
    
    // Default configuration for the Demo
    public static var `default`: NetworkConfiguration {
        return NetworkConfiguration(baseURL: URL(string: "https://api.themoviedb.org/3")!)
    }
}
