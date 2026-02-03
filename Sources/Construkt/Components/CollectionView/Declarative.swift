//
//  Declarative.swift
//  Construkt
//
//  Created by User on 2026-02-02.
//

import UIKit

// MARK: - Result Builders

import RxSwift
import RxCocoa

// MARK: - Result Builders

@resultBuilder
public struct SectionResultBuilder {
    public static func buildBlock() -> Observable<[SectionController]> {
        .just([])
    }
    
    public static func buildBlock(_ components: SectionObservable...) -> Observable<[SectionController]> {
        return Observable.combineLatest(components.map { $0.asSectionObservable() })
            .map { $0.flatMap { $0 } }
    }
    
    public static func buildIf(_ value: SectionObservable?) -> Observable<[SectionController]> {
        value?.asSectionObservable() ?? .just([])
    }
    
    public static func buildEither(first: SectionObservable) -> Observable<[SectionController]> {
        first.asSectionObservable()
    }
    
    public static func buildEither(second: SectionObservable) -> Observable<[SectionController]> {
        second.asSectionObservable()
    }
    
    public static func buildArray(_ components: [SectionObservable]) -> Observable<[SectionController]> {
        Observable.combineLatest(components.map { $0.asSectionObservable() })
            .map { $0.flatMap { $0 } }
    }
}

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

// MARK: - Protocols

public protocol SectionObservable {
    func asSectionObservable() -> Observable<[SectionController]>
}

extension SectionController: SectionObservable {
    public func asSectionObservable() -> Observable<[SectionController]> { .just([self]) }
}

extension Array: SectionObservable where Element == SectionController {
    public func asSectionObservable() -> Observable<[SectionController]> { .just(self) }
}

public protocol CellConvertible {
    func asCells() -> [CellController]
}

extension CellController: CellConvertible {
    public func asCells() -> [CellController] { [self] }
}

extension Array: CellConvertible where Element == CellController {
    public func asCells() -> [CellController] { self }
}

// MARK: - Declaration Wrapper

public struct Section: SectionObservable {
    private let observable: Observable<[SectionController]>
    
    // MARK: Initializers
    
    /// Standard initializer with a builder block (Static)
    public init(
        id: SectionControllerIdentifier,
        @CellResultBuilder content: () -> [CellController]
    ) {
        let cells = content()
        let section = SectionController(identifier: id, cells: cells, layoutProvider: nil)
        self.observable = .just([section])
    }
    
    /// Static Data-binding initializer
    public init<T>(
        id: SectionControllerIdentifier,
        items: [T],
        @CellResultBuilder content: (T) -> [CellController]
    ) {
        let cells = items.flatMap { content($0) }
        let section = SectionController(identifier: id, cells: cells, layoutProvider: nil)
        self.observable = .just([section])
    }
    
    /// Reactive Binding initializer
    public init<B: RxBinding>(
        id: SectionControllerIdentifier,
        binding: B,
        @CellResultBuilder content: @escaping (B.T) -> [CellController]
    ) {
        // Map the binding value to a SectionController
        self.observable = binding.asObservable()
            .map { items in
                let cells = content(items) // content(items) returns [CellController]? No, content takes B.T
                // Wait, if B.T is [Item], then content expects [Item].
                // The block should probably be T -> [CellController] if user passes items: binding.
                
                // Let's assume content handles the conversion.
                return [SectionController(identifier: id, cells: cells, layoutProvider: nil)]
            }
    }
    
    /// Reactive Binding with element iteration helper
    public init<B: RxBinding, Element>(
        id: SectionControllerIdentifier,
        items binding: B,
        @CellResultBuilder content: @escaping (Element) -> [CellController]
    ) where B.T == [Element] {
        self.observable = binding.asObservable()
            .map { items in
                let cells = items.flatMap { content($0) }
                return [SectionController(identifier: id, cells: cells, layoutProvider: nil)]
            }
    }
    
    // MARK: Modifiers
    
    public func layout(_ handler: @escaping (String) -> NSCollectionLayoutSection?) -> Section {
        // Apply layout to the inner section controllers when they emit
        let improved = observable.map { sections in
            sections.map { section in
                var copy = section
                copy.layoutProvider = handler
                return copy
            }
        }
        return Section(observable: improved)
    }
    
    public func skeleton<C, B>(
        _ type: C.Type,
        count: Int,
        when binding: B,
        configure: ((C) -> Void)? = nil
    ) -> Section where C: UICollectionViewCell, B: RxBinding, B.T == Bool {
        
        
        let loadingObservable = binding.asObservable()
                
        let combined = Observable.combineLatest(observable, loadingObservable)
            .map { (sections, isLoading) -> [SectionController] in
                if isLoading {
                    return sections.map { section in
                         return SectionController(
                            identifier: section.identifier,
                            cells: Skeleton<C>.create(count: count, configure: configure),
                            layoutProvider: section.layoutProvider
                         )
                    }
                } else {
                    return sections
                }
            }
            
        return Section(observable: combined)
    }
    
    public func skeleton<Content: View, B: RxBinding>(
        count: Int,
        when binding: B,
        placeholder: @escaping () -> Content
    ) -> Section where B.T == Bool {
        return skeleton(HostingCell<Content>.self, count: count, when: binding) { cell in
            cell.host(placeholder())
        }
    }
    
    // Internal init for modifiers
    private init(observable: Observable<[SectionController]>) {
        self.observable = observable
    }

    // MARK: Convert
    
    public func asSectionObservable() -> Observable<[SectionController]> {
        return observable
    }
}

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

// MARK: - CollectionView Wrapper

public struct CollectionView: ModifiableView {
    
    public let modifiableView = CollectionViewWrapperView()
    
    public init(@SectionResultBuilder content: () -> Observable<[SectionController]>) {
        let sectionsObservable = content()
        
        sectionsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak modifiableView] sections in
                modifiableView?.update(sections: sections)
            })
            .disposed(by: modifiableView.rxDisposeBag)
    }
}

public class CollectionViewWrapperView: UIView, UICollectionViewDelegate {
    
    private(set) lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        cv.backgroundColor = .clear
        cv.clipsToBounds = false
        cv.delegate = self
        return cv
    }()
    
    private lazy var dataSource: CollectionDiffableDataSource = {
        return CollectionDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, index, item) in
                return item.cell(in: collectionView, at: index)
            }
        )
    }()
    
    private lazy var adapter: CellControllerAdapter = {
        return CellControllerAdapter(dataSource: dataSource)
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func update(sections: [SectionController]) {
        dataSource.display(sections)
        
        let layout = UICollectionViewCompositionalLayout { [weak self] index, _ in
            guard let self = self,
                  let sect = self.dataSource.sectionIdentifier(at: index) else { return nil }
            
            // Check if section provided via snapshot matches
            // We need to look up the section controller to find the layout provider
            if let sectionController = sections.first(where: { $0.identifier.uniqueId == sect }),
               let layout = sectionController.layoutProvider?(sect) {
                
                // Hide empty sections logic
                if self.dataSource.snapshot().numberOfItems(inSection: sectionController) == 0 {
                   layout.contentInsets = .zero
                   layout.decorationItems = []
                   layout.boundarySupplementaryItems = []
                }
                
                return layout
            }
            return nil
        }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    // MARK: - Delegate Forwarding
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        adapter.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        adapter.collectionView(collectionView, prefetchItemsAt: indexPaths)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        adapter.collectionView(collectionView, cancelPrefetchingForItemsAt: indexPaths)
    }
}
