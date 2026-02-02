import UIKit
import RxSwift

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
            .subscribe(onNext: { state in
                switch state {
                case .initial, .loading:
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchData() {
        viewModel.loadPopularMovies()
    }
    
    private func showDetail(for movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: UI
private extension HomeViewController {
    func configureUI() {
        view.backgroundColor = UIColor("#F0F3F7")
        configureCollectionView()
    }
    
    func configureCollectionView() {
        view.addSubview(collectionView)
        refreshControl.alpha = 0
        registerPullToRefresh(onRefresh: { [weak self] in
            self?.fetchData()
        })
        registerLayout(handler: { [unowned self] _ in
            return .layout(
                group: .vertically(estimatedHeight: 180),
                spacing: 12,
                insets: .init(top: 16, leading: 16, bottom: 16, trailing: 16)
            )
        })
        collectionView.then {
            $0.contentInset.top = 16
            $0.snpMakeConstraintsLabeled { make in
                make.edges.equalTo(view.safeAreaLayoutGuide)
            }
        }
    }
}
