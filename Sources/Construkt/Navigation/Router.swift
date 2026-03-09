//
//  Router.swift
//  Construkt
//

import UIKit

public enum SheetDetent {
    case medium
    case large
}

public enum ModalStyle {
    case sheet(detents: [SheetDetent] = [.medium, .large], prefersGrabberVisible: Bool = true)
    case pageSheet
    case fullScreen
    case formSheet
    case custom((UIViewController) -> Void)
}

public protocol Router: AnyObject {
    var navigationController: UINavigationController { get }
    func setRoot(_ module: Presentable, hideBar: Bool, animated: Bool, receiver: AnyEventReceiving?)
    func push(_ module: Presentable, animated: Bool, hideTabBar: Bool, completion: (() -> Void)?, receiver: AnyEventReceiving?)
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
    func present(_ module: Presentable, style: ModalStyle, animated: Bool, completion: (() -> Void)?, receiver: AnyEventReceiving?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

public extension Router {
    func setRoot(_ module: Presentable, hideBar: Bool = false, animated: Bool = true, receiver: AnyEventReceiving? = nil) {
        setRoot(module, hideBar: hideBar, animated: animated, receiver: receiver)
    }
    
    func push(_ module: Presentable, animated: Bool = true, hideTabBar: Bool = false, completion: (() -> Void)? = nil, receiver: AnyEventReceiving? = nil) {
        push(module, animated: animated, hideTabBar: hideTabBar, completion: completion, receiver: receiver)
    }
    
    func pop(animated: Bool = true) {
        pop(animated: animated)
    }
    
    func popToRoot(animated: Bool = true) {
        popToRoot(animated: animated)
    }
    
    func present(_ module: Presentable, style: ModalStyle = .pageSheet, animated: Bool = true, completion: (() -> Void)? = nil, receiver: AnyEventReceiving? = nil) {
        present(module, style: style, animated: animated, completion: completion, receiver: receiver)
    }
    
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismiss(animated: animated, completion: completion)
    }
}

public final class DefaultRouter: NSObject, Router, UINavigationControllerDelegate {
    public let navigationController: UINavigationController
    private var completions: [UIViewController: () -> Void] = [:]
    
    public init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }
    
    public func setRoot(_ module: Presentable, hideBar: Bool = false, animated: Bool = true, receiver: AnyEventReceiving? = nil) {
        let vc = module.toPresentable()
        vc.associatedCoordinator = receiver
        navigationController.setViewControllers([vc], animated: animated)
        navigationController.isNavigationBarHidden = hideBar
    }
    
    public func push(_ module: Presentable, animated: Bool = true, hideTabBar: Bool = false, completion: (() -> Void)? = nil, receiver: AnyEventReceiving? = nil) {
        let vc = module.toPresentable()
        vc.associatedCoordinator = receiver
        vc.hidesBottomBarWhenPushed = hideTabBar
        if let completion = completion {
            completions[vc] = completion
        }
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public func pop(animated: Bool = true) {
        if let vc = navigationController.popViewController(animated: animated) {
            runCompletion(for: vc)
        }
    }
    
    public func popToRoot(animated: Bool = true) {
        let popped = navigationController.popToRootViewController(animated: animated) ?? []
        popped.forEach { runCompletion(for: $0) }
    }
    
    public func present(_ module: Presentable, style: ModalStyle = .pageSheet, animated: Bool = true, completion: (() -> Void)? = nil, receiver: AnyEventReceiving? = nil) {
        let vc = module.toPresentable()
        vc.associatedCoordinator = receiver
        switch style {
        case .pageSheet:
            vc.modalPresentationStyle = .pageSheet
        case .fullScreen:
            vc.modalPresentationStyle = .fullScreen
        case .formSheet:
            vc.modalPresentationStyle = .formSheet
        case .custom(let configure):
            configure(vc)
        default: break
        }
        
        if #available(iOS 15.0, *) {
            if case let .sheet(detents, grabber) = style {
                vc.modalPresentationStyle = .pageSheet
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = detents.map { d in
                        switch d {
                        case .medium: return .medium()
                        case .large: return .large()
                        }
                    }
                    sheet.prefersGrabberVisible = grabber
                }
            }
        }
        
        topMostViewController().present(vc, animated: animated, completion: completion)
    }
    
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        topMostViewController().dismiss(animated: animated, completion: completion)
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromVC = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(fromVC) else { return }
        runCompletion(for: fromVC)
    }
    
    private func runCompletion(for vc: UIViewController) {
        if let completion = completions.removeValue(forKey: vc) {
            completion()
        }
    }
    
    private func topMostViewController(base: UIViewController? = nil) -> UIViewController {
        let base = base ?? navigationController
        if let presented = base.presentedViewController { return topMostViewController(base: presented) }
        if let nav = base as? UINavigationController { return nav.visibleViewController.map { topMostViewController(base: $0) } ?? nav }
        if let tab = base as? UITabBarController { return tab.selectedViewController.map { topMostViewController(base: $0) } ?? tab }
        return base
    }
}
