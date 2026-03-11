import UIKit
import ConstruktKit


@available(iOS 15.0, *)
@MainActor
final class ProfileCoordinator: BaseCoordinator, RouteHandlingCoordinator {
    typealias Event = AppRoute
    
    let router: any ConstruktRouter
    private let factory: ScreenFactoryProtocol
    
    init(router: any ConstruktRouter, factory: ScreenFactoryProtocol) {
        self.router = router
        self.factory = factory
        super.init()
    }
    
    override func start() {
        let profileVC = factory.makeProfileViewController()
        router.setRoot(profileVC, hideBar: false, animated: false, receiver: self)
    }
    
    func canReceive(_ event: AppRoute, sender: Any?) -> Bool {
        return false // No profile events handled yet
    }
}
