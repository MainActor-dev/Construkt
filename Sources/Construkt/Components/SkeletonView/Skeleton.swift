import UIKit

enum Skeleton<Cell: UICollectionViewCell> {
    static func create(
        count: Int = 1,
        identifier: String = UUID().uuidString
    ) -> [CellController] {
        guard count >= 1 else { fatalError("Need at least 1 cell controller") }
        return (1...count).map { idx in
            create(id: identifier + "_SHIMMER_" + String(idx))
        }
    }
    
    static func create(id: AnyHashable) -> CellController {
        return CellController(
            id: id,
            model: (),
            registration: CellRegistration<Cell, Void> { cell, indexPath, item in
                cell.setAnimatedSkeletonView(true)
            }
        )
    }
}
