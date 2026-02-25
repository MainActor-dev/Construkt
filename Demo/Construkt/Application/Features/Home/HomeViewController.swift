//
//  DeclarativeHomeViewController.swift
//  Construkt
//
//  Created by User on 2026-02-02.
//

import UIKit

import ConstruktKit

class HomeViewController: UIViewController {
    
    public enum Action {
        case movieSelected(Movie)
        case listSelected(HomeSection, Genre?, [Genre]?)
        case searchSelected
    }
    
    public var onAction: ((Action) -> Void)?
    
    private let viewModel = MovieViewModel()
    private weak var cachedCollectionView: UICollectionView?
    
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
                },
                onSearchTap: { [weak self] in
                    self?.onAction?(.searchSelected)
                }
            )
        }
        .margins(bottom: 100)
    }
    
    // MARK: - Sections
    
    private var heroSection: Section {
        Section(id: HomeSection.hero, items: viewModel.nowPlayingMovies) { movie in
            Cell(movie, id: "hero-\(movie.id)") { movie in
                Modified(HeroContentView()) { view in
                    view.configure(with: movie)
                }
            }
        }
        .onSelect(on: self) { (me, movie: Movie) in
            me.showDetail(for: movie)
        }
        .layout { [weak self] _ in
            HomeSection.hero.layout.then { layout in
                layout.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) in
                    self?.handleHeroScroll(items: items, offset: offset, env: env)
                }
            }
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
            HomeSection.categories.layout
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
            HomeSection.popular.layout
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
            HomeSection.upcoming.layout
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
            HomeSection.topRated.layout
        }
        .skeleton(count: 3, when: viewModel.isTopRatedLoading) {
            TopRatedCell(index: 0, movie: .placeholder)
        }
    }
}

// MARK: - Navigation

extension HomeViewController {
    private func showDetail(for movie: Movie) {
        onAction?(.movieSelected(movie))
    }
    
    private func showMovieList(
        for section: HomeSection,
        selectedGenre: Genre? = nil
    ) {
        onAction?(.listSelected(section, selectedGenre, viewModel.currentGenres))
    }
}

// MARK: - Helpers

extension HomeViewController {
    private func handleHeroScroll(
        items: [NSCollectionLayoutVisibleItem],
        offset: CGPoint,
        env: NSCollectionLayoutEnvironment
    ) {
        let containerWidth = env.container.contentSize.width
        let visibleRectCenter = offset.x + containerWidth / 2.0
        
        let collectionView: UICollectionView
        
        if let cached = cachedCollectionView {
            collectionView = cached
        } else if let wrapper = view.firstSubview(ofType: CollectionViewWrapperView.self),
                  let found = wrapper.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            collectionView = found
            cachedCollectionView = found
        } else {
            return
        }
        
        for item in items {
            let distanceFromCenter = abs(item.center.x - visibleRectCenter)
            let progress = min(1.0, distanceFromCenter / (containerWidth / 2.0))
            
            if let cell = collectionView.cellForItem(at: item.indexPath),
               let heroView = findAllHeroViews(in: cell).first {
                heroView.setScrollProgress(progress)
            }
        }
        
        // Stretchy Header Logic
        let y = offset.y
        if y < 0 {
            items.forEach { item in
                let originalHeight: CGFloat = 550
                let newHeight = originalHeight + abs(y)
                let scale = newHeight / originalHeight
                
                let translationY = y / 2
                item.alpha = 1.0
                item.transform = CGAffineTransform(translationX: 0, y: translationY)
                    .scaledBy(x: 1, y: scale)
            }
        }
    }
    
    private func findAllHeroViews(in view: UIView) -> [HeroContentView] {
        var views: [HeroContentView] = []
        if let heroView = view as? HeroContentView { views.append(heroView) }
        for subview in view.subviews { views.append(contentsOf: findAllHeroViews(in: subview)) }
        return views
    }
    
    private func handleNavBarScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        let alpha = min(1.0, max(0.0, y / 100.0))
        navBarBackgroundView?.alpha = alpha
    }
}

