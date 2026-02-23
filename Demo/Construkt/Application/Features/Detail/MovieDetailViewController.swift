import UIKit
import ConstruktKit

final class MovieDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = MovieViewModel()
    private let movie: Movie
    private let heroHeight: CGFloat = 450
    
    private weak var scrollView: UIScrollView?
    private weak var heroImageView: UIView?
    private weak var navBarBackgroundView: UIView?
    private weak var navBarTitleLabel: UIView?
    private var heroHeightConstraint: NSLayoutConstraint?
    // MARK: - Init
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    deinit {
        ImageCache.clear()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("#0A0A0A")
        setupUI()
        fetchDetail()
    }
    
    private func fetchDetail() {
        viewModel.selectMovie(movie)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        let details = viewModel.movieDetails.compactMap { $0 }
        let casts = viewModel.movieCasts
        
        view.subviews.forEach { $0.removeFromSuperview() }
        
        view.embed(
            ZStackView {
                ImageView(nil)
                    .contentMode(.scaleAspectFill)
                    .clipsToBounds(true)
                    .onReceive(details.map { $0.backdropURL ?? $0.posterURL }) { context in
                        context.view.setImage(from: context.value)
                    }
                    .onReceive(viewModel.isLoadingDetails) { context in
                        context.view.isHidden = context.value
                    }
                    .with { [weak self] view in
                        self?.heroImageView = view
                    }
                    .customConstraints { [weak self] view in
                        guard let self = self, let superview = view.superview else { return }
                        view.translatesAutoresizingMaskIntoConstraints = false
                        let heightConstraint = view.heightAnchor.constraint(equalToConstant: self.heroHeight)
                        self.heroHeightConstraint = heightConstraint
                        NSLayoutConstraint.activate([
                            view.topAnchor.constraint(equalTo: superview.topAnchor),
                            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                            heightConstraint
                        ])
                    }
                
                // Layer 2: Scroll Content
                ContainerView {
                    VerticalScrollView {
                        VStackView(spacing: 24) {
                            // Transparent Header Space + Content Overlay
                            MovieDetailHero(details: details, height: self.heroHeight)
                            
                            VStackView(spacing: 24) {
                                actionButtons
                                MovieStoryline(details: details)
                                MovieCast(casts: casts) { cast in
                                    print("Tapped on cast: \(cast.name)")
                                }
                                MovieSimilar(details: details) { [weak self] movie in
                                    if let scrollView = self?.scrollView as? UIScrollView {
                                        scrollView.setContentOffset(.zero, animated: true)
                                    }
                                    self?.viewModel.selectMovie(movie)
                                }
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
                    MovieDetailNavBar(
                        title: movie.title,
                        onBack: { [weak self] in self?.navigationController?.popViewController(animated: true) },
                        backgroundViewCapture: { [weak self] view in self?.navBarBackgroundView = view },
                        titleLabelCapture: { [weak self] view in self?.navBarTitleLabel = view }
                    )
                    
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
        guard let _ = heroImageView else { return }
        
        if yOffset < 0 {
            heroHeightConstraint?.constant = heroHeight + abs(yOffset)
        } else {
            heroHeightConstraint?.constant = max(0, heroHeight - yOffset)
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
}
