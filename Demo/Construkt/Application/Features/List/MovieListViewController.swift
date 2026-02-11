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
    
    deinit {
        print("MovieListViewController deinit")
        ImageCache.clear()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor("#0A0A0A")
        view.embed(
            ContainerView {
                CollectionView {
                     filterSection
                     gridSection
                }
                .pagination(model: viewModel.$paginationState) { [weak self] _ in
                    self?.viewModel.loadMore()
                }
                .backgroundColor(UIColor("#0A0A0A"))
                .with {
                    $0.collectionView.contentInset.top = 40
                }
               
                CustomNavigationBar(
                    leading: [
                        HStackView {
                            ImageView(systemName: "arrow.left")
                                .tintColor(.white)
                                .size(width: 24, height: 24)
                                .contentMode(.scaleAspectFit)
                        }
                            .onTapGesture { [weak self] _ in
                                self?.navigationController?.popViewController(animated: true)
                            }
                    ],
                    customTitle: LabelView(viewModel.title)
                        .font(.systemFont(ofSize: 18, weight: .semibold))
                        .color(.white),
                    trailing: [
                        ImageView(systemName: "arrow.up.arrow.down")
                            .tintColor(.gray)
                            .size(width: 20, height: 20)
                            .contentMode(.scaleAspectFit)
                    ]
                )
                .position(.top)
                .height(48)
                .backgroundColor(UIColor("#0A0A0A"))
            }
        )
    }
    
    private var filterSection: Section {
        Section(
            id: MovieListSection.filter,
            items: viewModel.filterItemsObservable
        ) { item in
            Cell(item, id: item.id) { item in
                GenresCell(
                    id: item.id,
                    genre: Genre(id: item.id, name: item.title),
                    isSelected: item.isSelected
                )
            }
        }
        .onSelect(on: self) { (self, item: MovieListViewModel.FilterItem) in
            self.viewModel.selectGenre(item.genre)
            self.scrollToFilter(item)
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
    }
    
    private var gridSection: Section {
        Section(
            id:  MovieListSection.grid,
            items: viewModel.moviesObservable.map { Array($0.enumerated()) },
            footer: Footer { [viewModel] in
                CenteredView {
                    ZStackView {
                        ActivityIndicator(style: .large)
                            .color(.white)
                            .animating(viewModel.$paginationState.asObservable().map { $0.isPaginating })
                    }
                    .padding(12)
                }
            }
        ) { index, movie in
            Cell(movie, id: "movie-\(movie.id)-\(index)") { movie in
                MovieGridCell(movie: movie)
            }
        }
        .onSelect(on: self) { (self, movie: Movie) in
            self.showDetail(for: movie)
        }
        .skeleton(count: 8, when: viewModel.$isLoading) {
            MovieGridCell(movie: .placeholder)
        }
        .layout { _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(0.75) // Aspect ratio for poster
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [.footer(height: .absolute(40))]
            return section
        }
    }
    
    private func showDetail(for movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func scrollToFilter(_ item: MovieListViewModel.FilterItem) {
        // Access the public (via cast or our previous change) dataSource
        guard let wrapper = view.firstSubview(ofType: CollectionViewWrapperView.self) else { return }
        
        // We need to access the data source.
        // Since `CollectionViewWrapperView` keeps it private, we either expose it or use a trick.
        // Wait, `dataSource` property in wrapper is private.
        // However, `collectionView.dataSource` returns the diffable data source object (type-erased as UICollectionViewDataSource).
        // We can cast it.
        
        guard let dataSource = wrapper.collectionView.dataSource as? CollectionDiffableDataSource else { return }
        
        // Use raw ID as requested
        let searchKey = CellController(id: item.id)
        
        if let indexPath = dataSource.indexPath(for: searchKey) {
            wrapper.collectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: true
            )
        }
    }
}
