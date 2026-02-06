import UIKit
import RxSwift
import RxCocoa

final class MovieDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = MovieViewModel()
    private let movie: Movie
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#0A0A0A")
        
        // Output signal
        let details = viewModel.movieDetails
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
        
        // Casts signal
        let casts = viewModel.movieCasts
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
            
        setupUI(details: details, casts: casts)
        
        // Trigger fetch
        viewModel.selectMovie(movie)
    }
    
    // MARK: - Setup UI
    private func setupUI(details: Observable<MovieDetail?>, casts: Observable<[Cast]>) {
        let safeDetails = details.compactMap { $0 }
        
        view.embed(
            ContainerView {
                // Background & Scroll Content
                VerticalScrollView {
                    VStackView(spacing: 24) {
                        heroSection(details: safeDetails)
                        
                        VStackView(spacing: 24) {
                            actionButtons
                            storylineSection(details: safeDetails)
                            castSection(casts: casts)
                            similarSection(details: safeDetails)
                        }
                        .padding(top: 0, left: 20, bottom: 0, right: 20)
                        
                        // Spacer
                        SpacerView(h: 40)
                    }
                }
                .with { $0.contentInsetAdjustmentBehavior = .never }
                
                // Overlay Navigation Bar
                navigationBar
            }
        )
    }
    
    private var navigationBar: View {
        ZStackView {
            GradientView(colors: [.black.withAlphaComponent(0.8), .black.withAlphaComponent(0.3)])
                .height(100)
                .alpha(0) // Start transparent
            
            CustomNavigationBar(
                leading: [
                    ButtonView()
                        .with { $0.setImage(UIImage(systemName: "arrow.left"), for: .normal) }
                        .tintColor(.white)
                        .backgroundColor(UIColor.black.withAlphaComponent(0.3), for: .normal)
                        .cornerRadius(20)
                        .size(width: 40, height: 40)
                        .onTap { [weak self] _ in self?.navigationController?.popViewController(animated: true) }
                ],
                trailing: [
                    ButtonView()
                        .with { $0.setImage(UIImage(systemName: "heart"), for: .normal) }
                        .tintColor(.white)
                        .backgroundColor(UIColor.black.withAlphaComponent(0.3), for: .normal)
                        .cornerRadius(20)
                        .size(width: 40, height: 40),
                    
                    ButtonView()
                        .with { $0.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal) }
                        .tintColor(.white)
                        .backgroundColor(UIColor.black.withAlphaComponent(0.3), for: .normal)
                        .cornerRadius(20)
                        .size(width: 40, height: 40)
                ]
            )
        }
        .position(.top)
        .height(48)
    }
    
    private func heroSection(details: Observable<MovieDetail>) -> View {
        ZStackView {
            // Layer 1: Backdrop Image
            ImageView(nil)
                .contentMode(.scaleAspectFill)
                .clipsToBounds(true)
                .height(450)
                .onReceive(details.map { $0.backdropURL ?? $0.posterURL }) { context in
                    context.view.setImage(from: context.value)
                }
            
            // Layer 2: Gradient Overlay
            LocalGradientView()
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
                    LabelView(movie.title)
                        .font(UIFont.systemFont(ofSize: 32, weight: .bold))
                        .color(.white)
                        .numberOfLines(2)
                        .alignment(.center)
                    
                    // Metadata Row
                    metadata(details: details)
                    
                    // Rating Row
                    HStackView(spacing: 4) {
                        ImageView(UIImage(systemName: "star.fill")).tintColor(.systemYellow).size(width: 14, height: 14)
                        ImageView(UIImage(systemName: "star.fill")).tintColor(.systemYellow).size(width: 14, height: 14)
                        ImageView(UIImage(systemName: "star.fill")).tintColor(.systemYellow).size(width: 14, height: 14)
                        ImageView(UIImage(systemName: "star.fill")).tintColor(.systemYellow).size(width: 14, height: 14)
                        ImageView(UIImage(systemName: "star.fill")).tintColor(.systemYellow).size(width: 14, height: 14)
                        
                        LabelView(details.map { "\(String(format: "%.1f", $0.voteAverage)) (2.4k)" })
                            .font(UIFont.systemFont(ofSize: 14))
                            .color(.lightGray)
                    }
                    .alignment(.center)
                }
                .alignment(.center) // Center children horizontally
            }
            .padding(top: 0, left: 16, bottom: 20, right: 16) // Padding from edges
            .position(.bottom) // Pin container to bottom of ZStack
        }
        .height(450)
    }
    
    private func metadata(details: Observable<MovieDetail>) -> View {
        ZStackView {
            HStackView(spacing: 6) {
                ZStackView {
                    LabelView(movie.releaseDate?.prefix(4).description ?? "2024")
                        .font(UIFont.systemFont(ofSize: 14))
                        .color(.lightGray)
                }
                LabelView("•")
                    .color(.darkGray)
                    .font(.systemFont(ofSize: 10))
                    .alignment(.center)
                ZStackView {
                    LabelView(details.map { $0.genreText })
                        .font(UIFont.systemFont(ofSize: 14))
                        .color(.lightGray)
                }
                LabelView("•")
                    .color(.darkGray)
                    .font(.systemFont(ofSize: 10))
                    .alignment(.center)
                ZStackView {
                    LabelView(details.map { $0.durationText })
                        .font(UIFont.systemFont(ofSize: 14))
                        .color(.lightGray)
                }
                LabelView("•")
                    .color(.darkGray)
                    .font(.systemFont(ofSize: 10))
                    .alignment(.center)
                ZStackView {
                    LabelView("4K")
                        .font(UIFont.systemFont(ofSize: 10))
                        .color(.lightGray)
                        .padding(top: 2, left: 4, bottom: 2, right: 4)
                }
                .border(color: .lightGray, lineWidth: 1)
                .cornerRadius(4)
            }
        }
    }
    
    private var actionButtons: View {
        HStackView(spacing: 16) {
            ButtonView("Watch Now")
                .backgroundColor(.white, for: .normal)
                .color(.black, for: .normal)
                .font(UIFont.systemFont(ofSize: 16, weight: .bold))
                .cornerRadius(24)
                .height(56)
                .with {
                    $0.setImage(UIImage(systemName: "play.fill"), for: .normal)
                    $0.tintColor = .black
                    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
                }
            ButtonView("Download")
                .backgroundColor(UIColor(hex: "#1A1A1A"), for: .normal)
                .color(.white, for: .normal)
                .font(UIFont.systemFont(ofSize: 16, weight: .medium))
                .cornerRadius(24)
                .height(56)
                .with {
                    $0.setImage(UIImage(systemName: "arrow.down.to.line"), for: .normal)
                    $0.tintColor = .white
                    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
                }
        }
        .distribution(.fillEqually)
    }
    
    private func storylineSection(details: Observable<MovieDetail>) -> View {
        VStackView(spacing: 12) {
            LabelView("Storyline")
                .font(UIFont.systemFont(ofSize: 18, weight: .bold))
                .color(.white)
            
            LabelView(details.map { $0.overview })
                .font(UIFont.systemFont(ofSize: 14))
                .color(.lightGray)
                .numberOfLines(0)
        }
    }
    
    private func castSection(casts: Observable<[Cast]>) -> View {
        VStackView(spacing: 16) {
            HStackView {
                LabelView("Cast & Crew")
                    .font(UIFont.systemFont(ofSize: 18, weight: .bold))
                    .color(.white)
                SpacerView()
                LabelView("View all")
                    .font(UIFont.systemFont(ofSize: 14))
                    .color(.gray)
            }
            
            ScrollView(
                HStackView {}
                    .onReceive(casts.map { self.createCastViews(from: $0) }) { context in
                        context.view.reset(to: context.value)
                    }
                    .spacing(16)
                    .alignment(.top)
            )
            .showHorizontalIndicator(false)
            .bounces(false)
            .height(min: 120)
        }
    }
    
    private func similarSection(details: Observable<MovieDetail>) -> View {
        VStackView(spacing: 16) {
            LabelView("More Like This")
                .font(UIFont.systemFont(ofSize: 18, weight: .bold))
                .color(.white)
            
            VStackView(details.map { self.createSimilarViews(from: $0) })
                .spacing(16)
        }
    }
    
    // MARK: - View Creators
    
    private func createCastViews(from casts: [Cast]) -> [View] {
        guard !casts.isEmpty else { return [] }
        return casts.prefix(10).map { createCastView($0) }
    }
    
    private func createCastView(_ cast: Cast) -> View {
        VStackView {
            ImageView(url: cast.profileURL)
                .backgroundColor(.darkGray)
                .cornerRadius(30)
                .width(60)
                .height(60)
                .clipsToBounds(true)
                .contentMode(.scaleAspectFill)
               
            ZStackView {
                VStackView(spacing: 4) {
                    LabelView(cast.name)
                        .font(UIFont.systemFont(ofSize: 12, weight: .medium))
                        .color(.white)
                        .numberOfLines(2)
                        .alignment(.center)
                    
                    LabelView(cast.character)
                        .font(UIFont.systemFont(ofSize: 10))
                        .color(.gray)
                        .numberOfLines(1)
                        .alignment(.center)
                }
                .alignment(.center)
            }
        }
        .width(max: 100, priority: .required)
        .alignment(.center)
        .padding(h: 2, v: 4)
    }
    
    private func createSimilarViews(from details: MovieDetail) -> [View] {
        guard let similarMovies = details.similar?.results.prefix(9) else { return [] }
        let chunked = Array(similarMovies).chunked(into: 3)
        return chunked.map { rowMovies -> View in
            var views: [View] = rowMovies.map { self.createMoviePoster($0) }
            
            // Add spacers if row is incomplete to align left
            if rowMovies.count < 3 {
                for _ in 0..<(3 - rowMovies.count) {
                    views.append(ContainerView().with { $0.alpha = 0 })
                }
            }
            
            return HStackView(views).distribution(.fillEqually)
        }
    }
    
    private func createMoviePoster(_ movie: Movie) -> View {
        ImageView(nil)
            .backgroundColor(.darkGray)
            .cornerRadius(8)
            .contentMode(.scaleAspectFill)
            .clipsToBounds(true)
            .with { view in
                view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2/3).isActive = true
                view.setImage(from: movie.posterURL)
            }
    }
}

// MARK: - Extensions
// Assuming LabelView, etc are from Builder

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - Local Custom Components

struct LocalGradientView: ModifiableView {
    
    var modifiableView = GradientOverlayView()
    
    init() {}
}

class GradientOverlayView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    init() {
        super.init(frame: .zero)
        guard let layer = self.layer as? CAGradientLayer else { return }
        layer.colors = [UIColor.clear.cgColor, UIColor(hex: "#0A0A0A").cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
