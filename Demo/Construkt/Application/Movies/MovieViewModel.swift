import Foundation
import RxSwift
import RxCocoa

public class MovieViewModel {
    
    // MARK: - State
    public struct HomeData: Equatable {
        public internal(set) var nowPlaying: LoadableState<[Movie]> = .initial
        public internal(set) var popular: LoadableState<[Movie]> = .initial
        public internal(set) var upcoming: LoadableState<[Movie]> = .initial
        public internal(set) var topRated: LoadableState<[Movie]> = .initial
        public internal(set) var genres: LoadableState<[Genre]> = .initial
        
        public var isAnyLoading: Bool {
            nowPlaying.isLoading || popular.isLoading || upcoming.isLoading || topRated.isLoading || genres.isLoading
        }
        
        public var isEmpty: Bool {
            (nowPlaying.value?.isEmpty == true) &&
            (popular.value?.isEmpty == true) &&
            (upcoming.value?.isEmpty == true) &&
            (topRated.value?.isEmpty == true) &&
            (genres.value?.isEmpty == true)
        }
    }

    @Variable private var state = HomeData()
    @Variable private var selectedMovie: MovieDetail? = nil 
    
    // MARK: - Observables
    private var homeData: Observable<HomeData> { $state.asObservable() }
    public var movieDetails: Observable<MovieDetail?> { $selectedMovie.asObservable() }
    
    // Now Playing
    public var nowPlayingMovies: Observable<[Movie]> {
        homeData.map { $0.nowPlaying }.mapItems()
    }
    public var isNowPlayingLoading: Observable<Bool> {
        homeData.map { $0.nowPlaying }.mapLoading()
    }
    
    // Popular
    public var popularSectionMovies: Observable<[Movie]> {
        homeData.map { $0.popular }.mapItems()
    }
    public var isPopularSectionLoading: Observable<Bool> {
        homeData.map { $0.popular }.mapLoading()
    }
    
    // Upcoming
    public var upcomingMovies: Observable<[Movie]> {
        homeData.map { $0.upcoming }.mapItems()
    }
    public var isUpcomingLoading: Observable<Bool> {
        homeData.map { $0.upcoming }.mapLoading()
    }
    
    // Top-Rated
    public var topRatedMovies: Observable<[Movie]> {
        homeData.map { $0.topRated }.mapItems()
    }
    public var isTopRatedLoading: Observable<Bool> { homeData.map { $0.topRated }.mapLoading() }
    
    // Genres
    public var genres: Observable<[Genre]> { homeData.map { $0.genres }.mapItems() }
    public var isLoadingGenres: Observable<Bool> { homeData.map { $0.genres }.mapLoading() }
    
    public var isEmptyObservable: Observable<Bool> {
        return homeData.map { !$0.isAnyLoading && $0.isEmpty }
    }
    
    // MARK: - Dependencies
    private let service: MovieServiceProtocol
    
    // MARK: - Init
    
    public init(service: MovieServiceProtocol = MovieService()) {
        self.service = service
    }
    
    public func loadHomeData() {
        state.nowPlaying = .loading
        state.popular = .loading
        state.upcoming = .loading
        state.topRated = .loading
        state.genres = .loading
        
        // Fetch concurrently and update incrementally
        Task {
            // Simulate loading latency for demo purposes
             try? await Task.sleep(nanoseconds: 1_000_000_000)
            
           fetchNowPlaying()
           fetchPopular()
           fetchUpcoming()
           fetchTopRated()
           fetchGenres()
        }
    }
    
    private func fetchNowPlaying() {
        Task {
            do {
                let result = try await service.getNowPlayingMovies(page: 1)
                await MainActor.run {
                    self.state.nowPlaying = .loaded(result.results)
                }
            } catch {
                await MainActor.run { self.state.nowPlaying = .loaded([]) }
            }
        }
    }

    private func fetchPopular() {
        Task {
            do {
                let result = try await service.getPopularMovies(page: 1)
                await MainActor.run {
                    self.state.popular = .loaded(result.results)
                }
            } catch {
                await MainActor.run { self.state.popular = .loaded([]) }
            }
        }
    }
    
    private func fetchUpcoming() {
        Task {
            do {
                let result = try await service.getPopularMovies(page: 2)
                await MainActor.run {
                    self.state.upcoming = .loaded(result.results)
                }
            } catch {
                await MainActor.run { self.state.upcoming = .loaded([]) }
            }
        }
    }
    
    private func fetchTopRated() {
        Task {
            do {
                let result = try await service.getTopRatedMovies(page: 1)
                await MainActor.run {
                    self.state.topRated = .loaded(result.results)
                }
            } catch {
                await MainActor.run { self.state.topRated = .loaded([]) }
            }
        }
    }
    
    private func fetchGenres() {
        Task {
            do {
                let result = try await service.getGenres()
                await MainActor.run {
                    self.state.genres = .loaded(result.genres)
                }
            } catch {
                await MainActor.run { self.state.genres = .loaded([]) }
            }
        }
    }
    
    public func selectMovie(_ movie: Movie) {        
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
