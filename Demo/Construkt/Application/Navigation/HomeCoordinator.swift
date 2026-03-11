import UIKit
import ConstruktKit


@available(iOS 15.0, *)
@MainActor
final class HomeCoordinator: BaseCoordinator, RouteHandlingCoordinator {
 
    let router: any ConstruktRouter
    private let factory: ScreenFactoryProtocol
    
    var onSwitchToExplore: (() -> Void)?
    
    init(router: any ConstruktRouter, factory: ScreenFactoryProtocol) {
        self.router = router
        self.factory = factory
        super.init()
    }
    
    override func start() {
        let homeVC = factory.makeScreen(for: .home)
        router.setRoot(homeVC, hideBar: false, animated: false, receiver: self)
    }
    
    func canReceive(_ event: AppRoute, sender: Any?) -> Bool {
        switch event {
        case .back:
            router.pop(animated: true)
            
        case .movieDetail(let movieId):
            let screen = factory.makeScreen(for: .movieDetail(movieId: movieId))
            router.push(screen, animated: true, hideTabBar: true, receiver: self)
            
        case .movieList(let title, let sectionTypeRaw, let genreId, let genreName, let allGenres):
            let screen = factory.makeScreen(for: .movieList(title: title, sectionTypeRaw: sectionTypeRaw, genreId: genreId, genreName: genreName, allGenres: allGenres))
            router.push(screen, animated: true, completion: nil, receiver: self)
            
        case .search:
            onSwitchToExplore?()
        default: return false
        }
        
        return true
    }
}
