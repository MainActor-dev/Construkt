import UIKit
import ConstruktKit

public class SearchViewController: UIViewController {

    private let viewModel: SearchViewModel

    public init(viewModel: SearchViewModel = SearchViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("#0A0A0A")
        view.embed(body)
    }

    private var body: View {
        ZStackView {
            VStackView(spacing: 16) {
                // Search Bar
                searchBar

                // Search Results
                ZStackView {
                    // Empty State
                    LabelView("Type to search TMDB movies...")
                        .color(.lightGray)
                        .alignment(.center)
                        .font(.systemFont(ofSize: 16, weight: .medium))
                        .visible(false)
                        .onReceive(viewModel.isInitialObservable) { context in
                            context.view.isHidden = !context.value
                        }

                    LabelView("No results found.")
                        .color(.lightGray)
                        .alignment(.center)
                        .font(.systemFont(ofSize: 16, weight: .medium))
                        .visible(false)
                        .onReceive(viewModel.isEmptyObservable) { context in
                            context.view.isHidden = !context.value
                        }


                    // List
                    CollectionView {
                        Section(id: SearchSection.results, items: viewModel.moviesObservable) { movie in
                            Cell(movie, id: movie.id) { movie in
                                MovieSearchRow(movie: movie)
                            }
                        }
                        .onSelect(on: self) { (self, movie: Movie) in
                            let vc = MovieDetailViewController(movie: movie)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        .skeleton(count: 8, when: viewModel.isLoadingObservable) {
                            MovieSearchRow(movie: .placeholder)
                        }
                        .layout { _ in
                            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                            let item = NSCollectionLayoutItem(layoutSize: itemSize)
                            
                            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
                            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                            
                            let section = NSCollectionLayoutSection(group: group)
                            section.interGroupSpacing = 16
                            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
                            return section
                        }
                    }
                    .onReceive(viewModel.moviesObservable) { context in
                        context.view.isHidden = context.value.isEmpty
                    }
                }
                .backgroundColor(UIColor("#0A0A0A"))
            }
        }
    }

    private var searchBar: View {
        HStackView(spacing: 8) {
            ImageView(UIImage(systemName: "magnifyingglass"))
                .tintColor(.lightGray)
                .size(width: 20, height: 20)
            
            TextField("Search for a movie...")
                .text(bidirectionalBind: viewModel.$searchQuery)
                .with { tf in
                    tf.font = .systemFont(ofSize: 16, weight: .regular)
                    tf.textColor = .white
                    tf.attributedPlaceholder = NSAttributedString(
                        string: "Search for a movie...",
                        attributes: [.foregroundColor: UIColor.lightGray]
                    )
                }
        }
        .padding(insets: .init(top: 12, left: 16, bottom: 12, right: 16))
        .cornerRadius(12)
        .padding(insets: .init(top: 16, left: 16, bottom: 0, right: 16))
    }
}

// MARK: - Row View

struct MovieSearchRow: ViewBuilder {
    let movie: Movie

    var body: View {
        HStackView(spacing: 16) {
            ImageView(url: movie.posterURL)
                .contentMode(.scaleAspectFill)
                .backgroundColor(.darkGray)
                .width(80)
                .height(120)
                .cornerRadius(8)
                .clipsToBounds(true)
                .skeletonable(true)

            VStackView(spacing: 4) {
                LabelView(movie.title)
                    .font(.systemFont(ofSize: 16, weight: .bold))
                    .color(.white)
                    .numberOfLines(2)
                    .skeletonable(true)
                
                HStackView(spacing: 4) {
                    ImageView(UIImage(systemName: "star.fill"))
                        .tintColor(.systemYellow)
                        .size(width: 14, height: 14)
                        .skeletonable(true)
                    
                    LabelView(String(format: "%.1f", movie.voteAverage))
                        .font(.systemFont(ofSize: 14, weight: .regular))
                        .color(.systemYellow)
                        .skeletonable(true)
                }
                .alignment(.center)
                
                SpacerView()
            }
            .alignment(.leading)
            .padding(top: 8, left: 0, bottom: 8, right: 0)
        }
        .backgroundColor(UIColor("#1A1A1A"))
        .cornerRadius(12)
        .padding(12)
    }
}

enum SearchSection: String, SectionControllerIdentifier {
    case results
    
    var uniqueId: String { rawValue }
}
