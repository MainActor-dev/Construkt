//
//  DeclarativeHomeViewController.swift
//  Construkt
//
//  Created by User on 2026-02-02.
//

import UIKit
import RxSwift

import RxSwift


class HomeViewController: UIViewController {
    
    private let viewModel = MovieViewModel()
    private let disposeBag = DisposeBag()
    private weak var cachedHeroContainerView: UIView?
    
    var body: View {
        CollectionView {
            heroSection
            categorySection
            popularSection
            upcomingSection
            topRatedSection
        }
        .emptyState(when: viewModel.isEmptyObservable) {
           EmptyView(
            title: "No movies found",
            subtitle: "Check your connection.",
            buttonTitle: "Retry"
           )
        }
        .backgroundColor(UIColor("#0A0A0A"))
        .with {
            $0.collectionView.contentInsetAdjustmentBehavior = .never
            $0.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("#0A0A0A")
        view.embed(body)
        fetchData()
    }
    
    private func fetchData() {
        viewModel.loadHomeData()
    }
    
    private func showDetail(for movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Sections
    private var heroSection: Section {
        Section(id: HomeSection.hero, items: viewModel.nowPlayingMoviesObservable) { movie in
            Cell<HeroCollectionCell, Movie>(movie, id: "hero-\(movie.id)") { cell, movie in
                cell.configure(with: movie)
            }
            .onSelect { [weak self] movie in
                self?.showDetail(for: movie)
            }
        }
        .layout { [weak self] _ in
            let layout = HomeSection.hero.layout
            layout.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) in
                self?.handleHeroScroll(items: items, offset: offset, env: env)
            }
            return layout
        }
        .skeleton(count: 1, when: viewModel.isNowPlayingLoadingObservable) {
            Modified(HeroContentView()) { $0.configure(with: .placeholder) }
        }
    }
    
    private func handleHeroScroll(items: [NSCollectionLayoutVisibleItem], offset: CGPoint, env: NSCollectionLayoutEnvironment) {
        let containerWidth = env.container.contentSize.width
        // Calculate center of the visible rect based on scroll offset
        let visibleRectCenter = offset.x + containerWidth / 2.0
        
        // We need to find the actual cells to update them
        guard let collectionView = view.firstSubview(ofType: CollectionViewWrapperView.self) else { return }
        
        
        let heroCells: [HeroCollectionCell]
        
        // Cache the container view to avoid expensive recursive searches
        if let container = cachedHeroContainerView {
            heroCells = container.subviews.compactMap { $0 as? HeroCollectionCell }
        } else {
            // Initial search
            heroCells = findAllHeroCells(in: collectionView)
            if let firstCell = heroCells.first {
                cachedHeroContainerView = firstCell.superview
            }
        }
        
        // Map visible items to their progress
        for item in items {
            // Distance of item center from viewport center
            let distanceFromCenter = abs(item.center.x - visibleRectCenter)
            
            // Normalize distance: 0 at center, 1 at edge
            let progress = min(1.0, distanceFromCenter / (containerWidth / 2.0))
            
            // Match layout item to cell by X position in the orthogonal scroll view
            if let matchedCell = heroCells.first(where: { abs($0.center.x - item.center.x) < 2.0 }) {
                 matchedCell.heroContentView.setScrollProgress(progress)
            }
        }
    }
    
    private func updateHeroAnimation(hidden: Bool) {
         // Deprecated but kept for safety
    }
    
    private func findAllHeroCells(in view: UIView) -> [HeroCollectionCell] {
        var cells: [HeroCollectionCell] = []
        if let cell = view as? HeroCollectionCell {
            cells.append(cell)
        }
        for subview in view.subviews {
            cells.append(contentsOf: findAllHeroCells(in: subview))
        }
        return cells
    }
    
    
    private var categorySection: Section {
        Section(
            id: HomeSection.categories,
            items: viewModel.genresObservable,
            header: {
                Header {
                    StandardHeader(title: "Categories", actionTitle: nil)
                }
            }
        ) { genre in
            Cell(genre, id: "genre-\(genre.id)") { genre in
                CategoryCell(genre: genre)
            }
        }
        .layout { _ in
            return HomeSection.categories.layout
        }
    }
    
    private var popularSection: Section {
        Section(
            id: HomeSection.popular,
            items: viewModel.popularSectionMoviesObservable,
            header: {
                Header {
                    StandardHeader(title: "Popular Now", actionTitle: "See All", onAction: {
                        print("See All Tapped")
                    })
                }
            }
        ) { movie in
            Cell(movie, id: "popular-\(movie.id)") { movie in
                PosterCell(movie: movie)
            }
            .onSelect { [weak self] movie in
                self?.showDetail(for: movie)
            }
        }
        .layout { _ in
            return HomeSection.popular.layout
        }
        .skeleton(count: 4, when: viewModel.isPopularSectionLoadingObservable) {
            PosterCell(movie: .placeholder)
        }
    }
    
    private var upcomingSection: Section {
        Section(
            id: HomeSection.upcoming,
            items: viewModel.upcomingMoviesObservable,
            header: {
                Header {
                    StandardHeader(title: "Upcoming", actionTitle: "See All", onAction: {
                        print("See All Tapped")
                    })                }
            }
        ) { movie in
            Cell(movie, id: "upcoming-\(movie.id)") { movie in
                UpcomingCell(movie: movie)
            }
            .onSelect { [weak self] movie in
                self?.showDetail(for: movie)
            }
        }
        .layout { _ in
            return HomeSection.upcoming.layout
        }
        .skeleton(count: 2, when: viewModel.isUpcomingLoadingObservable) {
            UpcomingCell(movie: .placeholder)
        }
    }
    
    private var topRatedSection: Section {
        Section(
            id: HomeSection.topRated,
            items: viewModel.topRatedMoviesObservable.map { Array($0.enumerated()) },
            header: {
                Header {
                    StandardHeader(title: "Top Rated", actionTitle: nil)
                }
            }
        ) { (index, movie) in
            Cell(movie, id: "top-\(movie.id)") { movie in
                TopRatedCell(index: index + 1, movie: movie)
            }
            .onSelect { [weak self] movie in
                self?.showDetail(for: movie)
            }
        }
        .layout { _ in
            return HomeSection.topRated.layout
        }
        .skeleton(count: 3, when: viewModel.isTopRatedLoadingObservable) {
            TopRatedCell(index: 0, movie: .placeholder)
        }
    }
}

// MARK: - Components

struct TopRatedCell: ViewBuilder {
    let index: Int
    let movie: Movie
    
    var body: View {
        ZStackView {
            HStackView {
                // Ranking Number
                LabelView(index > 0 ? "\(index)" : "")
                    .font(.systemFont(ofSize: 30, weight: .bold))
                    .color(UIColor.darkGray.withAlphaComponent(0.5)) // Faded number
                    .alignment(.center)
                    .width(40)
                
                // Poster
                ImageView(url: movie.posterURL)
                    .skeletonable(true)
                    .contentMode(.scaleAspectFill)
                    .backgroundColor(.darkGray)
                    .clipsToBounds(true)
                    .cornerRadius(8)
                    .width(60, priority: .required)
                    .height(90)
                
                // Info
                VStackView(spacing: 4) {
                    LabelView(movie.title)
                        .font(.systemFont(ofSize: 16, weight: .semibold))
                        .color(.white)
                        .numberOfLines(2)
                        .skeletonable(true)
                    HStackView(spacing: 4) {
                        ImageView(UIImage(systemName: "star.fill"))
                            .tintColor(.systemYellow)
                            .size(width: 12, height: 12)
                        HStackView {
                            LabelView(String(format: "%.1f", movie.voteAverage))
                                .font(.systemFont(ofSize: 14))
                                .color(.systemYellow)
                            LabelView("DRAMA") // Placeholder genre
                                .font(.systemFont(ofSize: 12))
                                .color(.gray)
                                .padding(insets: .init(top: 0, left: 8, bottom: 0, right: 0))
                            SpacerView()
                        }
                        .alignment(.center)
                    }
                    .alignment(.center)
                    .skeletonable(true)
                    SpacerView()
                }
            }
        }
        .padding(12)
        .backgroundColor(UIColor(white: 1.0, alpha: 0.05))
        .cornerRadius(12)
        .border(color: UIColor(white: 1.0, alpha: 0.1), lineWidth: 1)
    }
}

struct UpcomingCell: ViewBuilder {
    let movie: Movie
    
    var body: View {
        ZStackView {
            ImageView(url: movie.backdropURL)
                .skeletonable(true)
                .contentMode(.scaleAspectFill)
                .backgroundColor(.darkGray)
                .clipsToBounds(true)
            GradientView(colors: [.clear, .black.withAlphaComponent(0.8)])
                .height(80)
            VStackView {
                SpacerView()
                ZStackView {
                    VStackView(spacing: 2) {
                        SpacerView()
                        LabelView("COMING JUNE 24") // Placeholder
                            .font(.systemFont(ofSize: 10, weight: .bold))
                            .color(.white)
                            .backgroundColor(UIColor.black.withAlphaComponent(0.5))
                            .cornerRadius(4)
                            .padding(h: 4, v: 2)
                        LabelView(movie.title)
                            .font(.systemFont(ofSize: 16, weight: .semibold))
                            .color(.white)
                            .numberOfLines(2)
                            .skeletonable(true)
                    }
                    .alignment(.leading)
                }
                .padding(h: 12, v: 8)
            }
        }
        .cornerRadius(8)
        .clipsToBounds(true)
    }
}

struct StandardHeader: ViewBuilder {
    let title: String
    let actionTitle: String?
    var onAction: (() -> Void)? = nil
    
    var body: View {
        HStackView() {
            LabelView(title)
                .font(.systemFont(ofSize: 18, weight: .semibold))
                .color(.white)
            
            SpacerView()
            
            if let action = actionTitle {
                ButtonView(action) { _ in onAction?() }
                    .font(.systemFont(ofSize: 14))
                    .color(.lightGray)
            }
        }
        .alignment(.center)
    }
}

struct CategoryCell: ViewBuilder {
    let genre: Genre
    
    var body: View {
        ZStackView {
            HStackView(spacing: 8) {
                LabelView(genre.name)
                    .font(.systemFont(ofSize: 14, weight: .medium))
                    .color(.white)
                    .alignment(.center)
                    .padding(insets: .init(top: 8, left: 16, bottom: 8, right: 16))
            }
        }
        .backgroundColor(UIColor(white: 1.0, alpha: 0.1)) // Glassy/Dark look
        .cornerRadius(20) // Pill shape
        .border(color: UIColor(white: 1.0, alpha: 0.2), lineWidth: 1)
    }
}


// MARK: - Components


