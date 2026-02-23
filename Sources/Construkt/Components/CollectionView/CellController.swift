//
//  👨‍💻 Created by @thatswiftdev on 26/09/25.
//
//  © 2025, https://github.com/thatswiftdev. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

public protocol CellContentWrapper {
    var originalModel: Any { get }
}

public enum CellControllerState: Equatable {
    public typealias TotalSkeleton = Int
    case loading(TotalSkeleton)
    case loaded
}

/// A type-erased wrapper that encapsulates everything required to dequeue, configure, and
/// interact with a `UICollectionViewCell` within the Construkt collection architecture.
public struct CellController: Hashable {
    
    public let id: AnyHashable
    public let model: Any
    public let contentHash: AnyHashable?
    private let makeCell: (UICollectionView, IndexPath) -> UICollectionViewCell
    private let onSelect: (() -> Void)?
    private let onPrefetch: (() -> Void)?
    private let onCancelPrefetch: (() -> Void)?

    /// Initializes a `CellController` mapping a specific `UICollectionViewCell` subclass to its backing `Model`.
    /// - Parameters:
    ///   - id: A unique identifier for diffable data source hashing.
    ///   - model: The underlying data driving the cell.
    ///   - registration: The `UICollectionView.CellRegistration` dictating the cell's initialization/dequeueing mechanism.
    ///   - contentHash: An optional hash forcing cell reloads when the state changes.
    ///   - didSelect: A closure executed when the constructed cell is tapped.
    ///   - prefetch: A closure executed to begin prefetching data for the cell.
    ///   - cancelPrefetch: A closure executed to halt prefetching data for the cell.
    public init<Cell: UICollectionViewCell, Model>(
        id: AnyHashable = UUID(),
        model: Model,
        registration: UICollectionView.CellRegistration<Cell, Model>,
        contentHash: AnyHashable? = nil,
        didSelect: ((Model) -> Void)? = nil,
        prefetch: ((Model) -> Void)? = nil,
        cancelPrefetch: ((Model) -> Void)? = nil
    ) {
        self.id = id
        self.model = model
        self.contentHash = contentHash
        self.makeCell = { collectionView, indexPath in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: model
            )
        }
        self.onSelect = didSelect.map {
            handler in { handler(model) }
        }
        self.onPrefetch = prefetch.map {
            handler in { handler(model) }
        }
        self.onCancelPrefetch = cancelPrefetch.map {
            handler in { handler(model) }
        }
    }
    
    /// Convenience initializer for creating a dummy controller for lookup by ID.
    /// This controller will trap if used for display.
    public init(id: AnyHashable) {
        self.id = id
        self.model = ()
        self.contentHash = nil
        self.makeCell = { _, _ in fatalError("CellController initialized with 'init(id:)' is for lookup only and cannot be used for display.") }
        self.onSelect = nil
        self.onPrefetch = nil
        self.onCancelPrefetch = nil
    }
    
    // Internal helper for usage by onSelect modifier
    internal init(
        id: AnyHashable,
        model: Any,
        contentHash: AnyHashable?,
        makeCell: @escaping (UICollectionView, IndexPath) -> UICollectionViewCell,
        onSelect: (() -> Void)?,
        onPrefetch: (() -> Void)?,
        onCancelPrefetch: (() -> Void)?
    ) {
        self.id = id
        self.model = model
        self.contentHash = contentHash
        self.makeCell = makeCell
        self.onSelect = onSelect
        self.onPrefetch = onPrefetch
        self.onCancelPrefetch = onCancelPrefetch
    }
    
    public func withSelection(_ handler: @escaping () -> Void) -> CellController {
        // Chain with existing execution if needed, or just replace?
        // Usually modifiers replace or append. Let's append to existing to be safe.
        let current = self.onSelect
        let newHandler: () -> Void = {
            current?()
            handler()
        }
        
        return CellController(
            id: id,
            model: model,
            contentHash: contentHash,
            makeCell: makeCell,
            onSelect: newHandler,
            onPrefetch: onPrefetch,
            onCancelPrefetch: onCancelPrefetch
        )
    }

    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public func cell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        makeCell(collectionView, indexPath)
    }
    
    public func didSelect() {
        onSelect?()
    }
    
    public func prefetch() {
        onPrefetch?()
    }

    public func cancelPrefetch() {
        onCancelPrefetch?()
    }
}
