import UIKit
import SnapKit

class HeroContentView: UIView {
    
    private var backgroundImageView: UIImageView?
    private var contentContainer: UIView?
    private var titleLabel: UILabel?
    private var ratingLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        embed(
            ZStackView {
                // Background
                ImageView(nil)
                    .contentMode(.scaleAspectFill)
                    .backgroundColor(.darkGray)
                    .clipsToBounds(true)
                    .with { [weak self] in self?.backgroundImageView = $0 }
                
                // Content Gradient and Text
                VStackView {
                    SpacerView()
                    
                    ZStackView {
                        // Gradient
                        GradientView(colors: [.clear, .black.withAlphaComponent(0.8), .black])
                            .height(300)
                        
                        // Text Content
                        VStackView(spacing: 8) {
                            SpacerView()
                            
                            // Badge & Rating
                            HStackView(spacing: 8) {
                                LabelView("TRENDING NOW")
                                    .font(.systemFont(ofSize: 10, weight: .bold))
                                    .color(UIColor.white.withAlphaComponent(0.8))
                                    .backgroundColor(UIColor.white.withAlphaComponent(0.2))
                                    .cornerRadius(4)
                                    .padding(2)
                                HStackView(spacing: 4) {
                                    ImageView(UIImage(systemName: "star.fill"))
                                        .tintColor(.systemYellow)
                                        .size(width: 12, height: 12)
                                    LabelView("-")
                                        .font(.systemFont(ofSize: 12, weight: .bold))
                                        .color(.systemYellow)
                                        .with { [weak self] in self?.ratingLabel = $0 }
                                }
                                .alignment(.center)
                            }
                            .alignment(.leading)
                            
                            // Title
                            LabelView("-")
                                .font(.systemFont(ofSize: 32, weight: .bold))
                                .color(.white)
                                .numberOfLines(2)
                                .with { [weak self] in self?.titleLabel = $0 }
                            
                            // Metadata
                            LabelView("Sci-Fi  •  2h 15m")
                                .font(.systemFont(ofSize: 14))
                                .color(.lightGray)
                            
                            // Button
                            ButtonView("Watch Trailer")
                                .font(.systemFont(ofSize: 16, weight: .semibold))
                                .color(.black)
                                .backgroundColor(.white)
                                .cornerRadius(24)
                                .height(48)
                                .width(CGFloat.greatestFiniteMagnitude)
                        }
                        .alignment(.leading)
                        .padding(16)
                        .with { [weak self] in self?.contentContainer = $0 }
                    }
                }
            }
        )
    }
    
    func configure(with movie: Movie) {
        if let path = movie.backdropPath, let url = URL(string: "https://image.tmdb.org/t/p/w500" + path) {
             backgroundImageView?.setImage(from: url)
        }
        
        titleLabel?.text = movie.title
        ratingLabel?.text = String(format: "%.1f", movie.voteAverage)
    }
    
    // MARK: - Animation
    
    public func setScrollProgress(_ progress: CGFloat) {
        guard let container = contentContainer else { return }
        
        // progress: 0.0 (center) -> 1.0 (edge)
        let alpha = max(0, 1 - (progress * 1.5)) // Fade out faster than scroll
        let translationY = progress * 50 // Slide down 50pt max
        
        let transform = CGAffineTransform(translationX: 0, y: translationY)
        
        container.transform = transform
        container.alpha = alpha
    }
    
    public func setContentHidden(_ hidden: Bool, animated: Bool) {
        setScrollProgress(hidden ? 1.0 : 0.0)
    }
}
