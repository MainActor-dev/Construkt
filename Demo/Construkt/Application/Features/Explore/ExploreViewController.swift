import UIKit
import ConstruktKit

enum ExploreSection: String, SectionControllerIdentifier {
    case search
    case genres
    case collections
    case arrivals
    
    var uniqueId: String { rawValue }
}

class ExploreViewController: UIViewController {
    
    public enum Action {
        case movieSelected(String)
        case genreSelected(ExploreGenre)
        case searchSelected
    }
    
    public var onAction: ((Action) -> Void)?
    
    private let viewModel = ExploreViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.04, alpha: 1) // Neutral 950
        
        viewModel.loadData()
        
        view.embed(
            ZStackView {
                // Background gradients
                CircleView()
                    .backgroundColor(UIColor.systemIndigo.withAlphaComponent(0.05))
                    .size(width: 250, height: 250)
                    .position(.topLeft)
                    .margins(top: 0, left: 40)
                
                CircleView()
                    .backgroundColor(UIColor.systemPink.withAlphaComponent(0.05))
                    .size(width: 320, height: 320)
                    .position(.bottomRight)
                    .margins(bottom: 160, right: 0)
                
                // Main Collection View
                CollectionView {
                    genresSection
                    collectionsSection
                    arrivalsSection
                }
                .with {
                    $0.collectionView.contentInset.top = 60
                    $0.collectionView.showsVerticalScrollIndicator = false
                }
                
                // Fixed Header
                headerOverlay
            }
        )
    }
    
    // MARK: - Sections
    
    private var searchSection: Section {
        Section(id: ExploreSection.search, items: ["search_bar"]) { _ in
            Cell("search_bar", id: "search_bar") { _ in
                HStackView {
                    ExploreSearchBar(viewModel: self.viewModel)
                }
                .padding(top: 12, left: 24, bottom: 12, right: 24)
            }
        }
        .layout { env in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
            return NSCollectionLayoutSection(group: group)
        }
    }
    
    private var genresSection: Section {
        Section(
            id: ExploreSection.genres,
            items: viewModel.$genres,
            header: Header {
                ExploreHeader(title: "Browse Genres", subtitle: nil)
            }
        ) { genre in
            Cell(genre, id: genre.id) { genre in
                ExploreGenreCard(genre: genre)
            }
        }
        .onSelect(on: self) { (me, genre: ExploreGenre) in
            me.showMovieList(for: genre)
        }
        .layout { env in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(96))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(96))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 18, bottom: 24, trailing: 18)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
    
    private var collectionsSection: Section {
        Section(
            id: ExploreSection.collections,
            items: viewModel.$collections,
            header: Header {
                ExploreHeader(title: "Curated Collections", subtitle: "Hand-picked by our editors")
            }
        ) { collection in
            Cell(collection, id: collection.id) { collection in
                ExploreCollectionCard(collection: collection)
            }
        }
        .onSelect(on: self) { (me, collection: ExploreCollection) in
            me.showDetail(for: collection.id)
        }
        .layout { env in
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(240), heightDimension: .absolute(140))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(240), heightDimension: .absolute(140))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 24, trailing: 24)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
    
    private var arrivalsSection: Section {
        Section(
            id: ExploreSection.arrivals,
            items: viewModel.$arrivals,
            header: Header {
                ExploreHeader(title: "Just Arrived", subtitle: "New titles this week")
            }
        ) { arrival in
            Cell(arrival, id: arrival.id) { arrival in
                ExploreArrivalRow(arrival: arrival)
            }
        }
        .onSelect(on: self) { (me, arrival: ExploreArrival) in
            me.showDetail(for: arrival.id)
        }
        .layout { env in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 24, trailing: 24)
            section.interGroupSpacing = 8
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
    
    // MARK: - Components
    
    private var headerOverlay: View {
        ZStackView {
            BlurView(style: .dark)
            HStackView {
                LabelView("Explore")
                    .font(.systemFont(ofSize: 32, weight: .semibold))
                    .color(.white)
                SpacerView()
                ImageView(UIImage(systemName: "magnifyingglass"))
                    .tintColor(.white)
                    .size(width: 24, height: 24)
                    .contentMode(.scaleAspectFit)
                    .onTapGesture { [weak self] _ in self?.showSearch() }
            }
            .padding(insets: .init(top: 12, left: 24, bottom: 12, right: 24))
        }
        .border(color: UIColor(white: 1.0, alpha: 0.05), lineWidth: 1)
        .height(48)
        .position(.top)
        .safeArea(false)
    }
}

// MARK: - Navigation

extension ExploreViewController {
    private func showDetail(for id: String) {
        onAction?(.movieSelected(id))
    }
    
    private func showMovieList(for genre: ExploreGenre) {
        onAction?(.genreSelected(genre))
    }
    
    private func showSearch() {
        onAction?(.searchSelected)
    }
}

