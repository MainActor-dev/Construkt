//
//  DeclarativeHomeViewController.swift
//  Construkt
//
//  Created by User on 2026-02-02.
//

import UIKit
import RxSwift

class DeclarativeHomeViewController: UIViewController {
    
    private let viewModel = MovieViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Body
    
    var body: View {
        CollectionView {
            Section(id: HomeSection.hero, items: Array(viewModel.popularMovies.prefix(3))) { movie in
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
            .skeleton(HeroCell.self, count: 6, when: viewModel.isLoading && viewModel.popularMovies.isEmpty)
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
        observe()
        fetchData()
    }
    
    private func observe() {
        viewModel.$state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?.refresh()
            })
            .disposed(by: disposeBag)
    }
    
    private func refresh() {
        // Re-embed the body to apply updates.
        // In a true reactive system, CollectionView would bind to observables.
        // Here we just rebuild the declarative tree which is cheap, 
        // and CollectionViewWrapperView handles the diffing via DiffableDataSource.
        view.reset(body)
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
            ImageView(nil)
                .contentMode(.scaleAspectFill)
                .backgroundColor(.darkGray)
                .skeletonable(true)
            
            VStackView {
                SpacerView()
                VStackView {
                    LabelView(movie.title)
                        .font(.systemFont(ofSize: 24, weight: .bold))
                        .color(.white)
                        .numberOfLines(2)
                    
                    LabelView(movie.releaseDate ?? "")
                        .font(.systemFont(ofSize: 14))
                        .color(.lightGray)
                }
                .padding(16)
                .backgroundColor(UIColor.black.withAlphaComponent(0.6))
            }
        }
        .clipsToBounds(true)
        .cornerRadius(12)
    }
}
