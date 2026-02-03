//
//  Construkt+CollectionView.swift
//  Construkt
//
//  Created by User on 2026-02-03.
//

import UIKit
import RxSwift
import RxCocoa

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
        
        // Create lookup dictionary for O(1) access
        let sectionMap = Dictionary(uniqueKeysWithValues: sections.map { ($0.identifier.uniqueId, $0) })
        
        let layout = UICollectionViewCompositionalLayout { [weak self] index, _ in
            guard let self = self,
                  let sect = self.dataSource.sectionIdentifier(at: index) else { return nil }
            
            // O(1) Lookup
            if let sectionController = sectionMap[sect],
               let layout = sectionController.layoutProvider?(sect) {
                
                // Hide empty sections logic
                if self.dataSource.snapshot().numberOfItems(inSection: sectionController) == 0 {
                   layout.contentInsets = .zero
                   layout.decorationItems = []
                   layout.boundarySupplementaryItems = []
                } else {
                    // Filter hidden headers/footers
                    layout.boundarySupplementaryItems = layout.boundarySupplementaryItems.filter { item in
                        if item.elementKind == UICollectionView.elementKindSectionHeader {
                            return !(sectionController.header?.isHidden ?? false)
                        } else if item.elementKind == UICollectionView.elementKindSectionFooter {
                            return !(sectionController.footer?.isHidden ?? false)
                        }
                        return true
                    }
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
}

public extension CollectionView {
    func emptyState<B: RxBinding>(when binding: B, @ViewResultBuilder _ content: @escaping () -> ViewConvertable) -> CollectionView where B.T == Bool {
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
            .disposed(by: modifiableView.rxDisposeBag)
            
        return self
    }
}
