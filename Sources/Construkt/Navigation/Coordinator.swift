//
//  Coordinator.swift
//  Construkt
//

import Foundation

@MainActor
public protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    func start()
}

public extension Coordinator {
    func store(_ child: Coordinator) { children.append(child) }
    func free(_ child: Coordinator) { children.removeAll { $0 === child } }
}

/// Base class to eliminate boilerplate for developers creating Coordinators
@MainActor
open class BaseCoordinator: Coordinator {
    public var children: [Coordinator] = []
    
    public init() {}
    
    open func start() {
        fatalError("start() must be implemented")
    }
}

/// An optional convenience protocol.
/// Developers conform their Coordinator to this to magically receive `onRoute()` intents.
@MainActor
public protocol RouteHandlingCoordinator: Coordinator, EventHandling {
    var router: Router { get }
}
