import UIKit

struct MovieGridCell: ViewBuilder {
    let movie: Movie
    
    var body: View {
        VStackView(spacing: 8) {
            posterSection
            titleLabel
            metadataLabel
        }
    }
    
    private var posterSection: View {
        ContainerView {
            ImageView(url: movie.posterURL)
                .contentMode(.scaleAspectFill)
                .backgroundColor(.darkGray)
                .cornerRadius(8)
                .clipsToBounds(true)
                .skeletonable(true)
            
            ratingBadge
        }
        .height(180) 
    }
    
    private var ratingBadge: View {
        ContainerView {
            HStackView(spacing: 4) {
                ImageView(systemName: "star.fill")
                    .tintColor(.systemYellow)
                    .contentMode(.scaleAspectFit)
                    .size(width: 10, height: 10)
                
                LabelView(String(format: "%.1f", movie.voteAverage))
                    .font(.systemFont(ofSize: 10, weight: .bold))
                    .color(.white)
            }
            .padding(top: 4, left: 6, bottom: 4, right: 6)
        }
        .backgroundColor(UIColor.black.withAlphaComponent(0.7))
        .cornerRadius(4)
        .defaultPosition(.topRight)
        .padding(insets: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 8))
    }
    
    private var titleLabel: View {
        LabelView(movie.title)
            .font(.systemFont(ofSize: 14, weight: .semibold))
            .color(.white)
            .numberOfLines(1)
            .skeletonable(true)
    }
    
    private var metadataLabel: View {
        LabelView(metadataString)
            .font(.systemFont(ofSize: 12))
            .color(.gray)
            .numberOfLines(1)
            .skeletonable(true)
    }
    
    private var metadataString: String {
        // Placeholder genre + Year
        let genre = "Action" 
        let year = movie.releaseDate?.prefix(4) ?? "----"
        return "\(genre) • \(year)"
    }
}
