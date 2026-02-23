import UIKit

enum MovieListSection: String, SectionControllerIdentifier {
    case filter
    case grid
    
    var uniqueId: String { rawValue }
}

class MovieListViewController: UIViewController {
    
    private let viewModel: MovieListViewModel
    private var filterCollectionViewWrapper: CollectionViewWrapperView?
    
    init(viewModel: MovieListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observe()
    }
    
    deinit {
        print("MovieListViewController deinit")
        ImageCache.clear()
    }
    
    private func observe() {
        viewModel.$selectedGenre
            .compactMap { $0 }
            .distinctUntilChanged()
            .observe(on: .main) { [weak self] item in
                self?.scrollToFilter(item.id)
            }
            .store(in: cancelBag)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor("#0A0A0A")
        view.embed(
            ZStackView {
                VStackView {
                    CollectionView {
                        filterSection
                    }
                    .reference(&filterCollectionViewWrapper)
                    .backgroundColor(UIColor("#0A0A0A"))
                    .height(56)
                    .zIndex(100)
                    .clipsToBounds(true)

                    CollectionView {
                         gridSection
                    }
                    .pagination(model: viewModel.$paginationState) { [weak self] _ in
                        self?.viewModel.loadMore()
                    }
                    .onRefresh(viewModel.$isLoading) { [weak self] in
                        self?.viewModel.refresh()
                    }
                }
                .padding(top: 40)
                
                MovieListNavBar(title: viewModel.title, onTapBack: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                })
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
        }
        .layout { _ in
            return .layout(
                group: .horizontally(
                    width: .estimated(100),
                    height: .absolute(40)
                ),
                spacing: 12,
                insets: .init(v: 8, h: 16),
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
                            .animating(viewModel.$paginationState.map { $0.isPaginating })
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
                heightDimension: .fractionalWidth(0.75)
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
    
    private func scrollToFilter(_ id: Int) {
        guard let wrapper = filterCollectionViewWrapper,
              let dataSource = wrapper.collectionView.dataSource as? CollectionDiffableDataSource else { return }
        
        if dataSource.snapshot().numberOfItems == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.scrollToFilter(id)
            }
            return
        }
        
        let searchKey = CellController(id: id)
        if let indexPath = dataSource.indexPath(for: searchKey) {
            wrapper.collectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: true
            )
        }
    }
}
