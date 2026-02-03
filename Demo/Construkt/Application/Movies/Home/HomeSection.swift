import UIKit

enum HomeSection: String, SectionControllerIdentifier {
    case hero
    case popular
    
    var uniqueId: String { rawValue }
    
    var layout: NSCollectionLayoutSection {
        switch self {
        case .hero:
            return .layout(
                group: .horizontally(estimatedHeight: 480),
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
                scrolling: .continuous
            )
        }
    }
}
