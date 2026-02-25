import UIKit
import ma_ios_common

@MainActor
public final class HomeCoordinator: BaseCoordinator {
    private let factory: ScreenFactoryProtocol
    
    public init(router: RouterProtocol, factory: ScreenFactoryProtocol) {
        self.factory = factory
        super.init(router: router)
    }
    
    public func start() {
        let homeScreen = factory.makeScreen(for: .home)
        router.setRoot(homeScreen, animated: false, onPop: nil)
    }
    
    public override func rootViewController() -> UIViewController {
        return router.navigationController
    }
}
