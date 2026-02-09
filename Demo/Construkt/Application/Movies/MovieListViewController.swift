import UIKit
import RxSwift
import RxCocoa

enum MovieListSection: String, SectionControllerIdentifier {
    case filter
    case grid
    
    var uniqueId: String { rawValue }
}

class MovieListViewController: UIViewController {
    
    private let viewModel: MovieListViewModel
    
    init(viewModel: MovieListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor("#0A0A0A")
        
        // Custom Navigation Bar adjustments if needed,
        // but assuming we are pushed on a Standard nav stack or using the builder.
        // The design shows a back button and title "Popular Movies" and a sort icon.
        // We will use standard navigation bar for simplicity or the builder approach if `view.embed` handles it.
        
        navigationItem.title = viewModel.title
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        view.embed(
            ZStackView {
                CollectionView {
                    // Section 1: Filters
                    Section(
                        id: MovieListSection.filter,
                        items: viewModel.filterItemsObservable
                    ) { item in
                        Cell(item, id: "filter-\(item.id)") { item in
                            FilterCell(title: item.title, isSelected: item.isSelected)
                        }
                        .onSelect { [weak self] _ in
                            self?.viewModel.selectGenre(item.genre)
                        }
                    }
                    .layout { _ in
                        return .layout(
                            group: .horizontally(
                                width: .estimated(80),
                                height: .absolute(36)
                            ),
                            spacing: 8,
                            insets: .init(v: 16, h: 16),
                            scrolling: .continuous
                        )
                    }
                    
                    // Section 2: Movies Grid
                    Section(
                        id:  MovieListSection.grid,
                        items: viewModel.moviesObservable,
                        header: nil
                    ) { movie in
                        Cell(movie, id: "movie-\(movie.id)") { movie in
                            MovieGridCell(movie: movie)
                        }
                        .onSelect { [weak self] movie in
                            self?.showDetail(for: movie)
                        }
                    }
                    .layout { _ in
                        let itemSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(0.5),
                            heightDimension: .fractionalHeight(1.0)
                        )
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                        
                        let groupSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalWidth(0.75) // Aspect ratio for poster
                        )
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        
                        return NSCollectionLayoutSection(group: group)
                    }
                }
                .backgroundColor(UIColor("#0A0A0A"))
                .with {
                    $0.collectionView.contentInsetAdjustmentBehavior = .always
                }
            }
            
        )
    }
    
    private func showDetail(for movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
