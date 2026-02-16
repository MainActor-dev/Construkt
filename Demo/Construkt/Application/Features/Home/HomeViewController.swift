//
//  DeclarativeHomeViewController.swift
//  Construkt
//
//  Created by User on 2026-02-02.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    private let viewModel = MovieViewModel()
    private weak var cachedHeroContainerView: UIView?
    
    private var navBarBackgroundView: UIView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("#0A0A0A")
        view.embed(body)
        fetchData()
    }
    
    private func fetchData() {
        viewModel.loadHomeData()
    }
    
    // MARK: - Layout
    
    var body: View {
        return ZStackView {
            CollectionView {
                heroSection
                genresSection
                popularSection
                upcomingSection
                topRatedSection
            }
            .emptyState(when: viewModel.isEmptyObservable) { [weak self] in
                EmptyView(
                    title: "No movies found",
                    subtitle: "Check your connection.",
                    buttonTitle: "Retry",
                    onAction: { [weak self] in self?.fetchData() }
                )
            }
            .backgroundColor(UIColor("#0A0A0A"))
            .with {
                $0.collectionView.contentInsetAdjustmentBehavior = .never
                $0.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                $0.collectionView.showsVerticalScrollIndicator = false
            }
            .onRefresh(viewModel.isNowPlayingLoading) { [weak self] in
                self?.fetchData()
            }
            .onScroll { [weak self] scrollView in
                self?.handleNavBarScroll(scrollView)
            }
            
            HomeNavigationBar(
                isLoading: viewModel.isNowPlayingLoading,
                onBackgroundReference: { [weak self] view in
                    self?.navBarBackgroundView = view
                }
            )
        }
    }
    
    // MARK: - Sections
    
    private var heroSection: Section {
        Section(id: HomeSection.hero, items: viewModel.nowPlayingMovies) { movie in
            Cell<HeroCollectionCell, Movie>(movie, id: "hero-\(movie.id)") { cell, movie in
                cell.configure(with: movie)
            }
        }
        .onSelect(on: self) { (me, movie: Movie) in
            me.showDetail(for: movie)
        }
        .layout { [weak self] _ in
            let layout = HomeSection.hero.layout
            layout.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) in
                self?.handleHeroScroll(items: items, offset: offset, env: env)
            }
            return layout
        }
        .skeleton(count: 1, when: viewModel.isNowPlayingLoading) {
            Modified(HeroContentView()) { $0.configure(with: .placeholder) }
        }
    }
    
    private var genresSection: Section {
        Section(
            id: HomeSection.categories,
            items: viewModel.genres,
            header: Header {
                StandardHeader(title: "Genres", actionTitle: nil)
            }
        ) { genre in
            Cell(genre, id: "genre-\(genre.id)") { genre in
                GenresCell(id: genre.id, genre: genre)
            }
        }
        .onSelect(on: self) { (self, genre: Genre) in
            self.showMovieList(for: .categories, selectedGenre: genre)
        }
        .skeleton(
            count: 6,
            when: viewModel.isLoadingGenres,
            includeSupplementary: true
        ) {
            GenresCell(id: -2, genre: .placeholder)
        }
        .layout { _ in
            return HomeSection.categories.layout
        }
    }
    
    private var popularSection: Section {
        Section(
            id: HomeSection.popular,
            items: viewModel.popularSectionMovies,
            header: Header {
                StandardHeader(title: "Popular Now", actionTitle: "See All") { [weak self] in
                    self?.showMovieList(for: .popular)
                }
            }
        ) { movie in
            Cell(movie, id: "popular-\(movie.id)") { movie in
                PosterCell(movie: movie)
            }
        }
        .onSelect(on: self) { (me, movie: Movie) in
            me.showDetail(for: movie)
        }
        .layout { _ in
            return HomeSection.popular.layout
        }
        .skeleton(
            count: 4,
            when: viewModel.isPopularSectionLoading,
            includeSupplementary: true
        ) {
            PosterCell(movie: .placeholder)
        }
    }
    
    private var upcomingSection: Section {
        Section(
            id: HomeSection.upcoming,
            items: viewModel.upcomingMovies,
            header: Header {
                StandardHeader(title: "Upcoming", actionTitle: "See All") { [weak self] in
                    self?.showMovieList(for: .upcoming)
                }
            }
        ) { movie in
            Cell(movie, id: "upcoming-\(movie.id)") { movie in
                UpcomingCell(movie: movie)
            }
        }
        .onSelect(on: self) { (me, movie: Movie) in
            me.showDetail(for: movie)
        }
        .layout { _ in
            return HomeSection.upcoming.layout
        }
        .skeleton(
            count: 2,
            when: viewModel.isUpcomingLoading,
            includeSupplementary: true
        ) {
            UpcomingCell(movie: .placeholder)
        }
    }
    
    private var topRatedSection: Section {
        Section(
            id: HomeSection.topRated,
            items: viewModel.topRatedMovies.map { Array($0.enumerated()) },
            header: Header {
                StandardHeader(title: "Top Rated", actionTitle: nil)
            }
        ) { (index, movie) in
            if index == 5 {
                Cell("This is an ad") { text in AdsCell(text: text) }
            }
            Cell(movie, id: "top-\(movie.id)") { movie in
                TopRatedCell(index: index + 1, movie: movie)
            }
        }
        .onSelect(on: self) { (me, movie: Movie) in
            me.showDetail(for: movie)
        }
        .onSelect(on: self) { (me, ad: String) in
            print("Ad Selected: \(ad)")
        }
        .layout { _ in
            return HomeSection.topRated.layout
        }
        .skeleton(count: 3, when: viewModel.isTopRatedLoading) {
            TopRatedCell(index: 0, movie: .placeholder)
        }
    }
}

// MARK: - Navigation

extension HomeViewController {
    private func showDetail(for movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showMovieList(
        for section: HomeSection,
        selectedGenre: Genre? = nil
    ) {
        let title: String
        switch section {
        case .categories:
            if let selectedGenre {
                title = selectedGenre.name
            } else {
                title = "Genre"
            }
        case .popular: title = "Popular Movies"
        case .upcoming: title = "Upcoming Movies"
        case .topRated: title = "Top Rated Movies"
        default: title = "Movies"
        }
        
        let viewModel = MovieListViewModel(
            title: title,
            sectionType: section,
            genres: viewModel.currentGenres,
            selectedGenre: selectedGenre
        )
        let vc = MovieListViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Helpers

extension HomeViewController {
    private func handleHeroScroll(items: [NSCollectionLayoutVisibleItem], offset: CGPoint, env: NSCollectionLayoutEnvironment) {
        let containerWidth = env.container.contentSize.width
        let visibleRectCenter = offset.x + containerWidth / 2.0
        
        // We need to find the actual cells to update them
        guard let collectionView = view.firstSubview(ofType: CollectionViewWrapperView.self) else { return }
        
        let heroCells: [HeroCollectionCell]
        
        // Cache the container view to avoid expensive recursive searches
        // Also validate that the cached container is still effectively in the hierarchy (e.g. has a window)
        if let container = cachedHeroContainerView, container.window != nil {
            heroCells = container.subviews.compactMap { $0 as? HeroCollectionCell }
        } else {
            // Initial search or cache invalidation
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
        
        // Stretchy Header Logic
        let y = offset.y
        if y < 0 {
             items.forEach { item in
                 // Scale height to fill the pull-down area
                 // Original Height = 550
                 let originalHeight: CGFloat = 550
                 let newHeight = originalHeight + abs(y)
                 let scale = newHeight / originalHeight
                 
                 // Translate up to pin to top
                 // Center Y needs to move up by (difference in height / 2) + y
                 // Actually, if we scale Y, it scales from center.
                 // We want top edge to be at `y`.
                 
                 let translationY = y / 2
                 item.alpha = 1.0
                 item.transform = CGAffineTransform(translationX: 0, y: translationY)
                     .scaledBy(x: 1, y: scale)
             }
        } else {
            // Scroll Up: Fade Effect
            // Fade out as we scroll up
            let fadeRange: CGFloat = 350
            let alpha = max(0, 1 - (y / fadeRange))
            
            items.forEach { item in
                item.alpha = alpha
                item.transform = .identity
            }
        }
    }
    
    private func findAllHeroCells(in view: UIView) -> [HeroCollectionCell] {
        var cells: [HeroCollectionCell] = []
        if let cell = view as? HeroCollectionCell { cells.append(cell) }
        for subview in view.subviews { cells.append(contentsOf: findAllHeroCells(in: subview)) }
        return cells
    }
    
    private func handleNavBarScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        // Fade in between 0 and 100pt scroll
        let alpha = min(1.0, max(0.0, y / 100.0))
        navBarBackgroundView?.alpha = alpha
    }
}
