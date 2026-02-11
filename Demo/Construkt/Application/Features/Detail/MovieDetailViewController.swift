import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MovieDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = MovieViewModel()
    private let movie: Movie
    private let heroHeight: CGFloat = 450
    
    private weak var scrollView: UIScrollView?
    private weak var heroImageView: UIView?
    private weak var navBarBackgroundView: UIView?
    private weak var navBarTitleLabel: UIView?
    
    // MARK: - Init
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("#0A0A0A")
        observe()
        fetchDetail()
    }
    
    deinit {
        ImageCache.clear()
    }
    
    private func fetchDetail() {
        viewModel.selectMovie(movie)
    }
    
    private func observe() {
        let details = viewModel.movieDetails
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
        
        let casts = viewModel.movieCasts
            .observe(on: MainScheduler.instance)
            .share(replay: 1)
        
        setupUI(details: details, casts: casts)
    }
    
    // MARK: - Setup UI
    private func setupUI(details: Observable<MovieDetail?>, casts: Observable<[Cast]>) {
        let safeDetails = details.compactMap { $0 }
        
        view.subviews.forEach { $0.removeFromSuperview() }
        
        view.embed(
            ZStackView {
                ImageView(nil)
                    .contentMode(.scaleAspectFill)
                    .clipsToBounds(true)
                    .onReceive(safeDetails.map { $0.backdropURL ?? $0.posterURL }) { context in
                        context.view.setImage(from: context.value)
                    }
                    .onReceive(viewModel.isLoadingDetails){ context in
                        context.view.isHidden = context.value
                    }
                    .with { [weak self] view in
                        self?.heroImageView = view
                    }
                    .customConstraints { [weak self] view in
                        guard let self = self else { return }
                        view.snp.makeConstraints { make in
                            make.top.leading.trailing.equalToSuperview()
                            make.height.equalTo(self.heroHeight)
                        }
                    }
                
                // Layer 2: Scroll Content
                ContainerView {
                    VerticalScrollView {
                        VStackView(spacing: 24) {
                            // Transparent Header Space + Content Overlay
                            heroSectionContent(details: safeDetails)
                            
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
                    .onDidScroll { [weak self] context in
                        let yOffset = context.view.contentOffset.y
                        self?.updateStretchyHeader(yOffset: yOffset)
                        self?.handleNavBarScroll(yOffset: yOffset)
                    }
                    .with { scrollView in
                        scrollView.contentInsetAdjustmentBehavior = .never
                        scrollView.backgroundColor = .clear
                    }
                    .onReceive(viewModel.isLoadingDetails) { context in
                        context.view.isHidden = context.value
                    }
                    .reference(&scrollView)
                    
                    // Overlay Navigation Bar
                    navigationBar
                    
                    // Loading Indicator
                    LoadingView()
                        .visible(false)
                        .onReceive(viewModel.isLoadingDetails) { context in
                            context.view.isHidden = !context.value
                        }
                        .backgroundColor(.black.withAlphaComponent(0.5))
                }
            }
        )
    }
    
    private func updateStretchyHeader(yOffset: CGFloat) {
        guard let heroView = heroImageView else { return }
        
        if yOffset < 0 {
            heroView.snp.updateConstraints { make in
                make.height.equalTo(self.heroHeight + abs(yOffset))
            }
        } else {
            heroView.snp.updateConstraints { make in
                make.height.equalTo(max(0, self.heroHeight - yOffset))
            }
        }
    }
    
    private func handleNavBarScroll(yOffset: CGFloat) {
        // Fade in background between 0 and 100pt
        let bgAlpha = min(1.0, max(0.0, yOffset / 100.0))
        navBarBackgroundView?.alpha = bgAlpha
        
        // Fade in title between 300 and 350pt (when hero title disappears)
        let titleStart: CGFloat = 300
        let titleEnd: CGFloat = 350
        let titleAlpha = min(1.0, max(0.0, (yOffset - titleStart) / (titleEnd - titleStart)))
        navBarTitleLabel?.alpha = titleAlpha
    }
    
    private var navigationBar: View {
        ZStackView {
            GradientView(colors: [.black.withAlphaComponent(0.8), .black.withAlphaComponent(0.3)])
                .height(100)
                .alpha(0) // Start transparent
                .with { [weak self] view in
                    self?.navBarBackgroundView = view
                }
            
            // Title (Centered)
            
            
            CustomNavigationBar(
                leading: [
                    ButtonView()
                        .with { $0.setImage(UIImage(systemName: "arrow.left"), for: .normal) }
                        .tintColor(.white)
                        .backgroundColor(UIColor.black.withAlphaComponent(0.3), for: .normal)
                        .cornerRadius(20)
                        .size(width: 40, height: 40)
                        .onTap { [weak self] _ in self?.navigationController?.popViewController(animated: true) },
                    LabelView(movie.title)
                        .font(.systemFont(ofSize: 17, weight: .semibold))
                        .color(.white)
                        .alignment(.center)
                        .alpha(0)
                        .with { [weak self] view in
                            self?.navBarTitleLabel = view
                        }
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
    
    private func heroSectionContent(details: Observable<MovieDetail>) -> View {
        ZStackView {
            // Layer 1: Transparent Spacer to matching Hero Height
            SpacerView(h: heroHeight)
            
            // Layer 2: Gradient Overlay (Moves with content)
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
                    LabelView(details.map { $0.title })
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
        .height(heroHeight)
    }
    
    private func metadata(details: Observable<MovieDetail>) -> View {
        ZStackView {
            HStackView(spacing: 6) {
                ZStackView {
                    LabelView(details.map { $0.releaseDate?.prefix(4).description ?? "2024" })
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
                .backgroundColor(UIColor("#1A1A1A"), for: .normal)
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
                    .onReceive(casts.map { [weak self] in self?.createCastViews(from: $0) ?? [] }) { context in
                        context.view.reset(to: context.value)
                    }
                    .spacing(16)
                    .alignment(.top)
            )
            .showHorizontalIndicator(false)
            .bounces(false)
            .height(min: 120)
        }
        .onReceive(casts.map { $0.isEmpty }) { context in
            context.view.isHidden = context.value
        }
    }
    
    private func similarSection(details: Observable<MovieDetail>) -> View {
        VStackView(spacing: 16) {
            LabelView("More Like This")
                .font(UIFont.systemFont(ofSize: 18, weight: .bold))
                .color(.white)
            
            ScrollView(
                HStackView {}
                    .onReceive(details.map { [weak self] in self?.createSimilarViews(from: $0) ?? [] }) { context in
                        context.view.reset(to: context.value)
                    }
                    .spacing(16)
                    .alignment(.top)
            )
            .showHorizontalIndicator(false)
            .height(180)
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
        .onTapGesture { _ in
            print("Tapped on cast: \(cast.name)")
        }
    }
    
    private func createSimilarViews(from details: MovieDetail) -> [View] {
        guard let similarMovies = details.similar?.results.prefix(9) else { return [] }
        return similarMovies.map { createMoviePoster($0) }
    }
    
    private func createMoviePoster(_ movie: Movie) -> View {
        ImageView(nil)
            .backgroundColor(.darkGray)
            .cornerRadius(8)
            .contentMode(.scaleAspectFill)
            .clipsToBounds(true)
            .width(120)
            .height(180)
            .with { view in
                view.setImage(from: movie.posterURL)
            }
            .onTapGesture { [weak self] _ in
                if let scrollView = self?.scrollView as? UIScrollView {
                    scrollView.setContentOffset(.zero, animated: true)
                }
                self?.viewModel.selectMovie(movie)
            }
    }
}

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
        layer.colors = [UIColor.clear.cgColor, UIColor("#0A0A0A").cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
