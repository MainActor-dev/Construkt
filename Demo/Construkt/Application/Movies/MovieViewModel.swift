import Foundation
import RxSwift
import RxCocoa

public class MovieViewModel {
    
    // MARK: - State
    
    /// List of movies (Popular, Top Rated, etc.)
    @Variable public private(set) var state = LoadableState<[Movie]>.initial
    
    /// Detail of the selected movie
    @Variable public private(set) var selectedMovie: Movie? = nil
    
    /// Title describing the current list
    @Variable public private(set) var title: String = "Popular Movies"

    // MARK: - Computed Properties
    
    public var popularMovies: [Movie] {
        if case .loaded(let movies) = state {
            return movies
        }
        return []
    }

    public var popularMoviesObservable: Observable<[Movie]> {
        $state.asObservable().map { state in
            if case .loaded(let movies) = state {
                return movies
            }
            return []
        }
    }
    
    public var heroMovie: Movie? {
        return popularMovies.first
    }

    public var isLoadingObservable: Observable<Bool> {
        $state.asObservable()
            .map { state in
                if case .initial = state { return true }
                if case .loading = state { return true }
                return false
            }
    }
    
    // MARK: - Dependencies
    
    private let service: MovieServiceProtocol
    
    // MARK: - Init
    
    public init(service: MovieServiceProtocol = MovieService()) {
        self.service = service
    }
    
    // MARK: - Actions
    
    public func loadPopularMovies() {
        fetchMovies(title: "Popular Movies") { [weak self] in
            try await self?.service.getPopularMovies(page: 1)
        }
    }
    
    public func loadTopRatedMovies() {
        fetchMovies(title: "Top Rated Movies") { [weak self] in
            try await self?.service.getTopRatedMovies(page: 1)
        }
    }
    
    public func loadNowPlayingMovies() {
        fetchMovies(title: "Now Playing") { [weak self] in
            try await self?.service.getNowPlayingMovies(page: 1)
        }
    }
    
    public func selectMovie(_ movie: Movie) {
        // Optimistic selection
        self.selectedMovie = movie
        
        // Fetch full details
        Task {
            do {
                let detailedMovie = try await service.getMovieDetails(id: movie.id)
                await MainActor.run {
                    self.selectedMovie = detailedMovie
                }
            } catch {
                print("Failed to fetch details for movie \(movie.id): \(error)")
                // We keep the optimistically selected movie, maybe show an error toast in a real app
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func fetchMovies(title: String, action: @escaping () async throws -> MovieResponse?) {
        self.title = title
        self.state = .loading
        
        Task {
            /// Simulate loading for 2 seconds
            try await Task.sleep(nanoseconds: 2_000_000_000)
            do {
                if let response = try await action() {
                    let movies = response.results
                    await MainActor.run {
                        if movies.isEmpty {
                            self.state = .empty("No movies found.")
                        } else {
                            self.state = .loaded(movies)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
}
