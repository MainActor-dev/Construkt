//
//  👨‍💻 Created by @thatswiftdev on 04/02/26.
//
//  © 2026, https://github.com/thatswiftdev. All rights reserved.
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
//

import UIKit

// MARK: - Protocols

/// A protocol that identifies types capable of resolving into a collection of `CellConfig`s.
public protocol AnyCellConvertible: AnySectionComponent {
    /// Converts the conforming type into an array of cell controllers.
    func asCells() -> [CellConfig]
}

extension CellConfig: AnyCellConvertible {
    public func asCells() -> [CellConfig] { [self] }
}

extension Array: AnyCellConvertible where Element == CellConfig {
    public func asCells() -> [CellConfig] { self }
}

// MARK: - Result Builder

/// A result builder that enables a declarative, SwiftUI-like syntax for generating arrays of `CellConfig`s.
@resultBuilder
public struct AnyCellResultBuilder {
    public static func buildBlock() -> [CellConfig] {
        []
    }
    
    public static func buildBlock(_ values: AnyCellConvertible...) -> [CellConfig] {
        values.flatMap { $0.asCells() }
    }
    
    public static func buildIf(_ value: AnyCellConvertible?) -> [CellConfig] {
        value?.asCells() ?? []
    }
    
    public static func buildEither(first: AnyCellConvertible) -> [CellConfig] {
        first.asCells()
    }
    
    public static func buildEither(second: AnyCellConvertible) -> [CellConfig] {
        second.asCells()
    }
    
    public static func buildArray(_ components: [[CellConfig]]) -> [CellConfig] {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: AnyCellConvertible?) -> [CellConfig] {
        component?.asCells() ?? []
    }
}

// MARK: - Cell

/// A lightweight declarative wrapper for generating a `CellConfig` inline.
///
/// It allows configuring cells with closures directly within a section block, eliminating the need
/// for standard Delegate/DataSource boilerplate.
public struct AnyCell<C: UICollectionViewCell, Model>: AnyCellConvertible {
    
    private let model: Model?
    private let id: AnyHashable
    private let configure: (C, Model) -> Void
    private var onSelect: ((Model) -> Void)?
    private var shimmerCount: Int?
    
    public init(
        _ model: Model?,
        id: AnyHashable? = nil,
        configure: @escaping (C, Model) -> Void
    ) {
        self.model = model
        // If Model is Identifiable, use that, else use provided ID, else UUID
        if let id = id {
            self.id = id
        } else {
            self.id = UUID()
        }
        self.configure = configure
    }
    
    // MARK: Modifiers
    
    /// Attaches an imperative selection handler to the cell, triggered when the user taps it.
    ///
    /// - Parameter handler: A closure providing the cell's underlying generic `Model`.
    /// - Returns: A mutated copy of the `Cell` with the selection attached.
    public func onSelect(_ handler: @escaping (Model) -> Void) -> AnyCell {
        var copy = self
        copy.onSelect = handler
        return copy
    }
    
    /// Specifies how many animated shimmer copies of this cell should be shown when in a loading state.
    public func shimmer(count: Int) -> AnyCell {
        var copy = self
        copy.shimmerCount = count
        return copy
    }
    
    public func asCells() -> [CellConfig] {
        if let model = model {
            let wrapper = CellConfigurationWrapper(model: model, configure: configure)
            let registration = RegistrationCache.register(cell: C.self, model: Model.self)
            
             return [
                CellConfig(
                    id: id,
                    model: wrapper,
                    registration: registration,
                    contentHash: (model as? AnyHashable) ?? AnyHashable(UUID()),
                    didSelect: { wrapper in
                        onSelect?(wrapper.model)
                    }
                )
             ]
        } else if let count = shimmerCount {
            return _Shimmer<C>.create(count: count, identifier: "shimmer_\(id)")
        }
        return []
    }
}

// MARK: - Registration Caching

struct CellConfigurationWrapper<C: UICollectionViewCell, M>: CellContentWrapper {
    let model: M
    let configure: (C, M) -> Void
    
    var originalModel: Any { model }
}

class RegistrationCache {
    static var cache = [String: Any]()
    
    static func register<C: UICollectionViewCell, M>(cell: C.Type, model: M.Type) -> UICollectionView.CellRegistration<C, CellConfigurationWrapper<C, M>> {
        let key = "\(String(describing: C.self))_\(String(describing: M.self))"
        
        if let existing = cache[key] as? UICollectionView.CellRegistration<C, CellConfigurationWrapper<C, M>> {
            return existing
        }
        
        let registration = UICollectionView.CellRegistration<C, CellConfigurationWrapper<C, M>> { cell, _, wrapper in
            wrapper.configure(cell, wrapper.model)
        }
        
        cache[key] = registration
        return registration
    }
}

// MARK: - Hosting Cell

/// A specialized `UICollectionViewCell` designed to dynamically host an underlying declarative `View` hierarchy.
public final class HostingCell<Content: View>: UICollectionViewCell {
    
    private var hostedView: UIView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.isUserInteractionEnabled = true
    }
    
    /// Embeds a freshly built `View` hierarchy into the cell's content view.
    public func host(_ content: Content) {
        // Simple hosting strategy: Rebuild logic.
        // Optimally we would update, but View protocol implies build() -> UIView
        hostedView?.removeFromSuperview()
        
        let view = content.build()
        contentView.addSubview(view) // Wrapper view provided by Cell? No, direct embed.
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        hostedView = view
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        hostedView?.removeFromSuperview()
        hostedView = nil
    }
}

public extension AnyCell {
    /// Initializer for hosting a ViewBuilder content directly
    init<Content: View>(
        _ model: Model?,
        id: AnyHashable? = nil,
        content: @escaping (Model) -> Content
    ) where C == HostingCell<Content> {
        self.init(model, id: id) { cell, item in
            cell.host(content(item))
        }
    }
}
