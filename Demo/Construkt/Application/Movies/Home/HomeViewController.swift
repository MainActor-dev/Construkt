import UIKit
import RxSwift

enum HomeSection: String, SectionControllerIdentifier {
    case hero
    case popular
    
    var uniqueId: String { rawValue }
    
    var layout: NSCollectionLayoutSection {
        switch self {
        case .hero:
            return .layout(
                group: .vertically(height: .absolute(480)),
                scrolling: .groupPagingCentered
            )
        case .popular:
            return .layout(
                group: .horizontally(
                    estimatedWidth: 128,
                    estimatedHeight: 231,
                    insets: .init(top: 0, leading: 16, bottom: 0, trailing: 16)
                )
            )
        }
    }
}

struct HeroView: ViewBuilder {
    var body: View {
        ZStackView {
            ImageView(nil)
                .backgroundColor(.red)
                .skeletonable(true)
            VStackView {
                SpacerView()
                    .backgroundColor(.blue)
                VStackView {
                    SpacerView(1)
                    HStackView {
                        LabelView("TRENDING NEW")
                            .font(.systemFont(ofSize: 10, weight: .regular))
                        LabelView("0.5")
                            .font(.systemFont(ofSize: 10, weight: .regular))
                    }
                    LabelView("Midnight in Cell Number 9")
                        .font(.systemFont(ofSize: 36, weight: .bold))
                    SpacerView(16)
                }
                .spacing(16)
                .padding(h: 16, v: 0)
            }
            .distribution(.fillEqually)
        }
    }
}

final class HeroCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        embed(HeroView())
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}

final class HomeViewController: CollectionListViewController {
    
    private let viewModel = MovieViewModel()
    private let disposeBag = DisposeBag()
    
    private var mainView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
        fetchData()
    }
    
    private func observe() {
        viewModel.$state
            .observe(on: MainScheduler.asyncInstance)
            .delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .initial, .loading:
                    reloadList(state: .loading(1))
                case .loaded(let movies):
                    reloadList(movies: movies)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchData() {
        viewModel.loadPopularMovies()
    }
    
    func reloadList(
        movies: [Movie] = [],
        state: CellControllerState = .loaded
    ) {
        let section = makeSection(id: .hero, movies: movies, state: state)
        dataSource.display([section])
    }
    
    private func makeSection(
        id: HomeSection,
        movies: [Movie] = [],
        state: CellControllerState = .loaded
    ) -> SectionController {
        return SectionController(
            identifier: id,
            items: movies,
            state: state,
            cellConfiguration: { (cell: HeroCell, movie) in
                
            },
            didSelect: { movie in
                print("[BEKA] didSelect", movie)
            }
        )
    }
    
    private func showDetail(for movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: UI
private extension HomeViewController {
    func configureUI() {
        view.backgroundColor = UIColor("#0A0A0A")
        configureCollectionView()
    }
    
    func configureCollectionView() {
        view.addSubview(collectionView)
        refreshControl.alpha = 0
        registerPullToRefresh(onRefresh: { [weak self] in
            self?.fetchData()
        })
        registerLayout(handler: { identifier in
            return HomeSection(rawValue: identifier)?.layout
        })
        collectionView.then {
            $0.snpMakeConstraintsLabeled { make in
                make.edges.equalToSuperview()
            }
            $0.contentInsetAdjustmentBehavior = .never
        }
    }
}
