import UIKit
import ma_ios_common

@MainActor
final class ExploreCoordinator: BaseCoordinator {
    private let factory: ScreenFactoryProtocol
    
    init(router: RouterProtocol, factory: ScreenFactoryProtocol) {
        self.factory = factory
        super.init(router: router)
    }
    
    func start() {
        let exploreVC = factory.makeExploreViewController()
        
        exploreVC.onAction = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .movieSelected(let id):
                let screen = self.factory.makeScreen(for: .movieDetail(movieId: id))
                self.router.push(screen, animated: true, hideTabBar: true, onPop: nil)
                
            case .genreSelected(let selected, let all):
                guard let genreId = Int(selected.id) else { return }
                
                let allGenres = all.compactMap {
                    guard let id = Int($0.id) else { return nil as Genre? }
                    return Genre(id: id, name: $0.name)
                }
                
                let screen = self.factory.makeScreen(for: .movieList(title: selected.name, sectionTypeRaw: "categories", genreId: genreId, genreName: selected.name, allGenres: allGenres))
                self.router.push(screen, animated: true, hideTabBar: true, onPop: nil)
            case .searchSelected:
                let screen = factory.makeScreen(for: .search)
                router.push(screen, animated: true, hideTabBar: true, onPop: nil)
            }
        }
        
        router.setRoot(exploreVC, animated: false, onPop: nil)
    }
    
    override func rootViewController() -> UIViewController {
        return router.navigationController
    }
}
