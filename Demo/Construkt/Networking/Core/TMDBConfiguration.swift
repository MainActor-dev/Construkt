import Foundation

public struct TMDBConfiguration {
    public static let baseURL = URL(string: "https://api.themoviedb.org/3")!
    
    // MARK: - API Key
    // Please replace the string below with your actual TMDB API Key.
    public static let apiKey = "8df8d91448f1224d5a8ad39cffdcbc41"
    
    public static var defaultHeaders: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
