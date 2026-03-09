//
//  ConstruktCoordinator.swift
//  Construkt
//

import Foundation

@MainActor
public protocol ConstruktCoordinator: AnyObject {
    var children: [ConstruktCoordinator] { get set }
    func start()
}

public extension ConstruktCoordinator {
    func store(_ child: ConstruktCoordinator) { children.append(child) }
    func free(_ child: ConstruktCoordinator) { children.removeAll { $0 === child } }
}

/// Base class to eliminate boilerplate for developers creating Coordinators
@MainActor
open class BaseCoordinator: ConstruktCoordinator {
    public var children: [ConstruktCoordinator] = []
    
    public init() {}
    
    open func start() {
        fatalError("start() must be implemented")
    }
}

/// An optional convenience protocol.
/// Developers conform their ConstruktCoordinator to this to magically receive `onRoute()` intents.
@MainActor
public protocol RouteHandlingCoordinator: ConstruktCoordinator, RouteReceiving {
    var router: ConstruktRouter { get }
}
