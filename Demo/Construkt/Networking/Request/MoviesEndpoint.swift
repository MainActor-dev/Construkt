import Foundation

public enum MoviesEndpoint: Endpoint {
    case getPopularMovies(page: Int)
    case getTopRated(page: Int)
    case getNowPlaying(page: Int)
    case getMovieDetails(id: Int)
    case getGenres
    
    public var path: String {
        switch self {
        case .getPopularMovies:
            return "/movie/popular"
        case .getTopRated:
            return "/movie/top_rated"
        case .getNowPlaying:
            return "/movie/now_playing"
        case .getMovieDetails(let id):
            return "/movie/\(id)"
        case .getGenres:
            return "/genre/movie/list"
        }
    }
    
    public var method: HTTPMethod {
        return .get
    }
    
    public var queryItems: [String: String]? {
        switch self {
        case .getPopularMovies(let page),
             .getTopRated(let page),
             .getNowPlaying(let page):
            return ["page": String(page)]
        case .getMovieDetails, .getGenres:
            return nil
        }
    }
}
