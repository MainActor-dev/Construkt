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
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor("#0A0A0A")
        
        // Define CollectionView
        let moviesList: View = CollectionView {
            // Section 1: Filters
            Section(
                id: MovieListSection.filter,
                items: viewModel.filterItemsObservable
            ) { item in
                Cell(item, id: "filter-\(item.id)") { item in
                    GenresCell(
                        genre: Genre(id: item.id, name: item.title),
                        isSelected: item.isSelected
                    )
                }
                .onSelect { [weak self] _ in
                    self?.viewModel.selectGenre(item.genre)
                }
            }
            .layout { _ in
                return .layout(
                    group: .horizontally(
                        width: .estimated(100),
                        height: .absolute(40)
                    ),
                    spacing: 12,
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
            $0.collectionView.contentInset.top = 40
        }
        
        // Define Custom Navigation Bar
        let navBar: View = CustomNavigationBar(
            leading: [
                HStackView {
                    ImageView(systemName: "arrow.left")
                        .tintColor(.white)
                        .size(width: 24, height: 24)
                        .contentMode(.scaleAspectFit)
                }
                .padding(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)) // Increase hit area
                .onTapGesture { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            ] as [View],
            customTitle: LabelView(viewModel.title)
                .font(.systemFont(ofSize: 18, weight: .semibold))
                .color(.white),
            trailing: [
                ImageView(systemName: "arrow.up.arrow.down")
                    .tintColor(.gray)
                    .size(width: 20, height: 20)
                    .contentMode(.scaleAspectFit)
            ] as [View]
        )
        .position(.top)
        .height(48)
        .backgroundColor(UIColor("#0A0A0A"))
        
        // Embed in Container
        view.embed(
            ContainerView {
                moviesList
                navBar
            }
        )
    }
    
    private func showDetail(for movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
