import Foundation
import ConstruktKit

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
    @Variable private var casts: LoadableState<[Cast]> = .initial
    @Variable private var isDetailsLoading: Bool = false
    
    // MARK: - Bindings
    public var movieDetails: AnyViewBinding<MovieDetail?> { $selectedMovie.map { $0 } }
    public var movieCasts: AnyViewBinding<[Cast]> { $casts.mapItems() }
    public var isCastsLoading: AnyViewBinding<Bool> { $casts.mapLoading() }
    public var isLoadingDetails: AnyViewBinding<Bool> { $isDetailsLoading.map { $0 } }
    
    public func selectMovie(_ movie: Movie) {        
        self.isDetailsLoading = true
        Task {
            self.fetchMovieCasts(id: movie.id)
            do {
                try? await Task.sleep(nanoseconds: 500_000_000)
                let detailedMovie = try await service.getMovieDetails(id: movie.id)
                await MainActor.run {
                    self.selectedMovie = detailedMovie
                    self.isDetailsLoading = false
                }
            } catch {
                print("Failed to fetch details for movie \(movie.id): \(error)")
                await MainActor.run {
                    self.isDetailsLoading = false
                }
            }
        }
    }
    
    // Now Playing
    public var nowPlayingMovies: AnyViewBinding<[Movie]> {
        $state.map { $0.nowPlaying }.mapItems()
    }
    public var isNowPlayingLoading: AnyViewBinding<Bool> {
        $state.map { $0.nowPlaying }.mapLoading()
    }
    
    // Popular
    public var popularSectionMovies: AnyViewBinding<[Movie]> {
        $state.map { $0.popular }.mapItems()
    }
    public var isPopularSectionLoading: AnyViewBinding<Bool> {
        $state.map { $0.popular }.mapLoading()
    }
    
    // Upcoming
    public var upcomingMovies: AnyViewBinding<[Movie]> {
        $state.map { $0.upcoming }.mapItems()
    }
    public var isUpcomingLoading: AnyViewBinding<Bool> {
        $state.map { $0.upcoming }.mapLoading()
    }
    
    // Top-Rated
    public var topRatedMovies: AnyViewBinding<[Movie]> {
        $state.map { $0.topRated }.mapItems()
    }
    public var isTopRatedLoading: AnyViewBinding<Bool> { $state.map { $0.topRated }.mapLoading() }
    
    // Genres
    public var genres: AnyViewBinding<[Genre]> { $state.map { $0.genres }.mapItems() }
    public var isLoadingGenres: AnyViewBinding<Bool> { $state.map { $0.genres }.mapLoading() }
    
    public var isEmptyObservable: AnyViewBinding<Bool> {
        return $state.map { !$0.isAnyLoading && $0.isEmpty }
    }
    
    public var currentGenres: [Genre] {
        state.genres.value ?? []
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
        
        Task {
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
                await MainActor.run { self.state.genres = .error(error.localizedDescription) }
            }
        }
    }

    public func fetchMovieCasts(id: Int) {
        self.casts = .loading
        Task {
            do {
                let result = try await service.getMovieCredits(id: id)
                await MainActor.run {
                    self.casts = .loaded(result.cast)
                }
            } catch {
                await MainActor.run {
                    self.casts = .error(error.localizedDescription)
                }
            }
        }
    }
    

}
