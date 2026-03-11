//
//  ConstruktRouteHandler.swift
//  Construkt
//
//  Created by @thatswiftdev on 23/02/26.
//  © 2026, https://github.com/thatswiftdev. All rights reserved.
//

import UIKit

/// A lightweight, isolated routing handler that natively integrates with `ConstruktRouter` to perform UI navigation
/// without the hierarchical lifecycle overhead of a full `ConstruktCoordinator` (no start/finish/parent/child logic).
///
/// This provides a decoupled, seamless way to intercept events bubbling up the responder chain using only a Router.
@MainActor
open class ConstruktRouteHandler<RouteType>: RouteReceiving {
    
    public typealias Event = RouteType
    
    /// The router used to perform UI navigation.
    public let router: ConstruktRouter
    
    /// Initializes a new route handler with a valid router.
    public init(router: ConstruktRouter) {
        self.router = router
    }
    
    /// Subclasses should override this method to examine the route and trigger navigations via the `router`.
    /// - Parameters:
    ///   - route: The route payload bubbling up the responder chain.
    ///   - sender: The object that triggered the route (e.g., UIButton, UIView).
    /// - Returns: `true` if the route was successfully handled (stops bubbling), `false` to let it continue bubbling.
    open func handle(_ route: RouteType, sender: Any?) -> Bool {
        return false
    }
    
    // MARK: - RouteReceiving Internals
    
    public final func canReceive(_ event: RouteType, sender: Any?) -> Bool {
        return handle(event, sender: sender)
    }
}

// MARK: - UIViewController Native Integration

private struct RouteHandlerLinkKey {
    static var handlerKey: UInt8 = 0
}

public extension UIViewController {
    
    /// A strongly retained reference to a standalone `ConstruktRouteHandler` (or any `AnyRouteReceiving` instance).
    ///
    /// When navigation events bubble up to this View Controller from its subviews, it will attempt
    /// to process them using this handler before checking for an attached `ConstruktCoordinator`.
    var associatedRouteHandler: AnyRouteReceiving? {
        get { objc_getAssociatedObject(self, &RouteHandlerLinkKey.handlerKey) as? AnyRouteReceiving }
        set { objc_setAssociatedObject(self, &RouteHandlerLinkKey.handlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
