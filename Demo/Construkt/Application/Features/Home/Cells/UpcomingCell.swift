import UIKit
import ConstruktKit

struct UpcomingCell: ViewBuilder {
    let movie: Movie
    
    var body: View {
        ZStackView {
            ImageView(url: movie.backdropURL)
                .skeletonable(true)
                .contentMode(.scaleAspectFill)
                .backgroundColor(.darkGray)
                .clipsToBounds(true)
            GradientView(colors: [.clear, .black.withAlphaComponent(0.8)])
                .height(80)
            VStackView {
                SpacerView()
                ZStackView {
                    VStackView(spacing: 4) {
                        SpacerView()
                        LabelView("COMING JUNE 24") // Placeholder
                            .font(.systemFont(ofSize: 10, weight: .bold))
                            .color(.white)
                            .backgroundColor(UIColor.black.withAlphaComponent(0.5))
                            .cornerRadius(4)
                            .padding(h: 4, v: 2)
                            .skeletonable(true)
                        LabelView(movie.title)
                            .font(.systemFont(ofSize: 16, weight: .semibold))
                            .color(.white)
                            .numberOfLines(2)
                            .skeletonable(true)
                    }
                    .alignment(.leading)
                }
                .padding(h: 12, v: 8)
            }
        }
        .cornerRadius(8)
        .clipsToBounds(true)
    }
}
