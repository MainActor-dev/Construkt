import Foundation
import ConstruktKit

public protocol MovieServiceProtocol {
    func getPopularMovies(page: Int) async throws -> MovieResponse
    func getTopRatedMovies(page: Int) async throws -> MovieResponse
    func getNowPlayingMovies(page: Int) async throws -> MovieResponse
    func getMovieDetails(id: Int) async throws -> MovieDetail
    func getMovieCredits(id: Int) async throws -> CreditsResponse
    func getGenres() async throws -> GenreResponse
    func discoverMovies(page: Int, genreId: Int?) async throws -> MovieResponse
}

public class MovieService: MovieServiceProtocol {
    private let client: NetworkClient
    
    public init(client: NetworkClient = .init(
        configuration: NetworkConfiguration(baseURL: TMDBConfiguration.baseURL),
        interceptors: [TMDBRequestInterceptor(), LoggerInterceptor()])
    ) {
        self.client = client
    }
    
    public func getPopularMovies(page: Int = 1) async throws -> MovieResponse {
        return try await client.request(MoviesEndpoint.getPopularMovies(page: page))
    }
    
    public func getTopRatedMovies(page: Int = 1) async throws -> MovieResponse {
        return try await client.request(MoviesEndpoint.getTopRated(page: page))
    }
    
    public func getNowPlayingMovies(page: Int = 1) async throws -> MovieResponse {
        return try await client.request(MoviesEndpoint.getNowPlaying(page: page))
    }
    
    public func getMovieDetails(id: Int) async throws -> MovieDetail {
        return try await client.request(MoviesEndpoint.getMovieDetails(id: id))
    }
    
    public func getMovieCredits(id: Int) async throws -> CreditsResponse {
        return try await client.request(MoviesEndpoint.getMovieCredits(id: id))
    }
    
    public func getGenres() async throws -> GenreResponse {
        return try await client.request(MoviesEndpoint.getGenres)
    }
    
    public func discoverMovies(page: Int, genreId: Int?) async throws -> MovieResponse {
        return try await client.request(MoviesEndpoint.discover(page: page, genreId: genreId))
    }
}
