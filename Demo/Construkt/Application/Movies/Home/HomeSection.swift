import UIKit

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
            return .layout(
                group: .horizontally(height: .absolute(550)),
                insets: .init(top: 0, leading: 0, bottom: 16, trailing: 0),
                scrolling: .groupPagingCentered
            )
        case .categories:
            return .layout(
                group: .horizontally(
                    width: .estimated(100),
                    height: .absolute(40)
                ),
                spacing: 12,
                insets: .init(v: 16, h: 16),
                supplementaryItems: [.header(height: .absolute(40))],
                scrolling: .continuous
            )
        case .popular:
            return .layout(
                group: .horizontally(
                    width: .absolute(128),
                    height: .estimated(200)
                ),
                spacing: 8,
                insets: .init(v: 16, h: 16),
                supplementaryItems: [.header(height: .absolute(30))],
                scrolling: .continuous
            )
        case .upcoming:
            return .layout(
                group: .horizontally(
                    width: .absolute(280),
                    height: .absolute(160)
                ),
                spacing: 12,
                insets: .init(v: 16, h: 16),
                supplementaryItems: [.header(height: .absolute(40))],
                scrolling: .continuous
            )
        case .topRated:
            return .layout(
                group: .vertically(width: .fractionalWidth(1.0), height: .estimated(50)),
                spacing: 12,
                insets: .init(v: 16, h: 16),
                supplementaryItems: [.header(height: .absolute(40))]
            )
        }
    }
}
