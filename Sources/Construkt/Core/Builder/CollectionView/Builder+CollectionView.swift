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
import RxSwift
import RxCocoa

// MARK: - CollectionView Wrapper

/// A declarative builder component that bridges Construkt's View architecture with modern
/// `UICollectionView` APIs powered by Diffable Data Sources and Compositional Layouts.
public struct CollectionView: ModifiableView {
    
    public let modifiableView = CollectionViewWrapperView()
    
    /// Initializes a declarative collection view dynamically mapped to an Rx stream of `Section` arrays.
    public init(@SectionResultBuilder content: () -> Observable<[SectionController]>) {
        let sectionsObservable = content()
        
        sectionsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak modifiableView] sections in
                modifiableView?.update(sections: sections)
            })
            .store(in: modifiableView.cancelBag)
    }
}

/// The internal `UIView` subclass responsible for hosting the actual `UICollectionView` and
/// maintaining the Diffable Data Source mappings.
public class CollectionViewWrapperView: UIView, UICollectionViewDelegate {
    
    public private(set) lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        cv.backgroundColor = .clear
        cv.clipsToBounds = false
        cv.delegate = self
        return cv
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor("#FFFFFF") // Default to white for dark mode app
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var dataSource: CollectionDiffableDataSource = {
        let ds = CollectionDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, index, item) in
                return item.cell(in: collectionView, at: index)
            }
        )
        
        ds.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            // Identify section
            guard let self = self,
                  let identifier = self.dataSource.sectionIdentifier(at: indexPath.section),
                  let section = self.dataSource.snapshot().sectionIdentifiers.first(where: { $0.identifier.uniqueId == identifier })
            else { return nil }
            
            if kind == UICollectionView.elementKindSectionHeader, let header = section.header {
                 return header.dequeue(collectionView, indexPath)
            } else if kind == UICollectionView.elementKindSectionFooter, let footer = section.footer {
                 return footer.dequeue(collectionView, indexPath)
            }
            
            return nil
        }
        
        return ds
    }()
    
    private lazy var adapter: CellControllerAdapter = {
        return CellControllerAdapter(dataSource: dataSource)
    }()
    
    /// Cached section map for O(1) layout provider lookups
    private var currentSectionMap: [String: SectionController] = [:]
    
    /// Tracks whether the compositional layout has been set up
    private var hasInitializedLayout = false
    
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
        // Update the cached section map before applying data
        currentSectionMap = Dictionary(
            uniqueKeysWithValues: sections.map { ($0.identifier.uniqueId, $0) }
        )
        
        if !hasInitializedLayout {
            // Create layout once — the provider closure reads from currentSectionMap
            let layout = UICollectionViewCompositionalLayout { [weak self] index, _ in
                guard let self = self,
                      let sect = self.dataSource.sectionIdentifier(at: index) else { return nil }
                
                // O(1) Lookup
                if let sectionController = self.currentSectionMap[sect],
                   let layout = sectionController.layoutProvider?(sect) {
                    
                    // Hide empty sections logic
                    if self.dataSource.snapshot().numberOfItems(inSection: sectionController) == 0 {
                       layout.contentInsets = .zero
                       layout.decorationItems = []
                       layout.boundarySupplementaryItems = []
                    } else {
                        // Filter hidden or missing headers/footers
                        layout.boundarySupplementaryItems = layout.boundarySupplementaryItems.filter { item in
                            if item.elementKind == UICollectionView.elementKindSectionHeader {
                                return sectionController.header != nil && !(sectionController.header?.isHidden ?? false)
                            } else if item.elementKind == UICollectionView.elementKindSectionFooter {
                                return sectionController.footer != nil && !(sectionController.footer?.isHidden ?? false)
                            }
                            return true
                        }
                    }
                    
                    return layout
                }
                return nil
            }
            
            collectionView.setCollectionViewLayout(layout, animated: false)
            hasInitializedLayout = true
        }
        
        // Apply data changes (smart incremental diffing)
        dataSource.display(sections)
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
    
    // MARK: - Empty State
    
    public var emptyStateProvider: (() -> UIView)?
    private var emptyStateView: UIView?
    
    internal func updateEmptyState(show: Bool) {
        if show {
            if emptyStateView == nil {
                guard let provider = emptyStateProvider else { return }
                let view = provider()
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
                NSLayoutConstraint.activate([
                    view.centerXAnchor.constraint(equalTo: centerXAnchor),
                    view.centerYAnchor.constraint(equalTo: centerYAnchor),
                    view.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
                    view.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
                    view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 20),
                    view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20)
                ])
                emptyStateView = view
            }
            emptyStateView?.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyStateView?.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    // MARK: - Refresh Control
    
    private var onRefresh: (() -> Void)?
    
    internal func setupRefreshControl(action: @escaping () -> Void) {
        self.onRefresh = action
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        onRefresh?()
    }
    
    internal func setRefreshing(_ isRefreshing: Bool) {
        if isRefreshing {
            // Only begin refreshing if we are on screen to avoid "offscreen beginRefreshing" warning
            if window != nil {
                if !(collectionView.refreshControl?.isRefreshing ?? false) {
                    collectionView.refreshControl?.beginRefreshing()
                }
            }
        } else {
            if collectionView.refreshControl?.isRefreshing ?? false {
                collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Scroll Observation
    
    public var onScroll: ((UIScrollView) -> Void)?
    public var onWillBeginDragging: ((UIScrollView) -> Void)?
    public var onDidEndDragging: ((UIScrollView, Bool) -> Void)?
    public var onDidEndDecelerating: ((UIScrollView) -> Void)?
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScroll?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        onWillBeginDragging?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        onDidEndDragging?(scrollView, decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        onDidEndDecelerating?(scrollView)
    }
}

public extension CollectionView {
    /// Dynamically swaps the internal collection view display for a custom empty state `View` when the
    /// bounding Rx stream resolves to `true`.
    func emptyState<B: ViewBinding>(when binding: B, @ViewResultBuilder _ content: @escaping () -> ViewConvertable) -> CollectionView where B.Value == Bool {
        let views = content().asViews()
        let view = VStackView(views)
            .alignment(.center)
            .build()
        // Set the view provider (could be just the view instance)
        modifiableView.emptyStateProvider = { view }
        
        // Subscribe to binding
        binding.asObservable()
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak modifiableView] show in
                modifiableView?.updateEmptyState(show: show)
            })
            .store(in: modifiableView.cancelBag)
            
        return self
    }
    

}

public extension ModifiableView where Base: CollectionViewWrapperView {
    
    /// Adjusts the internal scroll view's content inset.
    @discardableResult
    func contentInset(
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) -> ViewModifier<Base> {
        modifiableView.collectionView.contentInset = .init(top: top, left: left, bottom: bottom, right: right)
        return ViewModifier(modifiableView)
    }
    
    /// Installs a `UIRefreshControl` directly into the collection view, binding its active state
    /// to a specific Rx boolean stream.
    @discardableResult
    func onRefresh<B: ViewBinding>(_ binding: B, action: @escaping () -> Void) -> ViewModifier<Base> where B.Value == Bool {
        modifiableView.setupRefreshControl(action: action)
        
        binding.asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak modifiableView] isRefreshing in
                modifiableView?.setRefreshing(isRefreshing)
            })
            .store(in: modifiableView.cancelBag)
            
        return ViewModifier(modifiableView)
    }
    
    /// Forwarded `UIScrollViewDelegate` scroll event.
    @discardableResult
    func onScroll(_ handler: @escaping (UIScrollView) -> Void) -> ViewModifier<Base> {
        modifiableView.onScroll = handler
        return ViewModifier(modifiableView)
    }
    
    /// Forwarded `UIScrollViewDelegate` scroll view delegate will begin dragging.
    @discardableResult
    func onWillBeginDragging(_ handler: @escaping (UIScrollView) -> Void) -> ViewModifier<Base> {
        modifiableView.onWillBeginDragging = handler
        return ViewModifier(modifiableView)
    }
    
    /// Forwarded `UIScrollViewDelegate` did end dragging.
    @discardableResult
    func onDidEndDragging(_ handler: @escaping (UIScrollView, Bool) -> Void) -> ViewModifier<Base> {
        modifiableView.onDidEndDragging = handler
        return ViewModifier(modifiableView)
    }
    
    /// Forwarded `UIScrollViewDelegate` did end decelerating.
    @discardableResult
    func onDidEndDecelerating(_ handler: @escaping (UIScrollView) -> Void) -> ViewModifier<Base> {
        modifiableView.onDidEndDecelerating = handler
        return ViewModifier(modifiableView)
    }
}
