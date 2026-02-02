import UIKit

final class MovieDetailViewController: UIViewController {
    
    let movie: Movie
    // In a real app we might bind to a ViewModel for full details,
    // but for this simple detail view we can just show what we have
    // or rely on the passed movie object which might be fully populated.
    
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = movie.title
        view.backgroundColor = .systemBackground
        

        view.embed (
            VerticalScrollView {
                VStackView(spacing: 16) {
                    
                    // Backdrop
                    ImageView(nil)
                        .contentMode(.scaleAspectFill)
                        .clipsToBounds(true)
                        .height(200)
                        .backgroundColor(.secondarySystemBackground)
                        .with { [weak self] view in
                            if let url = self?.movie.backdropURL ?? self?.movie.posterURL {
                                view.setImage(from: url)
                            }
                        }
                    
                    VStackView(spacing: 16) {
                        LabelView(movie.title)
                            .font(.preferredFont(forTextStyle: .title1))
                            .numberOfLines(0)
                        
                        HStackView(spacing: 8) {
                            LabelView("Rate: \(String(format: "%.1f", movie.voteAverage))/10")
                                .font(.preferredFont(forTextStyle: .subheadline))
                                .color(.secondaryLabel)
                            
                            LabelView("•")
                                .color(.secondaryLabel)
                            
                            LabelView(movie.releaseDate ?? "")
                                .font(.preferredFont(forTextStyle: .subheadline))
                                .color(.secondaryLabel)
                            
                            SpacerView()
                        }
                        
                        LabelView(movie.overview)
                            .font(.preferredFont(forTextStyle: .body))
                            .numberOfLines(0)
                    }
                    .padding(16)
                }
            }
        )
    }
}
