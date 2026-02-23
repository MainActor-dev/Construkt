import Foundation

public class MovieListViewModel {
    
    // MARK: - State
    @Variable public private(set) var movies: [Movie] = []
    @Variable public var selectedGenre: Genre? = nil
    @Variable public private(set) var isLoading: Bool = false
    @Variable public private(set) var error: String? = nil
    
    public struct FilterItem: Identifiable, Equatable, Hashable {
        public let id: Int
        public let title: String
        public let isSelected: Bool
        public let genre: Genre?
    }
    
    // MARK: - Bindings
    public var moviesObservable: AnyViewBinding<[Movie]> { $movies.map { $0 } }
    
    public var filterItemsObservable: AnyViewBinding<[FilterItem]> {
        $selectedGenre.map { selected in
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
        
    // MARK: - Properties
    public let title: String
    public let genres: [Genre] // Available filters
    
    private let sectionType: HomeSection
    private let service: MovieServiceProtocol
    
    // Pagination State
    @Variable public private(set) var paginationState = ListPaginationModel()
    
    // MARK: - Init
    init(
        title: String,
        sectionType: HomeSection,
        genres: [Genre],
        selectedGenre: Genre?,
        service: MovieServiceProtocol = MovieService()
    ) {
        self.title = title
        self.sectionType = sectionType
        self.genres = genres
        self.selectedGenre = selectedGenre
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
        guard !paginationState.isPaginating, !paginationState.isLastPage else { return }
        fetchMovies(reset: false)
    }
    
    public func refresh() {
        fetchMovies(reset: true)
    }
    
    // MARK: - Private
    private func fetchMovies(reset: Bool) {
        if reset {
            movies = []
            isLoading = true
            paginationState = ListPaginationModel(currentPage: 1, isPaginating: false, isLastPage: false)
        } else {
             paginationState = ListPaginationModel(
                currentPage: paginationState.currentPage,
                isPaginating: true,
                isLastPage: paginationState.isLastPage
             )
        }
        
        Task {
            do {
                let currentPage = paginationState.currentPage
                let response: MovieResponse
                
                if let genre = selectedGenre {
                    response = try await service.discoverMovies(page: currentPage, genreId: genre.id)
                } else {
                    switch sectionType {
                    case .popular:
                        response = try await service.getPopularMovies(page: currentPage)
                    case .upcoming:
                         response = try await service.getNowPlayingMovies(page: currentPage)
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
                    
                    let newPage = currentPage + 1
                    let isLastPage = newPage > response.totalPages
                    
                    self.paginationState = ListPaginationModel(
                        currentPage: newPage,
                        isPaginating: false,
                        isLastPage: isLastPage
                    )
                    
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    
                    self.paginationState = ListPaginationModel(
                        currentPage: self.paginationState.currentPage,
                        isPaginating: false,
                        isLastPage: self.paginationState.isLastPage
                    )
                    
                    self.isLoading = false
                }
            }
        }
    }
}
