import UIKit
import ConstruktKit

struct UpcomingCell: ViewBuilder {
    let item: RenderItem<Movie>
    
    var body: View {
        ZStackView {
            ImageView(UIImage())
                .render(for: item) { $0.backdropURL }
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
                        LabelView("")
                            .font(.systemFont(ofSize: 10, weight: .bold))
                            .color(.white)
                            .backgroundColor(UIColor.black.withAlphaComponent(0.5))
                            .cornerRadius(4)
                            .padding(h: 4, v: 2)
                            .render(for: item, placeholder: "COMING JUNE 24") { _ in "COMING JUNE 24" }
                        LabelView("")
                            .font(.systemFont(ofSize: 16, weight: .semibold))
                            .color(.white)
                            .numberOfLines(2)
                            .render(for: item, placeholder: "Placeholder Movie Title") { $0.title }
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
