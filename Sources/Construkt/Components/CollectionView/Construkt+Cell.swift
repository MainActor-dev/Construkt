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

public protocol CellConvertible: SectionComponent {
    func asCells() -> [CellController]
}

extension CellController: CellConvertible {
    public func asCells() -> [CellController] { [self] }
}

extension Array: CellConvertible where Element == CellController {
    public func asCells() -> [CellController] { self }
}

// MARK: - Result Builder

@resultBuilder
public struct CellResultBuilder {
    public static func buildBlock() -> [CellController] {
        []
    }
    
    public static func buildBlock(_ values: CellConvertible...) -> [CellController] {
        values.flatMap { $0.asCells() }
    }
    
    public static func buildIf(_ value: CellConvertible?) -> [CellController] {
        value?.asCells() ?? []
    }
    
    public static func buildEither(first: CellConvertible) -> [CellController] {
        first.asCells()
    }
    
    public static func buildEither(second: CellConvertible) -> [CellController] {
        second.asCells()
    }
    
    public static func buildArray(_ components: [[CellController]]) -> [CellController] {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: CellConvertible?) -> [CellController] {
        component?.asCells() ?? []
    }
}

// MARK: - Cell

public struct Cell<C: UICollectionViewCell, Model>: CellConvertible {
    
    private let model: Model?
    private let id: AnyHashable
    private let configure: (C, Model) -> Void
    private var onSelect: ((Model) -> Void)?
    private var skeletonCount: Int?
    
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
    
    public func onSelect(_ handler: @escaping (Model) -> Void) -> Cell {
        var copy = self
        copy.onSelect = handler
        return copy
    }
    
    public func skeleton(count: Int) -> Cell {
        var copy = self
        copy.skeletonCount = count
        return copy
    }
    
    public func asCells() -> [CellController] {
        if let model = model {
             return [
                CellController(
                    id: id,
                    model: model,
                    registration: CellRegistration<C, Model> { cell, _, item in
                        configure(cell, item)
                    },
                    didSelect: onSelect
                )
             ]
        } else if let count = skeletonCount {
            return Skeleton<C>.create(count: count, identifier: "skeleton_\(id)")
        }
        return []
    }
}

// MARK: - Hosting Cell

public final class HostingCell<Content: View>: UICollectionViewCell {
    
    private var hostedView: UIView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
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

public extension Cell {
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
