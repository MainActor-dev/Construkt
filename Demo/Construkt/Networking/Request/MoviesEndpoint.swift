import Foundation
import ConstruktKit

public enum MoviesEndpoint: Endpoint {
    case getPopularMovies(page: Int)
    case getTopRated(page: Int)
    case getNowPlaying(page: Int)
    case getMovieDetails(id: Int)
    case getMovieCredits(id: Int)
    case getGenres
    case discover(page: Int, genreId: Int?)
    case search(query: String, page: Int)
    
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
        case .getMovieCredits(let id):
            return "/movie/\(id)/credits"
        case .getGenres:
            return "/genre/movie/list"
        case .discover:
            return "/discover/movie"
        case .search:
            return "/search/movie"
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
        case .getMovieDetails:
            return ["append_to_response": "credits,similar"]
        case .getMovieCredits:
            return nil
        case .getGenres:
            return nil
        case .discover(let page, let genreId):
            var params = ["page": String(page), "sort_by": "popularity.desc"]
            if let genreId = genreId {
                params["with_genres"] = String(genreId)
            }
            return params
        case .search(let query, let page):
            return ["query": query, "page": String(page), "include_adult": "false"]
        }
    }
}
