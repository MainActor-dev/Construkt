//
//  👨‍💻 Created by @thatswiftdev on 23/02/26.
//  © 2026, https://github.com/thatswiftdev. All rights reserved.
//
//  Originally created by Michael Long
//  https://github.com/hmlongco/Builder

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
    
    /// Wraps the provided view transition over this controller's main `view`.
    public func transition(to view: View, padding: UIEdgeInsets? = nil, safeArea: Bool = false, delay: Double = 0.2) {
        self.view.transition(to: view, padding: padding, safeArea: safeArea, delay: delay)
    }

    /// Wraps the provided controller transition over this controller's main `view`.
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
