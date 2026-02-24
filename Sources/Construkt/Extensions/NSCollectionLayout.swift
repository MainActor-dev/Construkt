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

extension NSCollectionLayoutItem {
    /// Generates an item that occupies the entire width and height of its parent container.
    public static func withEntireSize() -> NSCollectionLayoutItem {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        return NSCollectionLayoutItem(layoutSize: itemSize)
    }
    
    public static func entireWidth(withHeight height: NSCollectionLayoutDimension) -> NSCollectionLayoutItem {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
        )
        return NSCollectionLayoutItem(layoutSize: itemSize)
    }
}

extension NSCollectionLayoutGroup {
    // MARK: - Vertical Scroll
    /// Creates a vertical layout group scaling the specified width and height.
    public static func vertically(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        insets: NSDirectionalEdgeInsets = .zero
    ) -> NSCollectionLayoutGroup {
        let item = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: width,
            heightDimension: height
        ))
        let groupSize = NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = insets
        return group
    }
    
    public static func vertically(
        entireWidthWithHeight height: NSCollectionLayoutDimension,
        insets: NSDirectionalEdgeInsets = .zero
    ) -> NSCollectionLayoutGroup {
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: height)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = insets
        return group
    }
    
    // MARK: - Horizontal Scroll
    public static func horizontally(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        insets: NSDirectionalEdgeInsets = .zero
    ) -> NSCollectionLayoutGroup {
        let item = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: width,
            heightDimension: height
        ))
        let groupSize = NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = insets
        return group
    }
    
    public static func horizontally(
        entireWidthWithHeight height: NSCollectionLayoutDimension,
        insets: NSDirectionalEdgeInsets = .zero
    ) -> NSCollectionLayoutGroup {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: height)
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: height)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = insets
        return group
    }
}

extension NSCollectionLayoutSection {
    public static func layout(
        group: NSCollectionLayoutGroup,
        spacing: CGFloat = 0,
        insets: NSDirectionalEdgeInsets = .zero,
        decorationItems: [NSCollectionLayoutDecorationItem] = [],
        supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = [],
        scrolling: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
        invalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler? = nil
    ) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = insets
        section.decorationItems = decorationItems
        section.boundarySupplementaryItems = supplementaryItems
        if let scrolling { section.orthogonalScrollingBehavior = scrolling }
        if let invalidationHandler { section.visibleItemsInvalidationHandler = invalidationHandler }
        return section
    }
}

extension NSCollectionLayoutBoundarySupplementaryItem {
    public static func header(
        height: NSCollectionLayoutDimension,
        isSticky: Bool = false
    ) -> NSCollectionLayoutBoundarySupplementaryItem {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .entireWidth(withHeight: height),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.pinToVisibleBounds = isSticky
        return header
    }
    
    public static func footer(
        height: NSCollectionLayoutDimension,
        isSticky: Bool = false
    ) -> NSCollectionLayoutBoundarySupplementaryItem {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .entireWidth(withHeight: height),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        header.pinToVisibleBounds = isSticky
        return header
    }
}

extension NSCollectionLayoutDecorationItem {
    public static func background(insets: NSDirectionalEdgeInsets = .zero) -> NSCollectionLayoutDecorationItem {
        let background = NSCollectionLayoutDecorationItem.background(elementKind: "background")
        background.contentInsets = insets
        return background
    }
}

extension NSCollectionLayoutSize {
    public static func entireWidth(withHeight height: NSCollectionLayoutDimension) -> NSCollectionLayoutSize {
        return NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
        )
    }
    
    public static func withEntireSize() -> NSCollectionLayoutSize {
        return NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
    }
}

extension NSDirectionalEdgeInsets {
    public init(v: CGFloat, h: CGFloat) {
        self.init(top: v, leading: h, bottom: v, trailing: h)
    }
}
