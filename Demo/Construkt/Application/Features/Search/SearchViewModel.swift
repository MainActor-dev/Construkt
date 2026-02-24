import Foundation
import ConstruktKit

public class SearchViewModel {
    
    // MARK: - State
    @Variable public var searchQuery: String = ""
    @Variable public var searchResults: LoadableState<[Movie]> = .initial
    
    // MARK: - Bindings
    public var moviesObservable: AnyViewBinding<[Movie]> {
        $searchResults.mapItems()
    }
    
    public var isLoadingObservable: AnyViewBinding<Bool> {
        $searchResults.map {
            if case .loading = $0 { return true }
            return false
        }
    }
    
    public var isEmptyObservable: AnyViewBinding<Bool> {
        $searchResults.map { !$0.isLoading && $0.value?.isEmpty == true && !self.searchQuery.isEmpty }
    }
    
    public var isInitialObservable: AnyViewBinding<Bool> {
        $searchResults.map {
            if case .initial = $0 { return true }
            return false
        }
    }
    
    // MARK: - Dependencies
    private let service: MovieServiceProtocol
    private let cancelBag = CancelBag()
    
    // MARK: - Init
    public init(service: MovieServiceProtocol = MovieService()) {
        self.service = service
        
        $searchQuery
            .debounce(for: 0.5, on: .main)
            .observe { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Actions
    private func performSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            searchResults = .initial
            return
        }
        
        searchResults = .loading
        
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            do {
                let result = try await service.searchMovies(query: trimmed, page: 1)
                await MainActor.run {
                    self.searchResults = .loaded(result.results)
                }
            } catch {
                await MainActor.run {
                    self.searchResults = .error(error.localizedDescription)
                }
            }
        }
    }
}
