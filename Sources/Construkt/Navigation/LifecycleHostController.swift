//
//  LifecycleHostController.swift
//  Construkt
//

import UIKit

/// A specialized structure designed exclusively to bind Builder Host lifecycle events to declarative closures.
public class ViewLifecycleRegistry {
    var onLoad: (() -> Void)?
    var onAppear: ((Bool) -> Void)?
    var onDisappear: ((Bool) -> Void)?
}

private struct AssociatedKeys {
    static var lifecycleKey: UInt8 = 0
}

/// Specialized ViewModifier extension to capture true UIViewController lifecycles
extension ModifiableView {
    
    // Uses an internal associated object to store the closures before the view is mounted to the host
    private func getRegistry() -> ViewLifecycleRegistry {
        if let registry = objc_getAssociatedObject(self.modifiableView, &AssociatedKeys.lifecycleKey) as? ViewLifecycleRegistry {
            return registry
        }
        let registry = ViewLifecycleRegistry()
        objc_setAssociatedObject(self.modifiableView, &AssociatedKeys.lifecycleKey, registry, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return registry
    }

    /// Triggers when the mounting UIViewController fires `viewDidLoad`
    @discardableResult
    public func onHostDidLoad(_ action: @escaping () -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.getRegistry().onLoad = action }
    }

    /// Triggers when the mounting UIViewController fires `viewWillAppear`
    @discardableResult
    public func onHostWillAppear(_ action: @escaping (_ animated: Bool) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.getRegistry().onAppear = action }
    }
    
    /// Triggers when the mounting UIViewController fires `viewWillDisappear`
    @discardableResult
    public func onHostWillDisappear(_ action: @escaping (_ animated: Bool) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.getRegistry().onDisappear = action }
    }
}

/// The actual View Controller that catches genuine UIKit lifecycles and forwards them to the declarative View
open class LifecycleHostController: UIViewController {
    private let contentView: UIView
    
    public init(contentView: UIView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("[CONSTRUKT 🔨] LifecycleHostController deinit")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        let registry = objc_getAssociatedObject(contentView, &AssociatedKeys.lifecycleKey) as? ViewLifecycleRegistry
        registry?.onLoad?()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let registry = objc_getAssociatedObject(contentView, &AssociatedKeys.lifecycleKey) as? ViewLifecycleRegistry
        registry?.onAppear?(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let registry = objc_getAssociatedObject(contentView, &AssociatedKeys.lifecycleKey) as? ViewLifecycleRegistry
        registry?.onDisappear?(animated)
    }
}

/// Allows ANY pure Construkt declarative View struct to be pushed directly onto a Navigation stack.
extension ViewConvertable {
    /// Packages the declarative view into a `LifecycleHostController`, returning it as a UIViewController.
    public func toPresentable(title: String? = nil) -> UIViewController {
        // Because `asViews()` generates the UIView instances that have the modifiers attached,
        // the returned `contentView` holds the associated lifecycle registry.
        let views = self.asViews()
        let view: UIView
        if views.count == 1 {
            view = views[0].build()
        } else {
            view = UIView()
            views.forEach { abstractView in
                let uiView = abstractView.build()
                uiView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(uiView)
                NSLayoutConstraint.activate([
                    uiView.topAnchor.constraint(equalTo: view.topAnchor),
                    uiView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    uiView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    uiView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
            }
        }
        let host = LifecycleHostController(contentView: view)
        host.title = title
        return host
    }
}
