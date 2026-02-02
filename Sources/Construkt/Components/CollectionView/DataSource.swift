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

public typealias CellRegistration<Cell: UICollectionViewCell, Item> = UICollectionView.CellRegistration<Cell, Item>
public typealias CollectionSnapshot = NSDiffableDataSourceSnapshot<SectionController, CellController>
public typealias CollectionDiffableDataSource = UICollectionViewDiffableDataSource<SectionController, CellController>

public extension CollectionDiffableDataSource {
    func updateSections(
        _ sections: [SectionController],
        beforeItem: CellController? = nil,
        completion: (() -> Void)? = nil,
        animated: Bool = false
    ) {
        var snapshot = snapshot()
        
        defer {
            applySnapshot(snapshot, completion: completion)
        }
                
        let displayedSections = snapshot.sectionIdentifiers
        let newSections = sections.filter { !displayedSections.contains($0) }
        newSections.forEach { newSection in
            snapshot.appendSections([newSection])
            snapshot.appendItems(newSection.cells, toSection: newSection)
        }
        
        let existingSections = displayedSections.filter { sections.contains($0) }
        
        zip(existingSections, sections).forEach { old, new in
            guard old.identifier.uniqueId == new.identifier.uniqueId else { return  }
            
            let newItems = new.cells
            let oldItems = snapshot.itemIdentifiers(inSection: old)
            var filtered = newItems.filter { !oldItems.contains($0) }
            
            /// Delete items if needed
            let toBeDeletedItems = oldItems.filter { !newItems.contains($0) }
            snapshot.deleteItems(toBeDeletedItems)
            
            if let beforeItem = beforeItem {
                if snapshot.itemIdentifiers.contains(beforeItem) {
                    snapshot.insertItems(filtered, beforeItem: beforeItem)
                } else {
                    filtered.removeAll(where: { $0 == beforeItem })
                    snapshot.appendItems(filtered, toSection: old)
                    snapshot.appendItems([beforeItem], toSection: old)
                }
            } else {
                snapshot.appendItems(filtered, toSection: new)
            }
        }
    }
    
    func display(_ sections: [SectionController], completion: (() -> Void)? = nil) {
        var snapshot = CollectionSnapshot()
        sections.forEach { section in
            if !section.cells.isEmpty {
                snapshot.appendSections([section])
                snapshot.appendItems(section.cells, toSection: section)
            }
        }
        applySnapshotUsingReloadData(snapshot, completion: completion)
    }
    
    func appendItems(
        _ items: [CellController],
        into identifier: SectionControllerIdentifier,
        animated: Bool = false
    ) {
        let displayedSections = snapshot().sectionIdentifiers
        let section = displayedSections.section(identifier: identifier)
        
        var snapshot = snapshot()
        snapshot.appendItems(items, toSection: section)
        applySnapshot(snapshot, animated: animated)
    }
    
    func deleteItems(_ items: [CellController]) {
        var snapshot = snapshot()
        snapshot.deleteItems(items)
        applySnapshot(snapshot, animated: true)
    }
    
    func section(at index: Int) -> SectionController? {
        return snapshot().sectionIdentifiers[safe: index]
    }
    
    func sectionIdentifier(at index: Int) -> String? {
        return snapshot().sectionIdentifiers[safe: index]?.identifier.uniqueId
    }
    
    private func applySnapshot(
        _  snapshot: CollectionSnapshot,
        animated: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        if #available(iOS 15.0, *) {
            applySnapshotUsingReloadData(snapshot, completion: completion)
        } else {
            apply(snapshot, animatingDifferences: animated)
        }
    }
}
