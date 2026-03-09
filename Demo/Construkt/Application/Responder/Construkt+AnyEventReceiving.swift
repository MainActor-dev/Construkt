import UIKit
// MARK: - Event Routing View Modifier
public extension ModifiableView where Base: UIView {
    /// Add a tap gesture recognizer that routes the given event payload up the responder chain.
    /// - Parameter event: An autoclosure providing the event to route when tapped.
    @discardableResult
    func onRoute<E>(_ event: @autoclosure @escaping () -> E) -> ViewModifier<Base> {
        return self.with { view in
            // Create a target designed to route the evaluated event
            let target = RouteTapTarget(view: view, eventProvider: event)
            
            // Retain the target on the view so it lives as long as the view
            objc_setAssociatedObject(
                view,
                &RouteAssociator.routeTargetKey,
                target,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            // Add the gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: target, action: #selector(RouteTapTarget<Any>.handleTap))
            view.addGestureRecognizer(tapGesture)
            view.isUserInteractionEnabled = true
        }
    }
}

// MARK: - Internal Routing Infrastructure
private struct RouteAssociator {
    static var routeTargetKey: UInt8 = 0
}

private final class RouteTapTarget<E>: NSObject {
    private weak var view: UIView?
    private let eventProvider: () -> E
    
    init(view: UIView, eventProvider: @escaping () -> E) {
        self.view = view
        self.eventProvider = eventProvider
    }
    
    @objc func handleTap() {
        guard let view = view else { return }
        view.route(eventProvider(), sender: view)
    }
}
