// 
//  👨‍💻 Created by @thatswiftdev on 24/09/25.
//
//  © 2025, https://github.com/thatswiftdev. All rights reserved.
//
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


// MARK: - Type-erased entry (responder chain only knows this)
protocol AnyEventReceiving: AnyObject {
    /// Return true if the event was handled (stop bubbling)
    func __receive(_ event: Any, sender: Any?) -> Bool
}

// MARK: - Generic, strongly-typed handler each target conforms to
protocol EventHandling: AnyEventReceiving {
    associatedtype Event
    func canReceive(_ event: Event, sender: Any?) -> Bool
}

extension EventHandling {
    func __receive(_ event: Any, sender: Any?) -> Bool {
        guard let e = event as? Event else { return false }
        return canReceive(e, sender: sender)
    }
}

// MARK: - Router
extension UIResponder {
    /// Bubble a strongly-typed payload up the responder chain.
    @discardableResult
    func route<E>(_ event: E, sender: Any?) -> Bool {
        if let h = self as? AnyEventReceiving, h.__receive(event, sender: sender) { return true }
        return next?.route(event, sender: sender) ?? false
    }
}

extension UIViewController {
    enum VCNeighbor {
        case children, parent, presented, presenting, navigationStack, tabBar, windowRoot
    }

    /// Find first view controller matching `predicate` using BFS over the VC graph.
    /// `neighborsOrder` controls which neighbor types get enqueued (default: common useful ones).
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

            // Build neighbors in the requested order:
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

    /// Route event to the first view controller of given type `T` that also conforms to AnyEventReceiving.
    /// Returns true if the target exists AND handled the event (i.e., __receive returned true).
    @discardableResult
    func routeToViewController<T: UIViewController & EventHandling>(_ targetType: T.Type, event: T.Event, sender: Any? = nil) -> Bool {
        guard let target = findFirstViewController(matching: { $0 is T }) as? T else { return false }
        return target.__receive(event, sender: sender)
    }

    /// Route event to the first view controller matching a predicate.
    /// Returns true if the target exists AND handled the event.
    @discardableResult
    func routeToViewController<E>(_ event: E, sender: Any? = nil, matching predicate: @escaping (UIViewController) -> Bool) -> Bool {
        guard let target = findFirstViewController(matching: predicate) else { return false }
        guard let receiver = target as? AnyEventReceiving else { return false }
        return receiver.__receive(event, sender: sender)
    }
}

// MARK: - Convenience from UIView: start from owning VC or window root
extension UIView {
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
