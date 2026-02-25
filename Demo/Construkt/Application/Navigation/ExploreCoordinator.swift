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
        let exploreScreen = factory.makeScreen(for: .explore)
        router.setRoot(exploreScreen, animated: false, onPop: nil)
    }
    
    public override func rootViewController() -> UIViewController {
        return router.navigationController
    }
}
