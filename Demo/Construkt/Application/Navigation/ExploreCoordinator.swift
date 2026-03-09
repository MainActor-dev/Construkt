import UIKit
import ConstruktKit


@available(iOS 15.0, *)
@MainActor
final class ExploreCoordinator: BaseCoordinator, RouteHandlingCoordinator {
    typealias Event = AppRoute
    
    let router: any Router
    private let factory: ScreenFactoryProtocol
    
    init(router: any Router, factory: ScreenFactoryProtocol) {
        self.router = router
        self.factory = factory
        super.init()
    }
    
    override func start() {
        let exploreVC = factory.makeExploreViewController()
        router.setRoot(exploreVC, hideBar: false, animated: false, receiver: self)
    }
    
    func canReceive(_ event: AppRoute, sender: Any?) -> Bool {
        switch event {
        case .movieDetail(let movieId):
            let screen = factory.makeScreen(for: .movieDetail(movieId: movieId))
            router.push(screen, animated: true, completion: nil, receiver: self)
            return true
            
        case .movieList(let title, let sectionTypeRaw, let genreId, let genreName, let allGenres):
            let screen = factory.makeScreen(for: .movieList(title: title, sectionTypeRaw: sectionTypeRaw, genreId: genreId, genreName: genreName, allGenres: allGenres))
            router.push(screen, animated: true, completion: nil, receiver: self)
            return true
            
        case .search:
            let screen = factory.makeScreen(for: .search)
            router.push(screen, animated: true, completion: nil, receiver: self)
            return true
            
        default:
            return false // Allow bubbling
        }
    }
}
