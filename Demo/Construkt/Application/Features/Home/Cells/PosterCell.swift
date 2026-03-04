import UIKit
import ConstruktKit

struct PosterCell: ViewBuilder {
    let movie: Movie
    
    var body: View {
        VStackView(spacing: 8) {
            ImageView(url: movie.posterURL)
                .shimmerable(true)
                .contentMode(.scaleAspectFill)
                .backgroundColor(.darkGray)
                .cornerRadius(8)
                .clipsToBounds(true)
                .height(180)
            
            VStackView(spacing: 4) {
                LabelView(movie.title)
                    .font(.systemFont(ofSize: 14, weight: .semibold))
                    .color(.white)
                    .numberOfLines(1)
                    .shimmerable(true)
                
                LabelView("Adventure") // Placeholder genre
                    .font(.systemFont(ofSize: 12))
                    .color(.gray)
                    .shimmerable(true)
            }
            .alignment(.leading)
        }
        .clipsToBounds(true)
    }
}
