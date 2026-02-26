import UIKit
import ma_ios_common

@MainActor
final class ProfileCoordinator: BaseCoordinator {
    private let factory: ScreenFactoryProtocol
    
    init(router: RouterProtocol, factory: ScreenFactoryProtocol) {
        self.factory = factory
        super.init(router: router)
    }
    
    func start() {
        let profileVC = factory.makeProfileViewController()
        router.setRoot(profileVC, animated: false, onPop: nil)
    }
    
    override func rootViewController() -> UIViewController {
        return router.navigationController
    }
}
