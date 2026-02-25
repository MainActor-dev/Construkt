import UIKit
import ma_ios_common

@MainActor
protocol ScreenFactoryProtocol {
    func makeScreen(for route: AppRoute) -> Presentable
    func makeHomeViewController() -> HomeViewController
    func makeExploreViewController() -> ExploreViewController
}

@MainActor
final class ScreenFactory: ScreenFactoryProtocol {
    init() {}
    
    func makeScreen(for route: AppRoute) -> Presentable {
        switch route {
        case .home:
            return makeHomeViewController()
        case .explore:
            return makeExploreViewController()
        case .search:
            return SearchViewController()
        case .movieDetail(let movieId):
            guard let id = Int(movieId) else { return UIViewController() }
            let dummyMovie = Movie(id: id, title: "", overview: "", releaseDate: nil, posterPath: nil, backdropPath: nil, voteAverage: 0, genreIds: nil)
            return MovieDetailViewController(movie: dummyMovie)
            
        case .movieList(let title, let sectionTypeRaw, let genreId, let genreName, let allGenres):
            let sectionType = HomeSection(rawValue: sectionTypeRaw) ?? .categories
            var selectedGenre: Genre? = nil
            if let gId = genreId, let gName = genreName {
                selectedGenre = Genre(id: gId, name: gName)
            }
            
            let listViewModel = MovieListViewModel(
                title: title,
                sectionType: sectionType,
                genres: allGenres ?? (selectedGenre != nil ? [selectedGenre!] : []),
                selectedGenre: selectedGenre
            )
            return MovieListViewController(viewModel: listViewModel)
        }
    }
    
    func makeHomeViewController() -> HomeViewController {
        return HomeViewController()
    }
    
    func makeExploreViewController() -> ExploreViewController {
        return ExploreViewController()
    }
}
