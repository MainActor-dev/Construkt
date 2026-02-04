import Foundation
import RxSwift
import RxCocoa

public class MovieViewModel {
    
    // MARK: - State
    
    public struct HomeData: Equatable {
        public internal(set) var nowPlaying: [Movie] = []
        public internal(set) var popular: [Movie] = []
        public internal(set) var upcoming: [Movie] = []
        public internal(set) var topRated: [Movie] = []
        public internal(set) var genres: [Genre] = []
        
        public var isEmpty: Bool {
            nowPlaying.isEmpty && popular.isEmpty && upcoming.isEmpty && topRated.isEmpty && genres.isEmpty
        }
    }

    @Variable private var state = LoadableState<HomeData>.initial
    @Variable private var selectedMovie: Movie? = nil // Kept separate as it's a detail view state

    // MARK: - Observables
    
    // Unified Loading State
    // Must emit (even empty) during loading to trigger combineLatest in skeleton modifier
    private var homeData: Observable<HomeData> { $state.asObservable().mapValue().map { $0 ?? HomeData() } }
    
    public var nowPlayingMovies: Observable<[Movie]> { homeData.map { $0.nowPlaying } }
    public var isNowPlayingLoading: Observable<Bool> { $state.asObservable().mapLoading() }
    
    public var popularSectionMovies: Observable<[Movie]> { homeData.map { $0.popular } }
    public var isPopularSectionLoading: Observable<Bool> { $state.asObservable().mapLoading() }
    
    public var upcomingMovies: Observable<[Movie]> { homeData.map { $0.upcoming } }
    public var isUpcomingLoading: Observable<Bool> { $state.asObservable().mapLoading() }
    
    public var topRatedMovies: Observable<[Movie]> { homeData.map { $0.topRated } }
    public var isTopRatedLoading: Observable<Bool> { $state.asObservable().mapLoading() }
    
    public var genres: Observable<[Genre]> { homeData.map { $0.genres } }
    public var isLoadingGenres: Observable<Bool> { $state.asObservable().mapLoading() }
    
    public var isEmptyObservable: Observable<Bool> {
        Observable.combineLatest(
            $state.asObservable().mapLoading(),
            homeData.map { $0.isEmpty }
        ).map { isLoading, isEmpty in
            return !isLoading && isEmpty
        }
    }
    
    // MARK: - Dependencies
    
    private let service: MovieServiceProtocol
    
    // MARK: - Init
    
    public init(service: MovieServiceProtocol = MovieService()) {
        self.service = service
    }
    
    public func loadHomeData() {
        state = .loading
        
        Task {
            // Simulate loading
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            // Fetch concurrently
            async let nowPlaying = service.getNowPlayingMovies(page: 1)
            async let popular = service.getPopularMovies(page: 1)
            async let upcoming = service.getPopularMovies(page: 2)
            async let topRated = service.getTopRatedMovies(page: 1)
            async let genres = service.getGenres()
            
            do {
                let nowPlayingResult = try await nowPlaying
                let popularResult = try await popular
                let upcomingResult = try await upcoming
                let topRatedResult = try await topRated
                let genresResult = try await genres
                
                await MainActor.run {
                    var data = HomeData()
                    data.nowPlaying = nowPlayingResult.results
                    data.popular = popularResult.results
                    data.upcoming = upcomingResult.results
                    data.topRated = topRatedResult.results
                    data.genres = genresResult.genres
                    
                    self.state = .loaded(data)
                }
            } catch {
                await MainActor.run {
                    self.state = .loaded(HomeData()) // Or .error(error.localizedDescription)
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
            }
        }
    }
}
