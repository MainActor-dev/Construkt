import UIKit
import ConstruktKit

enum HomeSection: String, SectionControllerIdentifier {
    case hero
    case categories
    case popular
    case upcoming
    case topRated
    
    var uniqueId: String { rawValue }
    
    var layout: NSCollectionLayoutSection {
        switch self {
        case .hero:
            return CollectionLayoutSectionBuilder.carousel(itemWidth: .fractionalWidth(1.0), itemHeight: .absolute(500))
                .insets(top: 0, leading: 0, bottom: 16, trailing: 0)
                .orthogonalScrolling(.groupPagingCentered)
                .section
        case .categories:
            return CollectionLayoutSectionBuilder.carousel(itemWidth: .estimated(100), itemHeight: .absolute(40))
                .spacing(12)
                .insets(top: 16, leading: 16, bottom: 16, trailing: 16)
                .supplementaryHeader(height: .absolute(40))
                .section
        case .popular:
            return CollectionLayoutSectionBuilder.carousel(itemWidth: .absolute(128), itemHeight: .estimated(200))
                .spacing(8)
                .insets(top: 16, leading: 16, bottom: 16, trailing: 16)
                .supplementaryHeader(height: .absolute(30))
                .section
        case .upcoming:
            return CollectionLayoutSectionBuilder.carousel(itemWidth: .absolute(280), itemHeight: .absolute(160))
                .spacing(12)
                .insets(top: 16, leading: 16, bottom: 16, trailing: 16)
                .supplementaryHeader(height: .absolute(40))
                .section
        case .topRated:
            return CollectionLayoutSectionBuilder.list(itemHeight: .estimated(50))
                .spacing(12)
                .insets(top: 16, leading: 16, bottom: 16, trailing: 16)
                .supplementaryHeader(height: .absolute(40))
                .section
        }
    }
}
