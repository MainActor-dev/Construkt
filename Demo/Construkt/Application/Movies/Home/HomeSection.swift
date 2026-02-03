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
                    estimatedWidth: 128,
                    estimatedHeight: 231,
                    insets: .init(top: 0, leading: 16, bottom: 0, trailing: 16)
                )
            )
        }
    }
}
