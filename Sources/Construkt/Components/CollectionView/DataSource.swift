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
    func display(_ sections: [SectionController], completion: (() -> Void)? = nil) {
        let currentSnapshot = snapshot()
        let isFirstLoad = currentSnapshot.numberOfSections == 0
        
        // Build new snapshot
        var newSnapshot = CollectionSnapshot()
        sections.forEach { section in
            if !section.cells.isEmpty {
                newSnapshot.appendSections([section])
                newSnapshot.appendItems(section.cells, toSection: section)
            }
        }
        
        if isFirstLoad {
            // First load: use reloadData for instant display (no animation needed)
            applySnapshotUsingReloadData(newSnapshot, completion: completion)
        } else {
            // Build content map from current snapshot before applying structural changes
            let oldItemMap = buildContentMap(from: currentSnapshot)
            let oldIds = Set(currentSnapshot.itemIdentifiers.map { $0.id })
            
            // Apply structural diff (inserts/deletes/moves) without animation
            apply(newSnapshot, animatingDifferences: false) { [weak self] in
                guard let self = self else {
                    completion?()
                    return
                }
                
                // Find items that need reconfiguration:
                // - nil contentHash: can't verify content unchanged → reconfigure
                // - different contentHash: content confirmed changed → reconfigure
                // - same non-nil contentHash: content confirmed unchanged → skip
                let itemsToReconfigure = newSnapshot.itemIdentifiers.filter { item in
                    // Only reconfigure items that existed before (new items already handled by apply)
                    guard oldIds.contains(item.id) else { return false }
                    
                    guard let newHash = item.contentHash else {
                        // No contentHash — can't verify unchanged, must reconfigure
                        return true
                    }
                    guard let oldHash = oldItemMap[item.id] else {
                        // Item existed but had no hash before — reconfigure
                        return true
                    }
                    // Both have hashes — only reconfigure if different
                    return oldHash != newHash
                }
                
                if !itemsToReconfigure.isEmpty {
                    var reconfigSnapshot = self.snapshot()
                    // Filter to only items that actually exist in the current snapshot
                    // (guards against race conditions from overlapping display() calls)
                    let currentIds = Set(reconfigSnapshot.itemIdentifiers.map { $0.id })
                    let safeItems = itemsToReconfigure.filter { currentIds.contains($0.id) }
                    
                    if !safeItems.isEmpty {
                        // Use reloadItems (not reconfigureItems) because each CellController
                        // creates a new CellRegistration per emission — reconfigureItems
                        // requires the same registration, which we can't guarantee.
                        reconfigSnapshot.reloadItems(safeItems)
                        // Enable animations to preserve orthogonal scroll positions
                        self.apply(reconfigSnapshot, animatingDifferences: false)
                    }
                }
                
                completion?()
            }
        }
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
        apply(snapshot, animatingDifferences: animated)
    }
    
    func deleteItems(_ items: [CellController]) {
        var snapshot = snapshot()
        snapshot.deleteItems(items)
        apply(snapshot, animatingDifferences: true)
    }
    
    func section(at index: Int) -> SectionController? {
        return snapshot().sectionIdentifiers[safe: index]
    }
    
    func sectionIdentifier(at index: Int) -> String? {
        return snapshot().sectionIdentifiers[safe: index]?.identifier.uniqueId
    }
    
    // MARK: - Private Helpers
    
    /// Builds a lookup of [CellController.id → contentHash] from the current snapshot
    private func buildContentMap(
        from snapshot: CollectionSnapshot
    ) -> [AnyHashable: AnyHashable] {
        var map: [AnyHashable: AnyHashable] = [:]
        for item in snapshot.itemIdentifiers {
            if let hash = item.contentHash {
                map[item.id] = hash
            }
        }
        return map
    }
}
