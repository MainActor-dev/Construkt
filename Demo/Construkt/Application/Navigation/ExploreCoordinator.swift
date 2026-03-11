import UIKit
import ConstruktKit


@available(iOS 15.0, *)
@MainActor
final class ExploreCoordinator: BaseCoordinator, RouteHandlingCoordinator {
    
    let router: any ConstruktRouter
    private let factory: ScreenFactoryProtocol
    
    init(router: any ConstruktRouter, factory: ScreenFactoryProtocol) {
        self.router = router
        self.factory = factory
        super.init()
    }
    
    override func start() {
        let exploreVC = factory.makeScreen(for: .explore)
        router.setRoot(exploreVC, hideBar: false, animated: false, receiver: self)
    }
    
    func canReceive(_ event: AppRoute, sender: Any?) -> Bool {
        switch event {
        case .back:
            router.pop(animated: true)
        case .movieDetail(let movieId):
            let screen = factory.makeScreen(for: .movieDetail(movieId: movieId))
            push(screen)
        case .movieList(let title, let sectionTypeRaw, let genreId, let genreName, let allGenres):
            let screen = factory.makeScreen(for: .movieList(title: title, sectionTypeRaw: sectionTypeRaw, genreId: genreId, genreName: genreName, allGenres: allGenres))
            push(screen)
        case .search:
            let screen = factory.makeScreen(for: .search)
            push(screen)
            
        default:
            return false
        }
        
        return true
    }
    
    private func push(_ screen: ConstruktPresentable) {
        router.push(screen, hideTabBar: true, receiver: self)
    }
}


