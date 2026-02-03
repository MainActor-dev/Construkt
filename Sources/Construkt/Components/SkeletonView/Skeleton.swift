import UIKit

public enum Skeleton<Cell: UICollectionViewCell> {
    public static func create(
        count: Int = 1,
        identifier: String = UUID().uuidString,
        configure: ((Cell) -> Void)? = nil
    ) -> [CellController] {
        guard count >= 1 else { fatalError("Need at least 1 cell controller") }
        return (1...count).map { idx in
            create(id: identifier + "_SHIMMER_" + String(idx), configure: configure)
        }
    }
    
    public static func create(id: AnyHashable, configure: ((Cell) -> Void)? = nil) -> CellController {
        return CellController(
            id: id,
            model: (),
            registration: CellRegistration<Cell, Void> { cell, indexPath, item in
                configure?(cell)
                cell.layoutIfNeeded()
                cell.setAnimatedSkeletonView(true)
            }
        )
    }
}
