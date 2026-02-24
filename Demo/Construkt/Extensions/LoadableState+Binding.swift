import Foundation
import ConstruktKit

// MARK: - LoadableState ViewBinding Operators

public extension ViewBinding {
    
    /// Maps a `LoadableState<[T]>` binding to emit only the loaded items `[T]`.
    /// Emits an empty array when not in `.loaded` state.
    func mapItems<T>() -> AnyViewBinding<[T]> where Value == LoadableState<[T]> {
        return map { state in
            if case .loaded(let items) = state { return items }
            return []
        }
    }
    
    /// Maps a `LoadableState<T>` binding to emit only the loaded value `T?`.
    /// Emits `nil` when not in `.loaded` state.
    func mapValue<T>() -> AnyViewBinding<T?> where Value == LoadableState<T> {
        return map { state in
            if case .loaded(let item) = state { return item }
            return nil
        }
    }

    /// Maps a `LoadableState<T>` binding to a Boolean indicating loading state.
    /// Returns `true` for `.initial` and `.loading`, `false` otherwise.
    func mapLoading<T>() -> AnyViewBinding<Bool> where Value == LoadableState<T> {
        return map { state in
            if case .initial = state { return true }
            if case .loading = state { return true }
            return false
        }
    }
}
