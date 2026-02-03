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
    
    // MARK: - Body
    
    var body: View {
        CollectionView {
            heroSection
            popularSection
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
        }
    }
    
    // MARK: - Lifecycle
    
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
            Cell(movie, id: movie.id) { movie in
                HeroView(movie: movie)
            }
            .onSelect { [weak self] movie in
                self?.showDetail(for: movie)
            }
        }
        .layout { _ in
            return HomeSection.hero.layout
        }
        .skeleton(count: 1, when: viewModel.isNowPlayingLoadingObservable) {
            HeroView(movie: .placeholder)
        }
    }
    
    private var popularSection: Section {
        Section(
            id: HomeSection.popular,
            items: viewModel.popularSectionMoviesObservable,
            header: {
                Header {
                    LabelView("Popular")
                        .font(.systemFont(ofSize: 24, weight: .bold))
                        .color(.white)
                        .backgroundColor(.clear)
                }
            }
        ) { movie in
            Cell(movie, id: movie.id) { movie in
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
        .emptyState {
            EmptyView(title: "No items here!", subtitle: "Check your connection", buttonTitle: "Retry")
//            VStackView {
//                ImageView(systemName: "tray")
//                    .tintColor(.gray)
//                    .contentMode(.scaleAspectFit)
//                
//                LabelView("No items here!")
//                    .color(.gray)
//                    .alignment(.center)
//            }
//            .spacing(8)
//            .alignment(.center)
//            .padding(32)
        }
    }
}

// MARK: - Components
struct HeroView: ViewBuilder {
    let movie: Movie
    
    var body: View {
        ZStackView {
            ImageView(url: movie.backdropURL)
                .skeletonable(true)
                .contentMode(.scaleAspectFill)
                .backgroundColor(.darkGray)
                .clipsToBounds(true)
            
            VStackView {
                SpacerView()
                VStackView {
                    LabelView(movie.title)
                        .font(.systemFont(ofSize: 24, weight: .bold))
                        .color(.white)
                        .numberOfLines(2)
                        .skeletonable(true)
                    
                    LabelView(movie.releaseDate ?? "")
                        .font(.systemFont(ofSize: 14))
                        .color(.lightGray)
                        .skeletonable(true)
                }
                .padding(16)
                .backgroundColor(UIColor.black.withAlphaComponent(0.6))
            }
        }
        .clipsToBounds(true)
        .cornerRadius(12)
    }
}

