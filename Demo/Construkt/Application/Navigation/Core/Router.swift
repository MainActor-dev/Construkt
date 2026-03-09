import UIKit

/// Modal presentation styles supported by the Router
@available(iOS 15.0, *)
public enum ModalStyle {
    case sheet(detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
               prefersGrabberVisible: Bool = true)
    case fullScreen
    case formSheet
    case custom((UIViewController) -> Void)
    
    public var uiModalPresentationStyle: UIModalPresentationStyle {
        switch self {
        case .sheet:
            return .pageSheet
        case .fullScreen:
            return .fullScreen
        case .formSheet:
            return .formSheet
        case .custom:
            return .custom
        }
    }
}

/// Router protocol defining navigation primitives
///
/// Router owns the UINavigationController and mediates all navigation actions.
/// Coordinators use Router to perform push/pop/present/dismiss operations.
@MainActor
public protocol RouterProtocol: AnyObject {
    var navigationController: UINavigationController { get }
    
    /// Set the root view controller (replaces entire stack)
    func setRoot(_ presentable: Presentable, hideBar: Bool, animated: Bool, onPop: (@MainActor () -> Void)?)
    
    /// Push a screen onto the navigation stack
    func push(_ presentable: Presentable, animated: Bool, hideTabBar: Bool, onPop: (@MainActor () -> Void)?)
    
    /// Pop the top screen from the navigation stack
    func pop(animated: Bool)
    
    /// Pop to the root screen
    func popToRoot(animated: Bool)
    
    /// Present a screen modally
    @available(iOS 15.0, *)
    func present(_ presentable: Presentable, style: ModalStyle, animated: Bool, onDismiss: (@MainActor () -> Void)?)
    
    /// Dismiss the top-most modal
    func dismiss(animated: Bool, completion: (@MainActor () -> Void)?)
}

extension RouterProtocol {
    public func setRoot(_ presentable: Presentable, hideBar: Bool = true, animated: Bool = true, onPop: (@MainActor () -> Void)? = nil) {
        // Forward to the protocol requirement which has no default parameters
        (self as RouterProtocol).setRoot(presentable, hideBar: hideBar, animated: animated, onPop: onPop)
    }
    
    public func push(_ presentable: Presentable, animated: Bool = true, hideTabBar: Bool = false, onPop: (@MainActor () -> Void)? = nil) {
        (self as RouterProtocol).push(presentable, animated: animated, hideTabBar: hideTabBar, onPop: onPop)
    }
    
    @available(iOS 15.0, *)
    public func present(_ presentable: Presentable, style: ModalStyle = .sheet(), animated: Bool = true, onDismiss: (@MainActor () -> Void)? = nil) {
        (self as RouterProtocol).present(presentable, style: style, animated: animated, onDismiss: onDismiss)
    }
    
    public func dismiss(animated: Bool = true, completion: (@MainActor () -> Void)? = nil) {
        (self as RouterProtocol).dismiss(animated: animated, completion: completion)
    }
    
    public func pop(animated: Bool = true) {
        (self as RouterProtocol).pop(animated: animated)
    }
    
    public func popToRoot(animated: Bool = true) {
        (self as RouterProtocol).popToRoot(animated: animated)
    }
}

/// Default Router implementation with completion-based cleanup
///
/// Uses a dictionary to track per-VC completion closures that are called
/// when the VC is popped (back button, swipe-back) or modal is dismissed.
@available(iOS 15.0, *)
@MainActor
public final class Router: NSObject, RouterProtocol {
    public let navigationController: UINavigationController
    
    /// Completion closures keyed by view controller
    private var completions: [UIViewController: @MainActor () -> Void] = [:]
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    deinit {
        // Cleanup any presented modals
        let nav = navigationController
        Task { @MainActor in
            if nav.presentedViewController != nil {
                nav.dismiss(animated: false)
            }
        }
    }
    
    // MARK: - Navigation
    
    public func setRoot(_ presentable: Presentable, hideBar: Bool = true, animated: Bool = true, onPop: (@MainActor () -> Void)? = nil) {
        let vc = presentable.toViewController()
        if let onPop = onPop { completions[vc] = onPop }
        navigationController.setViewControllers([vc], animated: animated)
        navigationController.isNavigationBarHidden = hideBar
    }
    
    public func push(_ presentable: Presentable, animated: Bool, hideTabBar: Bool, onPop: (@MainActor () -> Void)?) {
        let vc = presentable.toViewController()
        vc.hidesBottomBarWhenPushed = hideTabBar
        // Don't push navigation controllers
        guard vc is UINavigationController == false else { return }
        
        if let onPop = onPop {
            completions[vc] = onPop
        }
        
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public func pop(animated: Bool) {
        if let controller = navigationController.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }
    
    public func popToRoot(animated: Bool) {
        if let controllers = navigationController.popToRootViewController(animated: animated) {
            controllers.forEach { runCompletion(for: $0) }
        }
    }
    
    public func present(_ presentable: Presentable, style: ModalStyle, animated: Bool = true, onDismiss: (@MainActor () -> Void)? = nil) {
        let vc = presentable.toViewController()
        
        switch style {
        case let .sheet(detents, grabber):
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.detents = detents
                sheet.prefersGrabberVisible = grabber
            }
        case .fullScreen:
            vc.modalPresentationStyle = .fullScreen
        case .formSheet:
            vc.modalPresentationStyle = .formSheet
        case .custom(let configure):
            configure(vc)
        }
        
        if let onDismiss = onDismiss {
            completions[vc] = onDismiss
        }
        
        // Set delegate for swipe-to-dismiss handling (non-fullScreen modals)
        if vc.modalPresentationStyle != .fullScreen {
            vc.presentationController?.delegate = self
        }
        
        // Present from the top-most view controller
        let presenter = topMostViewController()
        presenter.present(vc, animated: animated, completion: nil)
    }
    
    public func dismiss(animated: Bool, completion: (@MainActor () -> Void)? = nil) {
        let presenter = topMostViewController()
        if let presented = presenter.presentedViewController ?? (presenter != navigationController ? presenter : nil) {
            runCompletion(for: presented)
        }
        presenter.dismiss(animated: animated, completion: completion)
    }
    
    // MARK: - Private
    
    /// Run and remove the completion for a view controller
    private func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }
    
    /// Find the top-most presented view controller
    private func topMostViewController() -> UIViewController {
        var topVC: UIViewController = navigationController
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
}

// MARK: - UINavigationControllerDelegate

@available(iOS 15.0, *)
extension Router: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        // Detect if a VC was popped (back button or swipe-back)
        guard let poppedVC = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(poppedVC) else {
            return
        }
        runCompletion(for: poppedVC)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

@available(iOS 15.0, *)
extension Router: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // Called when user swipes down to dismiss a modal
        runCompletion(for: presentationController.presentedViewController)
    }
}
