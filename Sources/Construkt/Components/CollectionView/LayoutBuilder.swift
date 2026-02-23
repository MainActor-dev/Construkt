import UIKit

/// A declarative result builder enabling programmatic assembly of `NSCollectionLayoutSection`s.
///
/// Under the hood, this builder automatically wraps an `NSCollectionLayoutGroup` or 
/// `NSCollectionLayoutItem` into a section, minimizing boilerplate when writing Compositional Layouts.
@resultBuilder
public struct LayoutBuilder {
    
    // MARK: - Core Expressions
    
    public static func buildExpression(_ section: NSCollectionLayoutSection) -> NSCollectionLayoutSection {
        return section
    }
    
    public static func buildExpression(_ group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        return NSCollectionLayoutSection(group: group)
    }
    
    public static func buildExpression(_ item: NSCollectionLayoutItem) -> NSCollectionLayoutSection {
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: item.layoutSize.heightDimension
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    // MARK: - Blocks Support
    
    public static func buildBlock(_ component: NSCollectionLayoutSection) -> NSCollectionLayoutSection {
        return component
    }
    
    public static func buildEither(first component: NSCollectionLayoutSection) -> NSCollectionLayoutSection {
        return component
    }
    
    public static func buildEither(second component: NSCollectionLayoutSection) -> NSCollectionLayoutSection {
        return component
    }

    public static func buildOptional(_ component: NSCollectionLayoutSection?) -> NSCollectionLayoutSection? {
        return component
    }
}
