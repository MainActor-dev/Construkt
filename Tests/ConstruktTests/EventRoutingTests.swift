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
    
    @Test("Declarative .onReceiveRoute intercepts bubbled events")
    func testDeclarativeRouteInterceptor() {
        var trappedRoute: TestRoute? = nil
        
        let container = ContainerView()
            .onReceiveRoute(TestRoute.self, handler: { event in
                trappedRoute = event
                return true
            })
            .build()
            
        let button = ButtonView("Action")
            .onRoute(TestRoute.page1)
            .build() as! UIButton
            
        container.addSubview(button)
        
        // Bubbles up from the button -> intercepted by the declarative container logic
        button.route(TestRoute.page1, sender: button)
        
        #expect(trappedRoute == .page1)
    }
    
    @Test("Targeted declarative .onReceiveRoute safely decouples objects")
    func testTargetedRouteInterceptorMemorySafety() {
        class RefCountedTarget {
            var handledValue: Int = 0
            deinit {}
        }
        
        var target: RefCountedTarget? = RefCountedTarget()
        weak var weakTarget = target
        
        let container = ContainerView()
            .onReceiveRoute(TestRoute.self, on: target!) { ref, event in
                switch event {
                case .page2(let id):
                    ref.handledValue = id
                    return true
                default:
                    return false
                }
            }
            .build()
            
        let button = ButtonView("Action").build() as! UIButton
        container.addSubview(button)
        
        button.route(TestRoute.page2(id: 99), sender: button)
        #expect(target?.handledValue == 99)
        
        // Assert releasing the target works
        target = nil
        #expect(weakTarget == nil)
        
        // Bubbling continues instead of failing with released targets
        let handled = button.route(TestRoute.page2(id: 100), sender: button)
        #expect(handled == false)
    }
}
