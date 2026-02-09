import Foundation
import RxSwift
import RxCocoa

public class MovieListViewModel {
    
    // MARK: - State
    @Variable public private(set) var movies: [Movie] = []
    @Variable public var selectedGenre: Genre? = nil
    @Variable public private(set) var isLoading: Bool = false
    @Variable public private(set) var error: String? = nil
    
    public struct FilterItem: Identifiable, Equatable {
        public let id: Int
        public let title: String
        public let isSelected: Bool
        public let genre: Genre?
    }
    
    // MARK: - Observables
    public var moviesObservable: Observable<[Movie]> { $movies.asObservable() }
    
    public var filterItemsObservable: Observable<[FilterItem]> {
        $selectedGenre.asObservable().map { selected in
            let allItem = FilterItem(id: -1, title: "All", isSelected: selected == nil, genre: nil)
            let items = self.genres.map { genre in
                FilterItem(
                    id: genre.id,
                    title: genre.name,
                    isSelected: selected?.id == genre.id,
                    genre: genre
                )
            }
            return [allItem] + items
        }
    }
    
    public var selectedGenreObservable: Observable<Genre?> { $selectedGenre.asObservable() }
    
    // MARK: - Properties
    public let title: String
    public let genres: [Genre] // Available filters
    private let sectionType: HomeSection
    private let service: MovieServiceProtocol
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var isFetching: Bool = false
    
    // MARK: - Init
    init(
        title: String,
        sectionType: HomeSection,
        genres: [Genre],
        service: MovieServiceProtocol = MovieService()
    ) {
        self.title = title
        self.sectionType = sectionType
        // Prepend "All" to genres if not present? 
        // Actually UI can handle "All" as a separate case or nil selectedGenre.
        self.genres = genres
        self.service = service
        
        // Initial Fetch
        fetchMovies(reset: true)
    }
    
    // MARK: - Actions
    public func selectGenre(_ genre: Genre?) {
        guard selectedGenre != genre else { return }
        selectedGenre = genre
        fetchMovies(reset: true)
    }
    
    public func loadMore() {
        guard !isFetching, currentPage < totalPages else { return }
        fetchMovies(reset: false)
    }
    
    public func refresh() {
        fetchMovies(reset: true)
    }
    
    // MARK: - Private
    private func fetchMovies(reset: Bool) {
        if reset {
            currentPage = 1
            movies = []
            isLoading = true
        }
        
        isFetching = true
        
        Task {
            do {
                let response: MovieResponse
                
                if let genre = selectedGenre {
                    // If genre is selected, use discover endpoint (defaults to popularity desc)
                    // Note: This overrides sectionType specific logic for now, effectively verifying "Popular" + Genre.
                    response = try await service.discoverMovies(page: currentPage, genreId: genre.id)
                } else {
                    // "All" selected -> Use section specific endpoint
                    switch sectionType {
                    case .popular:
                        response = try await service.getPopularMovies(page: currentPage)
                    case .upcoming:
                        // Upcoming usually maps to "Popular" with page 2 in HomeViewModel for demo, 
                        // but ideally should use getNowPlaying or specific upcoming endpoint if available.
                        // For now we reuse what HomeViewModel did or use getPopularMovies as fallback.
                         response = try await service.getNowPlayingMovies(page: currentPage) // Approximation
                    case .topRated:
                        response = try await service.getTopRatedMovies(page: currentPage)
                    case .hero, .categories:
                         response = try await service.getNowPlayingMovies(page: currentPage)
                    }
                }
                
                await MainActor.run {
                    if reset {
                        self.movies = response.results
                    } else {
                        self.movies.append(contentsOf: response.results)
                    }
                    self.totalPages = response.totalPages
                    self.currentPage += 1
                    self.isLoading = false
                    self.isFetching = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                    self.isFetching = false
                }
            }
        }
    }
}
