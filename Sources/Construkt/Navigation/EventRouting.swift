//
//  EventRouting.swift
//  Construkt
//

import UIKit

// MARK: - Type-erased entry (responder chain only knows this)
@MainActor
public protocol AnyRouteReceiving: AnyObject {
    /// Return true if the event was handled (stop bubbling)
    func __receive(_ event: Any, sender: Any?) -> Bool
}

// MARK: - Generic, strongly-typed handler each target conforms to
@MainActor
public protocol RouteReceiving: AnyRouteReceiving {
    associatedtype Event
    func canReceive(_ event: Event, sender: Any?) -> Bool
}

public extension RouteReceiving {
    func __receive(_ event: Any, sender: Any?) -> Bool {
        guard let e = event as? Event else { return false }
        return canReceive(e, sender: sender)
    }
}

// MARK: - Route Dispatcher for UIResponder
public extension UIResponder {
    /// Bubble a strongly-typed payload up the responder chain.
    @discardableResult
    func route<E>(_ event: E, sender: Any?) -> Bool {
        // 1. Check if the current responder can handle it Directly
        if let h = self as? AnyRouteReceiving, h.__receive(event, sender: sender) { return true }
        
        // 2. If it's a View Controller, check if it has an associated ConstruktCoordinator to handle it
        if let vc = self as? UIViewController,
           let coordinator = vc.associatedCoordinator,
           coordinator.__receive(event, sender: sender) {
            return true
        }
        
        // 3. Otherwise, bubble up to the next responder
        return next?.route(event, sender: sender) ?? false
    }
}

private struct CoordinatorLinkKey {
    static var coordinatorKey: UInt8 = 0
}

public extension UIViewController {
    /// A weak reference to the coordinator responsible for this view controller.
    /// This allows events to jump from the UIResponder chain to the ConstruktCoordinator tree.
    var associatedCoordinator: AnyRouteReceiving? {
        get { (objc_getAssociatedObject(self, &CoordinatorLinkKey.coordinatorKey) as? WeakBox)?.value }
        set {
            let box = newValue.map { WeakBox($0) }
            objc_setAssociatedObject(self, &CoordinatorLinkKey.coordinatorKey, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private final class WeakBox: NSObject {
    weak var value: AnyRouteReceiving?
    init(_ value: AnyRouteReceiving) { self.value = value }
}

public extension UIView {
    private func owningViewController() -> UIViewController? {
        var r: UIResponder? = self
        while let next = r?.next {
            if let vc = next as? UIViewController { return vc }
            r = next
        }
        return nil
    }
}

// MARK: - Event Routing View Modifier
public extension ModifiableView where Base: UIView {
    /// Add a tap gesture recognizer that routes the given event payload up the responder chain.
    /// - Parameter event: An autoclosure providing the event to route when tapped.
    @discardableResult
    func onRoute<E>(_ event: @autoclosure @escaping () -> E) -> ViewModifier<Base> {
        return self.with { view in
            let target = RouteTapTarget(view: view, eventProvider: event)
            
            objc_setAssociatedObject(
                view,
                &RouteAssociator.routeTargetKey,
                target,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            let tapGesture = UITapGestureRecognizer(target: target, action: #selector(RouteTapTarget<Any>.handleTap))
            view.addGestureRecognizer(tapGesture)
            view.isUserInteractionEnabled = true
        }
    }
}

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
