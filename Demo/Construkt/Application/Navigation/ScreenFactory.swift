import UIKit
import ConstruktKit


@MainActor
protocol ScreenFactoryProtocol {
    func makeScreen(for route: AppRoute) -> ConstruktPresentable
    func makeHomeViewController() -> ConstruktPresentable
    func makeExploreViewController() -> ConstruktPresentable
    func makeProfileViewController() -> ConstruktPresentable
}

@MainActor
final class ScreenFactory: ScreenFactoryProtocol {
    init() {}
    
    func makeScreen(for route: AppRoute) -> ConstruktPresentable {
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
            
        case .web(let url):
            let vc = UIViewController()
            vc.title = url.absoluteString
            return vc
        }
    }
    
    func makeHomeViewController() -> ConstruktPresentable {
        return HomeView().toPresentable()
    }
    
    func makeExploreViewController() -> ConstruktPresentable {
        return ExploreView().toPresentable()
    }
    
    func makeProfileViewController() -> ConstruktPresentable {
        return ProfileView().toPresentable()
    }
}
