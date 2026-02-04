//
//  DeclarativeHomeViewController.swift
//  Construkt
//
//  Created by User on 2026-02-02.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController {
    
    private let viewModel = MovieViewModel()
    private let disposeBag = DisposeBag()
    private weak var cachedHeroContainerView: UIView?
    
    private var navBarBackgroundView: UIView?
    
    var body: View {
        ZStackView {
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
            .onRefresh(viewModel.isNowPlayingLoadingObservable) { [weak self] in
                self?.fetchData()
            }
            .onScroll { [weak self] scrollView in
                self?.handleNavBarScroll(scrollView)
            }
            navigationBar
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
    
    // MARK: - Scroll Handling
    
    private func handleNavBarScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        // Fade in between 0 and 100pt scroll
        let alpha = min(1.0, max(0.0, y / 100.0))
        navBarBackgroundView?.alpha = alpha
    }
    
    // MARK: - Navigation Bar
    private var navigationBar: View {
        ZStackView {
            // Gradient Background
            GradientView(colors: [.black.withAlphaComponent(0.8), .black.withAlphaComponent(0.3)])
                .height(100)
                .alpha(0) // Start transparent
                .reference(&navBarBackgroundView)
            
            // Navbar Content
            CustomNavigationBar(
                customTitle: LabelView("LUMIERE")
                    .font(.systemFont(ofSize: 24, weight: .bold))
                    .padding(insets: .init(top: 0, left: 4, bottom: 0, right: 0))
                    .color(bind: viewModel.isNowPlayingLoadingObservable.map { isLoading in
                        return isLoading ? .gray : .white
                    }),
                trailing: [
                    ImageView(UIImage(systemName: "magnifyingglass"))
                        .tintColor(.white)
                        .size(width: 24, height: 24)
                        .contentMode(.scaleAspectFit),
                    ImageView(UIImage(systemName: "person.crop.circle.fill"))
                        .tintColor(.gray)
                        .size(width: 32, height: 32)
                        .cornerRadius(16)
                        .clipsToBounds(true)
                        .backgroundColor(UIColor(white: 1.0, alpha: 0.2))
                        .border(color: .white, lineWidth: 1)
                ]
            )
        }
        .position(.top) // Pin to top without filling screen
        .height(100) // Explicit height
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
    
    private var genresSection: Section {
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
                GenresCell(genre: genre)
            }
        }
        .skeleton(
            count: 6,
            when: viewModel.isLoadingGenres,
            includeSupplementary: true
        ) {
            GenresCell(genre: .placeholder)
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
                    StandardHeader(title: "Popular Now", actionTitle: "See All") {
                        print("See All Tapped")
                    }
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
        .skeleton(
            count: 4,
            when: viewModel.isPopularSectionLoadingObservable,
            includeSupplementary: true
        ) {
            PosterCell(movie: .placeholder)
        }
    }
    
    private var upcomingSection: Section {
        Section(
            id: HomeSection.upcoming,
            items: viewModel.upcomingMoviesObservable,
            header: {
                Header {
                    StandardHeader(title: "Upcoming", actionTitle: "See All") {
                        print("See All Tapped")
                    }
                }
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
        .skeleton(
            count: 2,
            when: viewModel.isUpcomingLoadingObservable,
            includeSupplementary: true
        ) {
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

// MARK: - Helpers

private extension HomeViewController {
    private func handleHeroScroll(items: [NSCollectionLayoutVisibleItem], offset: CGPoint, env: NSCollectionLayoutEnvironment) {
        let containerWidth = env.container.contentSize.width
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
    
    private func findAllHeroCells(in view: UIView) -> [HeroCollectionCell] {
        var cells: [HeroCollectionCell] = []
        if let cell = view as? HeroCollectionCell { cells.append(cell) }
        for subview in view.subviews { cells.append(contentsOf: findAllHeroCells(in: subview)) }
        return cells
    }
}
