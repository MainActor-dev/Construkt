import Foundation
import RxSwift
import RxCocoa

public class MovieViewModel {
    
    // MARK: - State
    
    /// List of movies (Popular, Top Rated, etc.) - Main List
    @Variable public private(set) var state = LoadableState<[Movie]>.initial
    
    /// Now Playing Movies (Hero Section)
    @Variable public private(set) var nowPlayingState = LoadableState<[Movie]>.initial
    
    /// Popular Movies (Popular Section)
    @Variable public private(set) var popularState = LoadableState<[Movie]>.initial
    
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
    
    public var nowPlayingMoviesObservable: Observable<[Movie]> {
        $nowPlayingState.asObservable().map { state in
            if case .loaded(let movies) = state {
                return movies
            }
            return []
        }
    }
    
    public var isNowPlayingLoadingObservable: Observable<Bool> {
        $nowPlayingState.asObservable().map { state in
            if case .initial = state { return true }
            if case .loading = state { return true }
            return false
        }
    }
    
    public var popularSectionMoviesObservable: Observable<[Movie]> {
        $popularState.asObservable().map { state in
            if case .loaded(let movies) = state {
                return movies
            }
            return []
        }
    }
    
    public var isPopularSectionLoadingObservable: Observable<Bool> {
        $popularState.asObservable().map { state in
            if case .initial = state { return true }
            if case .loading = state { return true }
            return false
        }
    }
    
    public var isEmptyObservable: Observable<Bool> {
        Observable.combineLatest(
            nowPlayingMoviesObservable,
            popularSectionMoviesObservable,
            isNowPlayingLoadingObservable,
            isPopularSectionLoadingObservable
        ).map { nowPlaying, popular, isNowPlayingLoading, isPopularLoading in
            if isNowPlayingLoading || isPopularLoading { return false }
            return nowPlaying.isEmpty && popular.isEmpty
        }
    }
    
    // MARK: - Dependencies
    
    private let service: MovieServiceProtocol
    
    // MARK: - Init
    
    public init(service: MovieServiceProtocol = MovieService()) {
        self.service = service
    }
    
    public func loadHomeData() {
        self.nowPlayingState = .loading
        self.popularState = .loading
        
        Task {
            // Simulate loading
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            // Fetch concurrently
            async let nowPlaying = service.getNowPlayingMovies(page: 1)
            async let popular = service.getPopularMovies(page: 1)
            
            do {
                let nowPlayingResult = try await nowPlaying
                let popularResult = try await popular
                
                await MainActor.run {
                    self.nowPlayingState = .loaded(nowPlayingResult.results)
                    self.popularState = .loaded(popularResult.results)
                }
            } catch {
                await MainActor.run {
                    // Start simplified handling, ideally handle individually
                    self.nowPlayingState = .error(error.localizedDescription)
                    self.popularState = .error(error.localizedDescription)
                }
            }
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
}
