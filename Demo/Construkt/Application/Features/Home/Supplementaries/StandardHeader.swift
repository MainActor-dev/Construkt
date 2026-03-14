import UIKit
import ConstruktKit

struct StandardHeader: ViewBuilder {
    let title: String
    let actionTitle: String?
    var sectionId: String? = nil
    
    var body: View {
        HStackView() {
            LabelView(title)
                .font(.systemFont(ofSize: 18, weight: .semibold))
                .color(.white)
                .shimmerable(true)
            
            SpacerView()
            
            if let action = actionTitle {
                ButtonView(action)
                    .font(.systemFont(ofSize: 14))
                    .color(.lightGray)
                    .shimmerable(true)
                    .onRoute(AppRoute.movieList(title: "Popular Now", sectionTypeRaw: HomeSection.popular.rawValue, genreId: nil, genreName: nil, allGenres: nil))
            }
        }
        .alignment(.center)
        .with { view in
            if let id = sectionId {
                view.accessibilityIdentifier = id
            }
        }
    }
}

