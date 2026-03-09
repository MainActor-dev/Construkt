//
//  EventRouting.swift
//  Construkt
//

import UIKit

// MARK: - Type-erased entry (responder chain only knows this)
@MainActor
public protocol AnyEventReceiving: AnyObject {
    /// Return true if the event was handled (stop bubbling)
    func __receive(_ event: Any, sender: Any?) -> Bool
}

// MARK: - Generic, strongly-typed handler each target conforms to
@MainActor
public protocol EventHandling: AnyEventReceiving {
    associatedtype Event
    func canReceive(_ event: Event, sender: Any?) -> Bool
}

public extension EventHandling {
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
        if let h = self as? AnyEventReceiving, h.__receive(event, sender: sender) { return true }
        
        // 2. If it's a View Controller, check if it has an associated Coordinator to handle it
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
    /// This allows events to jump from the UIResponder chain to the Coordinator tree.
    var associatedCoordinator: AnyEventReceiving? {
        get { (objc_getAssociatedObject(self, &CoordinatorLinkKey.coordinatorKey) as? WeakBox)?.value }
        set {
            let box = newValue.map { WeakBox($0) }
            objc_setAssociatedObject(self, &CoordinatorLinkKey.coordinatorKey, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private final class WeakBox: NSObject {
    weak var value: AnyEventReceiving?
    init(_ value: AnyEventReceiving) { self.value = value }
}

public extension UIViewController {
    enum VCNeighbor {
        case children, parent, presented, presenting, navigationStack, tabBar, windowRoot
    }

    /// Find first view controller matching `predicate` using BFS over the VC graph.
    func findFirstViewController(
        matching predicate: (UIViewController) -> Bool,
        neighborsOrder: [VCNeighbor] = [.children, .parent, .presented, .presenting, .navigationStack, .tabBar, .windowRoot]
    ) -> UIViewController? {
        var queue: [UIViewController] = [self]
        var visited = Set<ObjectIdentifier>()

        while !queue.isEmpty {
            let vc = queue.removeFirst()
            let id = ObjectIdentifier(vc)
            if visited.contains(id) { continue }
            visited.insert(id)

            if predicate(vc) { return vc }

            var neighbors: [UIViewController] = []
            for n in neighborsOrder {
                switch n {
                case .children:
                    neighbors.append(contentsOf: vc.children)
                case .parent:
                    if let p = vc.parent { neighbors.append(p) }
                case .presented:
                    if let p = vc.presentedViewController { neighbors.append(p) }
                case .presenting:
                    if let p = vc.presentingViewController { neighbors.append(p) }
                case .navigationStack:
                    if let nav = vc.navigationController {
                        neighbors.append(contentsOf: nav.viewControllers)
                    }
                case .tabBar:
                    if let tab = vc.tabBarController, let t = tab.viewControllers {
                        neighbors.append(contentsOf: t)
                    }
                case .windowRoot:
                    if let root = vc.view.window?.rootViewController {
                        neighbors.append(root)
                    }
                }
            }

            queue.append(contentsOf: neighbors)
        }

        return nil
    }

    @discardableResult
    func routeToViewController<T: UIViewController & EventHandling>(_ targetType: T.Type, event: T.Event, sender: Any? = nil) -> Bool {
        guard let target = findFirstViewController(matching: { $0 is T }) as? T else { return false }
        return target.__receive(event, sender: sender)
    }

    @discardableResult
    func routeToViewController<E>(_ event: E, sender: Any? = nil, matching predicate: @escaping (UIViewController) -> Bool) -> Bool {
        guard let target = findFirstViewController(matching: predicate) else { return false }
        guard let receiver = target as? AnyEventReceiving else { return false }
        return receiver.__receive(event, sender: sender)
    }
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

    @discardableResult
    func routeToViewController<T: UIViewController & EventHandling>(_ targetType: T.Type, event: T.Event, sender: Any? = nil) -> Bool {
        if let vc = owningViewController() {
            return vc.routeToViewController(targetType, event: event, sender: sender)
        } else if let root = window?.rootViewController {
            return root.routeToViewController(targetType, event: event, sender: sender)
        }
        return false
    }

    @discardableResult
    func routeToViewController<E>(_ event: E, sender: Any? = nil, matching predicate: @escaping (UIViewController) -> Bool) -> Bool {
        if let vc = owningViewController() {
            return vc.routeToViewController(event, sender: sender, matching: predicate)
        } else if let root = window?.rootViewController {
            return root.routeToViewController(event, sender: sender, matching: predicate)
        }
        return false
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
