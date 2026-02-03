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
}
