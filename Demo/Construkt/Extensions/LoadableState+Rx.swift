import Foundation
import RxSwift

// MARK: - LoadableState Extensions

extension ObservableType {
    
    /// Maps a LoadableState<[T]> observable to the list of items [T].
    /// Returns empty list if not loaded.
    public func mapItems<T>() -> Observable<[T]> where Element == LoadableState<[T]> {
        return map { state in
            if case .loaded(let items) = state { return items }
            return []
        }
    }
    
    /// Maps a LoadableState<T> observable to the item T?.
    /// Returns nil if not loaded.
    public func mapValue<T>() -> Observable<T?> where Element == LoadableState<T> {
        return map { state in
            if case .loaded(let item) = state { return item }
            return nil
        }
    }

    /// Maps a LoadableState<T> observable to a Boolean indicating if it is loading (initial or loading).
    public func mapLoading<T>() -> Observable<Bool> where Element == LoadableState<T> {
        return map { state in
            if case .initial = state { return true }
            if case .loading = state { return true }
            return false
        }
    }
}
