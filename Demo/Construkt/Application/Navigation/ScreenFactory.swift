import UIKit
import ma_ios_common

@MainActor
public protocol ScreenFactoryProtocol {
    func makeScreen(for route: AppRoute) -> Presentable
}

@MainActor
public final class ScreenFactory: ScreenFactoryProtocol {
    public init() {}
    
    public func makeScreen(for route: AppRoute) -> Presentable {
        switch route {
        case .home:
            return HomeViewController()
        case .explore:
            return ExploreViewController()
        case .search:
            return SearchViewController()
        case .movieDetail(let movieId):
            guard let id = Int(movieId) else { return UIViewController() }
            let dummyMovie = Movie(id: id, title: "", overview: "", releaseDate: nil, posterPath: nil, backdropPath: nil, voteAverage: 0, genreIds: nil)
            return MovieDetailViewController(movie: dummyMovie)
            
        case .movieList(let title, let sectionTypeRaw, let genreId, let genreName):
            let sectionType = HomeSection(rawValue: sectionTypeRaw) ?? .categories
            var selectedGenre: Genre? = nil
            if let gId = genreId, let gName = genreName {
                selectedGenre = Genre(id: gId, name: gName)
            }
            
            // For simplicity, we create an empty genres list for now or load it later in ViewModel
            let listViewModel = MovieListViewModel(
                title: title,
                sectionType: sectionType,
                genres: selectedGenre != nil ? [selectedGenre!] : [],
                selectedGenre: selectedGenre
            )
            return MovieListViewController(viewModel: listViewModel)
        }
    }
}
