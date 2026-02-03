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
            Section(id: HomeSection.hero, items: viewModel.popularMoviesObservable) { movie in
                 Cell(movie, id: movie.id) { movie in
                      MovieCardView(movie: movie)
                 }
                 .onSelect { [weak self] movie in
                     self?.showDetail(for: movie)
                 }
            }
            .layout { _ in
                return HomeSection.hero.layout
            }
            .skeleton(count: 1, when: viewModel.isLoadingObservable) {
                MovieCardView(movie: .placeholder)
            }
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
        
        // Initial Embed
        view.embed(body)
        
        // Reactivity
        fetchData()
    }
    
    private func fetchData() {
        viewModel.loadPopularMovies()
    }
    
    private func showDetail(for movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Components

struct MovieCardView: ViewBuilder {
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

