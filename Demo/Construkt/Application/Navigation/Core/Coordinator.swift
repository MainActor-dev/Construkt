import UIKit

@MainActor
public protocol Coordinator: AnyObject {
    func start()
}

@MainActor
public protocol FlowCoordinator: AnyObject {
    associatedtype Result
    func start() async -> Result
}

/// Base class for all Coordinators
///
/// Coordinators own flow logic and manage navigation between screens.
/// They hold child coordinators and use Router for navigation primitives.
@MainActor
open class BaseCoordinator: Coordinator {
    /// Router for performing navigation actions
    public let router: RouterProtocol
    
    /// Child coordinators managed by this coordinator
    public private(set) var childCoordinators: [BaseCoordinator] = []
    
    // MARK: - Init
    
    // MARK: - Init
    
    public init(router: RouterProtocol) {
        self.router = router
    }
    
    open func start() {
        fatalError("start() must be implemented by subclasses")
    }
 
    // MARK: - Child Coordinator Management
    
    /// Add a child coordinator (retains it)
    public func addChild(_ coordinator: BaseCoordinator) {
        childCoordinators.append(coordinator)
    }
    
    /// Remove a child coordinator when its flow completes
    public func removeChild(_ coordinator: BaseCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    /// Remove all child coordinators
    public func removeAllChildren() {
        childCoordinators.removeAll()
    }
    
    public func setRootChild(_ coordinator: BaseCoordinator, animated: Bool = false) {
        removeAllChildren()
        addChild(coordinator)
        router.setRoot(coordinator.rootViewController(), animated: animated) { [weak self, weak coordinator] in
            guard let coordinator = coordinator else { return }
            self?.removeChild(coordinator)
        }
    }
    
    // MARK: - Navigation Helpers
    
    /// Push a child coordinator onto the navigation stack with auto-cleanup
    public func pushChild(_ coordinator: BaseCoordinator, animated: Bool, hideTabBar: Bool = false) {
        addChild(coordinator)
        
        router.push(coordinator.rootViewController(), animated: animated, hideTabBar: hideTabBar) { [weak self, weak coordinator] in
            guard let self = self, let coordinator = coordinator else { return }
            self.removeChild(coordinator)
        }
    }
    
    /// Present a child coordinator modally with auto-cleanup
    ///
    /// Note: Child coordinator must be initialized with a Router wrapping a UINavigationController
    /// before calling this method.
    @available(iOS 15.0, *)
    public func presentChild(_ coordinator: BaseCoordinator, style: ModalStyle, animated: Bool) {
        addChild(coordinator)
            
        router.present(coordinator.rootViewController(), style: style, animated: animated, onDismiss: { [weak self, weak coordinator] in
            guard let self = self, let coordinator = coordinator else { return }
            self.removeChild(coordinator)
        })
    }
    
    // MARK: - Override Point
    
    /// Returns the root view controller for this coordinator
    /// Override if using pushChild
    open func rootViewController() -> UIViewController {
        fatalError("rootViewController() must be overridden when using pushChild")
    }
}
