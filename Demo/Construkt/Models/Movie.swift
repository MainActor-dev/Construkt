import Foundation

public struct Movie: Decodable, Identifiable, Equatable {
    public let id: Int
    public let title: String
    public let overview: String
    public let releaseDate: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
    }
    
    public var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    public var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
    }
    
    public static var placeholder: Movie {
        Movie(
            id: 0,
            title: "Loading Movie Title",
            overview: "Loading Description",
            releaseDate: "2024-01-01",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 0.0
        )
    }
}

public struct MovieResponse: Decodable {
    public let page: Int
    public let results: [Movie]
    public let totalPages: Int
    public let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
