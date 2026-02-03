import UIKit

struct PosterCell: ViewBuilder {
    let movie: Movie
    
    var body: View {
        VStackView {
            ImageView(url: movie.posterURL)
                .skeletonable(true)
                .contentMode(.scaleAspectFill)
                .backgroundColor(.darkGray)
                .cornerRadius(8)
                .clipsToBounds(true)
                .height(180)
            
            LabelView(movie.title)
                .font(.systemFont(ofSize: 14, weight: .medium))
                .color(.white)
                .numberOfLines(1)
                .skeletonable(true)
        }
        .clipsToBounds(true)
    }
}
