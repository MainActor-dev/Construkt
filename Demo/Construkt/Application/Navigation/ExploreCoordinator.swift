import UIKit
import ma_ios_common

@MainActor
public final class ExploreCoordinator: BaseCoordinator {
    private let factory: ScreenFactoryProtocol
    
    public init(router: RouterProtocol, factory: ScreenFactoryProtocol) {
        self.factory = factory
        super.init(router: router)
    }
    
    public func start() {
        guard let exploreVC = factory.makeScreen(for: .explore) as? ExploreViewController else { return }
        
        exploreVC.onAction = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .movieSelected(let id):
                let screen = self.factory.makeScreen(for: .movieDetail(movieId: id))
                self.router.push(screen, animated: true, hideTabBar: true, onPop: nil)
                
            case .genreSelected(let genre):
                guard let genreId = Int(genre.id) else { return }
                let screen = self.factory.makeScreen(for: .movieList(title: genre.name, sectionTypeRaw: "categories", genreId: genreId, genreName: genre.name))
                self.router.push(screen, animated: true, hideTabBar: true, onPop: nil)
            case .searchSelected:
                let screen = factory.makeScreen(for: .search)
                router.push(screen, animated: true, hideTabBar: true, onPop: nil)
            }
        }
        
        router.setRoot(exploreVC, animated: false, onPop: nil)
    }
    
    public override func rootViewController() -> UIViewController {
        return router.navigationController
    }
}
