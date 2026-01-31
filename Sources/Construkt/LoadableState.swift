import Foundation

/// A generic state enum for loading data.
/// Automatically handles "production grade" features like Stable Cache Keys and Smart Updates.
public enum LoadableState<T: Equatable>: Equatable, EquivalentState, CacheKeyProviding {
    case initial
    case loading
    case loaded(T)
    case empty(String)
    case error(String)
    
    // MARK: - CacheKeyProviding
    /// Stable key for caching views. Ignores the associated data in .loaded case.
    public var cacheKey: String {
        switch self {
        case .initial: return "initial"
        case .loading: return "loading"
        case .loaded: return "loaded"
        case .empty: return "empty"
        case .error: return "error"
        }
    }
    
    // MARK: - EquivalentState
    /// Smart check to determine if we should Swap (Rebuild) or Update (Reload)
    public func isModification(of previous: Any) -> Bool {
        guard let previous = previous as? LoadableState<T> else { return false }
        
        switch (self, previous) {
        // If we are already loaded and get new data, it's just an update!
        // This preserves scroll position/focus in the active view.
        case (.loaded, .loaded): return true
        default: return false
        }
    }
}
