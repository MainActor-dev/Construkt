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

/// An internal storage construct holding specialized builder data (e.g., margins, constraints, lifecycle handlers)
/// that are applied dynamically when a view moves to the window hierarchy.
public class ViewBuilderAttributes {

    var position: UIView.EmbedPosition?
    var insets: UIEdgeInsets?
    var safeArea: Bool?

    var customConstraints: ((_ view: UIView) -> Void)?

    var onAppearHandlers: [(_ context: ViewBuilderContext<UIView>) -> Void] = []
    var onAppearOnceHandlers: [(_ context: ViewBuilderContext<UIView>) -> Void] = []
    var onDisappearHandlers: [(_ context: ViewBuilderContext<UIView>) -> Void] = []

}

// following attributes only apply when view is embedded within a ContainerView, ScrollView, ZStackView, or using when UIView.embed(view)

extension ModifiableView {

    /// Allows applying custom AutoLayout constraints after the view is added to the hierarchy.
    ///
    /// - Parameter constraints: A closure providing the initialized `UIView` for constraint setup.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func customConstraints(_ constraints: @escaping (_ view: UIView) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.builderAttributes()?.customConstraints = constraints
        }
    }

    /// Sets uniform margins applied to all edges when embedded in a container.
    ///
    /// - Parameter value: The margin padding for all edges.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func margins(_ value: CGFloat) -> ViewModifier<Base> {
        margins(insets: UIEdgeInsets(top: value, left: value, bottom: value, right: value))
    }

    /// Sets specific horizontal and vertical margins applied when embedded in a container.
    ///
    /// - Parameters:
    ///   - h: The horizontal margin logic.
    ///   - v: The vertical margin logic.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func margins(h: CGFloat, v: CGFloat) -> ViewModifier<Base> {
        margins(insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }

    /// Sets explicit margins for each edge applied when embedded in a container.
    ///
    /// - Parameters:
    ///   - top: The top margin.
    ///   - left: The left margin.
    ///   - bottom: The bottom margin.
    ///   - right: The right margin.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func margins(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> ViewModifier<Base> {
        margins(insets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }

    /// Sets detailed margins represented by `UIEdgeInsets`.
    ///
    /// - Parameter insets: The insets config.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func margins(insets: UIEdgeInsets) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.builderAttributes()?.insets = insets }
    }

    /// Specifies the alignment constraints of the view when embedded inside a container view.
    /// Useful for placing items centrally or locking to specific edges in composite backgrounds.
    ///
    /// - Parameter position: The `EmbedPosition` configuration (e.g. `.center`, `.topLeading`, etc.)
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func position(_ position: UIView.EmbedPosition) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.builderAttributes()?.position = position
        }
    }

    /// Determines if the container embeddings should respect the `safeAreaInsets`.
    ///
    /// - Parameter safeArea: `true` to constrain to the safe area, `false` to bleed to edges.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func safeArea(_ safeArea: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.builderAttributes()?.safeArea = safeArea
        }
    }

}

extension ViewBuilderAttributes {

    public func commonDidMoveToWindow(_ view: UIView) {
        if view.window == nil {
            onDisappearHandlers.forEach { $0(ViewBuilderContext(view: view)) }
        } else if let vc = view.parentViewController, let nc = vc.navigationController, nc.topViewController == vc {
            if !onAppearOnceHandlers.isEmpty {
                onAppearOnceHandlers.forEach { $0(ViewBuilderContext(view: view)) }
                onAppearOnceHandlers = []
            }
            onAppearHandlers.forEach { $0(ViewBuilderContext(view: view)) }
        }
    }

}

extension UIView {

    private static var BuilderAttributesKey: UInt8 = 0

    internal func builderAttributes() -> ViewBuilderAttributes? {
        if let attributes = objc_getAssociatedObject( self, &UIView.BuilderAttributesKey ) as? ViewBuilderAttributes {
            return attributes
        }
        let attributes = ViewBuilderAttributes()
        objc_setAssociatedObject(self, &UIView.BuilderAttributesKey, attributes, .OBJC_ASSOCIATION_RETAIN)
        return attributes
    }

    public func optionalBuilderAttributes() -> ViewBuilderAttributes? {
        return objc_getAssociatedObject( self, &UIView.BuilderAttributesKey ) as? ViewBuilderAttributes
    }

}

public protocol ViewBuilderEventHandling: UIView {
    // stores into attributes
}

extension ModifiableView where Base: ViewBuilderEventHandling {

    @discardableResult
    public func onAppear(_ handler: @escaping (_ context: ViewBuilderContext<UIView>) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.builderAttributes()?.onAppearHandlers.append(handler) }
    }

    @discardableResult
    public func onAppearOnce(_ handler: @escaping (_ context: ViewBuilderContext<UIView>) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.builderAttributes()?.onAppearOnceHandlers.append(handler) }
    }

    @discardableResult
    public func onDisappear(_ handler: @escaping (_ context: ViewBuilderContext<UIView>) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.builderAttributes()?.onDisappearHandlers.append(handler) }
    }

}
