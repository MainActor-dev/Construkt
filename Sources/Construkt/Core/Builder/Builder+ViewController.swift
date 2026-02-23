//
//  Builder+ViewController.swift
//  ViewBuilder
//
//  Created by Michael Long on 10/4/20.
//  Copyright © 2020 Michael Long. All rights reserved.
//

import UIKit

/// Extends `UIViewController` to allow initializing natively with a Construkt `View` hierarchy.
extension UIViewController {

    /// Convenience initializer mapping a declarative `View` into the controller's main view.
    convenience public init(_ view: View, padding: UIEdgeInsets? = nil, safeArea: Bool = false) {
        self.init()
        if #available(iOS 13, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        self.view.embed(view(), padding: padding, safeArea: safeArea)
    }
    
    public func transition(to view: View, padding: UIEdgeInsets? = nil, safeArea: Bool = false, delay: Double = 0.2) {
        self.view.transition(to: view, padding: padding, safeArea: safeArea, delay: delay)
    }

    public func transition(to viewController: UIViewController, delay: Double) {
        self.view.transition(to: viewController, delay: delay)
    }

}

/// A structural builder component specifically designed to host a child `UIViewController` natively within
/// the declarative view tree.
public struct ViewControllerHostView: ModifiableView {

    public var modifiableView = Modified(BuilderInternalViewControllerHostView()) {
        $0.backgroundColor = .clear
    }

    public init(_ viewController: UIViewController) {
        modifiableView.viewController = viewController
    }

}

/// An internal hosting `UIView` subclass managing custom container child events for `ViewControllerHostView`.
public class BuilderInternalViewControllerHostView: UIView {

    var viewController: UIViewController!

    public init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToWindow() {
        if subviews.isEmpty, let parentViewController = parentViewController {
            parentViewController.addChild(viewController)
            embed(viewController.view)
            viewController.didMove(toParent: parentViewController)
        }
    }

    override public func didMoveToSuperview() {
        if superview == nil {
            viewController?.willMove(toParent: nil)
            viewController?.view.removeFromSuperview()
            viewController?.removeFromParent()
        }
    }

}
