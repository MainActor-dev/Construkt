import UIKit

final class MovieDetailViewController: UIViewController {
    
    private let movie: Movie
  
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var navigationBar: View {
        ZStackView {
            CustomNavigationBar(
                title: movie.title,
                onBack: { [weak self] in self?.pop() },
                tintColor: .white
            )
            .with { $0.backgroundColor = .clear}
        }
        .position(.top)
        .height(48)
    }
    
    private var body: View {
        ZStackView {
            // Main Content
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
                            .color(UIColor("#F9F9F9"))
                        
                        HStackView(spacing: 8) {
                            LabelView("Rate: \(String(format: "%.1f", movie.voteAverage))/10")
                                .font(.preferredFont(forTextStyle: .subheadline))
                                .color(.white)
                            
                            LabelView("•")
                                .color(.white)
                            
                            LabelView(movie.releaseDate ?? "")
                                .font(.preferredFont(forTextStyle: .subheadline))
                                .color(.white)
                            
                            SpacerView()
                        }
                        
                        LabelView(movie.overview)
                            .font(.preferredFont(forTextStyle: .body))
                            .numberOfLines(0)
                            .color(.white)
                    }
                    .padding(16)
                }
            }
            .with { $0.contentInset.top = 48 } // Push content below navbar
            navigationBar
        }
        .backgroundColor(UIColor("#0A0A0A"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = movie.title
        view.embed (body)
    }
    
    private func pop() {
        navigationController?.popViewController(animated: true)
    }
}
