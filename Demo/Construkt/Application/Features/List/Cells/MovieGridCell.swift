import UIKit
import ConstruktKit

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
        .height(290)
    }
    
    private var ratingBadge: View {
        ZStackView {
            HStackView(spacing: 4) {
                ImageView(systemName: "star.fill")
                    .tintColor(.systemYellow)
                    .contentMode(.scaleAspectFit)
                    .size(width: 12, height: 12)
                
                LabelView(String(format: "%.1f", movie.voteAverage))
                    .font(.systemFont(ofSize: 10, weight: .bold))
                    .color(.white)
            }
            .padding(top: 4, left: 6, bottom: 4, right: 6)
            .alignment(.center)
        }
        .backgroundColor(.black.withAlphaComponent(0.5))
        .margins(h: 6, v: 6)
        .position(.topRight)
        .width(max: 50)
        .height(30)
        .cornerRadius(8)
        .skeletonable(true, bgColor: UIColor("#EEEEEE"))
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
