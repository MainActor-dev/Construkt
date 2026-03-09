import Testing
import UIKit
@testable import ConstruktKit

private enum TestRoute: Equatable {
    case page1
    case page2(id: Int)
}

private class MockRootViewController: UIViewController, RouteReceiving {
    typealias Event = TestRoute
    
    var receivedRoute: TestRoute?
    var dispatchClosure: (() -> Void)?
    
    func canReceive(_ event: TestRoute, sender: Any?) -> Bool {
        receivedRoute = event
        dispatchClosure?()
        return true
    }
}

@Suite("EventRoutingTests") @MainActor
struct EventRoutingTests {

    @Test("Route should bubble up to the root controller")
    func testRouteBubblesUpToRootController() {
        let rootVC = MockRootViewController()
        
        // Add a view that emits a route
        let button = ButtonView("Go").onRoute(TestRoute.page2(id: 42)).build() as! UIButton
        
        // Responder chain requires establishing a valid window hierarchy
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        
        rootVC.view.addSubview(button)
        
        // Simulate tap
        button.route(TestRoute.page2(id: 42), sender: button)
        
        #expect(rootVC.receivedRoute == .page2(id: 42))
    }
}
