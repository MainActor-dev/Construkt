import UIKit
import ma_ios_common

@MainActor
final class HomeCoordinator: BaseCoordinator {
    private let factory: ScreenFactoryProtocol
    
    var onSwitchToExplore: (() -> Void)?
    
    init(router: RouterProtocol, factory: ScreenFactoryProtocol) {
        self.factory = factory
        super.init(router: router)
    }
    
    func start() {
        let homeVC = factory.makeHomeViewController()
        homeVC.onAction = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .movieSelected(let movie):
                let screen = self.factory.makeScreen(for: .movieDetail(movieId: String(movie.id)))
                self.router.push(screen, animated: true, hideTabBar: true, onPop: nil)
                
            case .listSelected(let section, let genre, let allGenres):
                let title: String
                switch section {
                case .categories: title = genre?.name ?? "Genre"
                case .popular: title = "Popular Movies"
                case .upcoming: title = "Upcoming Movies"
                case .topRated: title = "Top Rated Movies"
                default: title = "Movies"
                }
                let screen = self.factory.makeScreen(for: .movieList(title: title, sectionTypeRaw: section.rawValue, genreId: genre?.id, genreName: genre?.name, allGenres: allGenres))
                self.router.push(screen, animated: true, hideTabBar: true, onPop: nil)
                
            case .searchSelected:
                self.onSwitchToExplore?()
            }
        }
        
        router.setRoot(homeVC, animated: false, onPop: nil)
    }
    
    override func rootViewController() -> UIViewController {
        return router.navigationController
    }
}
