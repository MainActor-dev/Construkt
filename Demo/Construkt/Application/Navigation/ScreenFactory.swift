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
            return MovieDetailView(movie: dummyMovie)
                .onReceiveRoute(MovieDetailRoute.self, handler: { [unowned self] route in
                    switch route {
                    case .back:
                        return false // Back routes are handled appropriately by default
                    case .similarMovie(let movie):
                        let appRoute = AppRoute.movieDetail(movieId: String(movie.id))
                        return true
                    }
                })
                .toPresentable()
            
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
    
    class RoutingProxy {
        weak var controller: UIViewController?
    }
    
    func makeHomeViewController() -> ConstruktPresentable {
       
        let proxy = RoutingProxy()
        
        let container = HomeView().onReceiveRoute(HomeRoute.self) { [proxy] route in
            guard let vc = proxy.controller else { return false }
            
            let appRoute: AppRoute
            switch route {
            case .movieDetail(let movieId):
                appRoute = .movieDetail(movieId: movieId)
            case .movieList(let title, let sectionType, let genreId, let genreName, let allGenres):
                appRoute = .movieList(title: title, sectionTypeRaw: sectionType, genreId: genreId, genreName: genreName, allGenres: allGenres)
            case .search:
                appRoute = .search
            }
            
            // Bubble the translated route up from the host controller's view
            vc.view.route(appRoute, sender: vc.view)
            return true
        }
        
        let vc = container.toPresentable()
        proxy.controller = vc
        return vc
    }
    
    func makeExploreViewController() -> ConstruktPresentable {
        return ExploreView().toPresentable()
    }
    
    func makeProfileViewController() -> ConstruktPresentable {
        return ProfileView().toPresentable()
    }
}
