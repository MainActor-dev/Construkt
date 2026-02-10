import UIKit

struct AdsCell: ViewBuilder {
    let text: String
    
    var body: View {
        CenteredView {
            LabelView(text)
                .font(.systemFont(ofSize: 16, weight: .bold))
                .alignment(.center)
                .color(.white)
        }
        .border(color: .white.withAlphaComponent(0.3), lineWidth: 1)
        .cornerRadius(12)
        .clipsToBounds(true)
    }
}

struct TopRatedCell: ViewBuilder {
    let index: Int
    let movie: Movie
    
    var body: View {
        ZStackView {
            HStackView {
                // Ranking Number
                LabelView(index > 0 ? "\(index)" : "")
                    .font(.systemFont(ofSize: 30, weight: .bold))
                    .color(UIColor.darkGray.withAlphaComponent(0.5)) // Faded number
                    .alignment(.center)
                    .width(40)
                    .skeletonable(true)
                
                // Poster
                ImageView(url: movie.posterURL)
                    .skeletonable(true)
                    .contentMode(.scaleAspectFill)
                    .backgroundColor(.darkGray)
                    .clipsToBounds(true)
                    .cornerRadius(8)
                    .width(60, priority: .required)
                    .height(90)
                
                // Info
                VStackView(spacing: 4) {
                    LabelView(movie.title)
                        .font(.systemFont(ofSize: 16, weight: .semibold))
                        .color(.white)
                        .numberOfLines(2)
                        .skeletonable(true)
                    HStackView(spacing: 4) {
                        ImageView(UIImage(systemName: "star.fill"))
                            .tintColor(.systemYellow)
                            .size(width: 12, height: 12)
                        HStackView {
                            LabelView(String(format: "%.1f", movie.voteAverage))
                                .font(.systemFont(ofSize: 14))
                                .color(.systemYellow)
                            LabelView("DRAMA") // Placeholder genre
                                .font(.systemFont(ofSize: 12))
                                .color(.gray)
                                .padding(insets: .init(top: 0, left: 8, bottom: 0, right: 0))
                            SpacerView()
                        }
                        .alignment(.center)
                    }
                    .alignment(.center)
                    .skeletonable(true)
                    SpacerView()
                }
            }
        }
        .padding(12)
        .backgroundColor(UIColor(white: 1.0, alpha: 0.05))
        .cornerRadius(12)
        .border(color: UIColor(white: 1.0, alpha: 0.1), lineWidth: 1)
    }
}
