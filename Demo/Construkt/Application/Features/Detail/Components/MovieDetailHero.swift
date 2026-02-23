import UIKit
import ConstruktKit

struct MovieDetailHero: ViewBuilder {
    
    let details: AnyViewBinding<MovieDetail>
    let height: CGFloat
    
    var body: View {
        ZStackView {
            // Layer 1: Transparent Spacer to matching Hero Height
            SpacerView(h: height)
            
            // Layer 2: Gradient Overlay (Moves with content)
            GradientView(colors: [.clear, UIColor("#0A0A0A")])
                .position(.fill)
            
            // Layer 3: Play Button (Centered in Hero)
            ImageView(UIImage(systemName: "play.circle.fill"))
                .tintColor(.white)
                .size(width: 64, height: 64)
                .position(.center)
            
            // Layer 4: Content Overlay (Pinned Bottom, Centered)
            ZStackView {
                VStackView(spacing: 8) {
                    SpacerView()
                    // Title
                    LabelView(details.map { $0.title })
                        .font(UIFont.systemFont(ofSize: 32, weight: .bold))
                        .color(.white)
                        .numberOfLines(2)
                        .alignment(.center)
                    
                    // Metadata Row
                    MovieMetadata(details: details)
                    
                    // Rating Row
                    HStackView(spacing: 4) {
                        ImageView(UIImage(systemName: "star.fill")).tintColor(.systemYellow).size(width: 14, height: 14)
                        LabelView(details.map { "\(String(format: "%.1f", $0.voteAverage)) (2.4k)" })
                            .font(UIFont.systemFont(ofSize: 14))
                            .color(.lightGray)
                    }
                    .alignment(.center)
                }
                .alignment(.center)
            }
            .padding(top: 0, left: 16, bottom: 20, right: 16)
            .position(.bottom)
        }
        .height(height)
    }
}
