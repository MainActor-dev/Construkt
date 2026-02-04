import Foundation
import RxSwift
import RxCocoa

public class MovieViewModel {
    
    // MARK: - State

    @Variable private var nowPlayingState = LoadableState<[Movie]>.initial
    @Variable private var genresState = LoadableState<[Genre]>.initial
    @Variable private var popularState = LoadableState<[Movie]>.initial
    @Variable private var upcomingState = LoadableState<[Movie]>.initial
    @Variable private var topRatedState = LoadableState<[Movie]>.initial
    @Variable private var selectedMovie: Movie? = nil

    
    // MARK: - Observables
    public var nowPlayingMovies: Observable<[Movie]> { $nowPlayingState.asObservable().mapItems() }
    public var isNowPlayingLoading: Observable<Bool> { $nowPlayingState.asObservable().mapLoading() }
    
    public var popularSectionMovies: Observable<[Movie]> { $popularState.asObservable().mapItems() }
    public var isPopularSectionLoading: Observable<Bool> { $popularState.asObservable().mapLoading() }
    
    public var upcomingMovies: Observable<[Movie]> { $upcomingState.asObservable().mapItems() }
    public var isUpcomingLoading: Observable<Bool> { $upcomingState.asObservable().mapLoading() }
    
    public var topRatedMovies: Observable<[Movie]> { $topRatedState.asObservable().mapItems() }
    public var isTopRatedLoading: Observable<Bool> { $topRatedState.asObservable().mapLoading() }
    
    public var genres: Observable<[Genre]> { $genresState.asObservable().mapItems() }
    public var isLoadingGenres: Observable<Bool> { $genresState.asObservable().mapLoading() }
    
    public var isEmptyObservable: Observable<Bool> {
        Observable.combineLatest(
            nowPlayingMovies,
            genres,
            popularSectionMovies,
            isNowPlayingLoading,
            isPopularSectionLoading
        ).map { nowPlaying, popular, genres, isNowPlayingLoading, isPopularLoading in
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
        setLoading()
        
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
                    let heroMovies = nowPlayingResult.results.isEmpty ? popularResult.results : nowPlayingResult.results
                    self.nowPlayingState = .loaded(heroMovies)
                    self.popularState = .loaded(popularResult.results)
                    self.upcomingState = .loaded(upcomingResult.results)
                    self.topRatedState = .loaded(topRatedResult.results)
                    self.genresState = .loaded(genresResult.genres)
                }
            } catch {
                await MainActor.run {
                    self.setEmpty()
                }
            }
        }
    }
    
    private func setLoading() {
        nowPlayingState = .loading
        popularState = .loading
        upcomingState = .loading
        topRatedState = .loading
        genresState = .loading
    }
    
    private func setEmpty() {
        nowPlayingState = .loaded([])
        popularState = .loaded([])
        upcomingState = .loaded([])
        topRatedState = .loaded([])
        genresState = .loaded([])
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
