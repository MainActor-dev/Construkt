import UIKit

enum HomeSection: String, SectionControllerIdentifier {
    case hero
    case popular
    
    var uniqueId: String { rawValue }
    
    var layout: NSCollectionLayoutSection {
        switch self {
        case .hero:
            return .layout(
                group: .horizontally(height: .absolute(480)),
                insets: .init(top: 0, leading: 0, bottom: 16, trailing: 0),
                scrolling: .groupPagingCentered
            )
        case .popular:
            return .layout(
                group: .horizontally(
                    width: .absolute(128),
                    height: .estimated(200)
                ),
                spacing: 8,
                insets:  .init(top: 16, leading: 16, bottom: 0, trailing: 16),
                supplementaryItems: [.header(height: .absolute(30))],
                scrolling: .continuous
            )
        }
    }
}
