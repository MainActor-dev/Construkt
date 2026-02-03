//
//  SupplementaryController.swift
//  Construkt
//
//  Created by User on 2026-02-03.
//

import UIKit

public struct SupplementaryController {
    let elementKind: String
    let dequeue: (UICollectionView, IndexPath) -> UICollectionReusableView
    var isHidden: Bool = false
    
    public init<ViewType: UICollectionReusableView>(
        elementKind: String,
        viewType: ViewType.Type,
        configure: @escaping (ViewType) -> Void
    ) {
        self.elementKind = elementKind
        let registration = UICollectionView.SupplementaryRegistration<ViewType>(elementKind: elementKind) { view, _, _ in
            configure(view)
        }
        self.dequeue = { collectionView, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
        }
    }
}
