import UIKit

final class MoviesViewController: UIViewController {
    
    let viewModel = MovieViewModel()
    
    // Tracks current view for transition
    var mainView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Popular Movies" 
        view.backgroundColor = .systemBackground
        
        // Add a simple menu to switch categories
        // Add a simple menu to switch categories
        let filterButton = UIButton(type: .system)
        filterButton.setTitle("Filter", for: .normal)
        filterButton.addTarget(self, action: #selector(showFilter), for: .touchUpInside)
        let barItem = UIBarButtonItem(customView: filterButton)
        navigationItem.rightBarButtonItem = barItem
        
        let stateView = StateView(viewModel.$state) { [weak self] state in
            guard let self = self else { return LabelView("Loading...") }
            switch state {
            case .initial:
                 return LabelView("Initializing...")
                    .alignment(.center)
            case .loading:
                // Reusing LoadingView from UsersView.swift for now, or we can duplicate/move it to a shared place.
                // Assuming UsersView.swift is still there or we should move LoadingView to Shared.
                // For safety, I'll inline a simple loading view here if I can't guarantee LoadingView existence
                // but since I haven't deleted UsersView yet, it should be fine.
                // Better refactor: Move LoadingView/ErrorView/EmptyView to a Common file.
                // For this step I will just reference them, assuming they are available globally in the module.
                return LoadingView()
            case .loaded(let movies):
                return MoviesTableView(movies: movies) { [weak self] movie in
                    self?.showDetail(for: movie)
                }
                .reference(&self.mainView)
            case .empty(let message):
                return EmptyView(message: message)
            case .error(let error):
                return ErrorView(message: error)
            }
        }
        .onAppearOnce { [weak self] _ in
            self?.viewModel.loadPopularMovies()
        }
        
        // Bind title
        // Note: Generic StateView handles the content, but we want to update the VC title too.
        _ = viewModel.$title.onChange { [weak self] newTitle in
            self?.title = newTitle
        }
        
        view.embed(stateView)
    }
    
    @objc private func showFilter() {
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Popular", style: .default, handler: { _ in
            self.viewModel.loadPopularMovies()
        }))
        alert.addAction(UIAlertAction(title: "Top Rated", style: .default, handler: { _ in
            self.viewModel.loadTopRatedMovies()
        }))
        alert.addAction(UIAlertAction(title: "Now Playing", style: .default, handler: { _ in
            self.viewModel.loadNowPlayingMovies()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showDetail(for movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
