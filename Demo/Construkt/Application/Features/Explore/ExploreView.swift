//
//  ExploreView.swift
//  Construkt
//

import UIKit
import ConstruktKit

public enum ExploreRoute {
    case movieDetail(movieId: String)
    case movieList(title: String, sectionTypeRaw: String, genreId: Int?, genreName: String?, allGenres: [Genre]?)
    case search
}

enum ExploreSection: String, SectionConfigIdentifier {
    case search
    case genres
    case collections
    case arrivals
    
    var uniqueId: String { rawValue }
}

struct ExploreView: ViewConvertable {
    
    // We bind the viewModel at initialization.
    private let viewModel = ExploreViewModel()
    
    func asViews() -> [View] {
        Screen {
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
        }
        .navigationBar {
            headerOverlay
        }
        .backgroundColor(UIColor(white: 0.04, alpha: 1)) // Neutral 950
        .onHostDidLoad {
            viewModel.loadData()
        }
        .asViews()
    }
    
    // MARK: - Sections
    
    private var genresSection: AnySection {
        AnySection(
            id: ExploreSection.genres,
            items: viewModel.$genres,
            header: Header {
                ExploreHeader(title: "Browse Genres", subtitle: nil)
            }
        ) { genre in
            AnyCell(genre, id: genre.id) { genre in
                ExploreGenreCard(genre: genre)
            }
        }
        .onRoute { (genre: ExploreGenre) -> ExploreRoute? in
            guard let genreId = Int(genre.id) else { return nil }
            let allGenres = viewModel.allGenres.compactMap {
                guard let id = Int($0.id) else { return nil as Genre? }
                return Genre(id: id, name: $0.name)
            }
            return ExploreRoute.movieList(
                title: genre.name,
                sectionTypeRaw: "categories",
                genreId: genreId,
                genreName: genre.name,
                allGenres: allGenres
            )
        }
        .layout {
            .grid(
                itemHeight: .absolute(96),
                columns: 2,
                itemInsets: .init(top: 6, leading: 6, bottom: 6, trailing: 6)
            )
            .insets(top: 12, leading: 18, bottom: 24, trailing: 18)
            .supplementaryHeader(height: .estimated(50))
        }
    }
    
    private var collectionsSection: AnySection {
        AnySection(
            id: ExploreSection.collections,
            items: viewModel.$collections,
            header: Header {
                ExploreHeader(title: "Curated Collections", subtitle: "Hand-picked by our editors")
            }
        ) { collection in
            AnyCell(collection, id: collection.id) { collection in
                ExploreCollectionCard(collection: collection)
            }
        }
        .onRoute { (collection: ExploreCollection) in
            ExploreRoute.movieDetail(movieId: collection.id)
        }
        .layout {
            .carousel(
                itemWidth: .absolute(240),
                itemHeight: .absolute(140)
            )
            .spacing(16)
            .insets(top: 0, leading: 24, bottom: 24, trailing: 24)
            .supplementaryHeader(height: .estimated(60))
        }
    }
    
    private var arrivalsSection: AnySection {
        AnySection(
            id: ExploreSection.arrivals,
            items: viewModel.$arrivals,
            header: Header {
                ExploreHeader(title: "Just Arrived", subtitle: "New titles this week")
            }
        ) { arrival in
            AnyCell(arrival, id: arrival.id) { arrival in
                ExploreArrivalRow(arrival: arrival)
            }
        }
        .onRoute { (arrival: ExploreArrival) in
            ExploreRoute.movieDetail(movieId: arrival.id)
        }
        .layout {
            .list(itemHeight: .estimated(80))
            .spacing(8)
            .insets(top: 0, leading: 24, bottom: 24, trailing: 24)
            .supplementaryHeader(height: .estimated(60))
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
                    .onRoute(ExploreRoute.search)
            }
            .padding(insets: .init(top: 12, left: 24, bottom: 12, right: 24))
        }
        .border(color: UIColor(white: 1.0, alpha: 0.05), lineWidth: 1)
        .height(48)
        .safeArea(false)
    }
}
