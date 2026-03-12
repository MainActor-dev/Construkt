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
        let profileVC = factory.makeScreen(for: .profile)
        router.setRoot(profileVC, hideBar: false, animated: false, receiver: self)
    }
    
    func canReceive(_ event: AppRoute, sender: Any?) -> Bool {
        switch event {
        case .back:
            router.pop(animated: true)
        default:
            let screen = factory.makeScreen(for: event)
            router.push(screen, animated: true, hideTabBar: true, receiver: self)
        }
        return true
    }
}
