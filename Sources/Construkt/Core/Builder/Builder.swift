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


/// A result builder that enables a declarative, SwiftUI-like syntax for constructing `UIView` hierarchies.
/// It converts combinations of `ViewConvertable` expressions into a flat array of abstract `View` components.
@resultBuilder public struct ViewResultBuilder {
    public static func buildBlock() -> [View] {
        []
    }
    public static func buildBlock(_ values: ViewConvertable...) -> [View] {
        values.flatMap { $0.asViews() }
    }
    public static func buildIf(_ value: ViewConvertable?) -> ViewConvertable {
        value ?? []
    }
    public static func buildEither(first: ViewConvertable) -> ViewConvertable {
        first
    }
    public static func buildEither(second: ViewConvertable) -> ViewConvertable {
        second
    }
    public static func buildArray(_ components: [[View]]) -> [View] {
        components.flatMap { $0 }
    }
}



/// A protocol representing a type that can be converted into an array of abstract `View` objects.
///
/// This is the fundamental building block for the `ViewResultBuilder`, allowing elements like single views,
/// arrays of views, and dynamic builders to coexist cleanly in the DSL.
public protocol ViewConvertable {
    func asViews() -> [View]
}

// Allows an array of views to be used with ViewResultBuilder
extension Array: ViewConvertable where Element == View {
    public func asViews() -> [View] { self }
}

// Allows an array of an array of views to be used with ViewResultBuilder
extension Array where Element == ViewConvertable {
    public func asViews() -> [View] { self.flatMap { $0.asViews() } }
}

// MARK: - Routing Modifiers

public extension ViewConvertable {
    /// Declaratively catch and handle events bubbling up from child views.
    func onReceiveRoute<E>(_ eventType: E.Type, handler: @escaping @MainActor (E) -> Bool) -> [View] {
        return self.asViews().map { element in
            RouteReceivingModifier(view: element, configurator: { RouteReceivingModifier.configure($0, handler: handler) })
        }
    }
    
    /// Declaratively catch and handle events bubbling up from child views, injecting an unretained target safely.
    func onReceiveRoute<E, Target: AnyObject>(_ eventType: E.Type, on target: Target, handler: @escaping @MainActor (Target, E) -> Bool) -> [View] {
        return self.asViews().map { element in
            RouteReceivingModifier(view: element, configurator: { RouteReceivingModifier.configure($0, target: target, handler: handler) })
        }
    }
    
    /// Declaratively catch and handle events bubbling up from child views, exposing the sender.
    func onReceiveRoute<E>(_ eventType: E.Type, handler: @escaping @MainActor (E, UIResponder?) -> Bool) -> [View] {
        return self.asViews().map { element in
            RouteReceivingModifier(view: element, configurator: { RouteReceivingModifier.configure($0, handler: handler) })
        }
    }
    
    /// Declaratively catch and handle events bubbling up from child views, injecting an unretained target safely, and exposing the sender.
    func onReceiveRoute<E, Target: AnyObject>(_ eventType: E.Type, on target: Target, handler: @escaping @MainActor (Target, E, UIResponder?) -> Bool) -> [View] {
        return self.asViews().map { element in
            RouteReceivingModifier(view: element, configurator: { RouteReceivingModifier.configure($0, target: target, handler: handler) })
        }
    }
}

/// An internal wrapper that securely attaches an `.onReceiveRoute` listener to an arbitrary `View`.
///
/// Because `View` can be anything (including Custom UIViews) and we don't want to enforce global
/// `@MainActor` onto the entire Builder framework and all client views just yet, we wrap the `View`
/// and only attach the native UIKit event listeners when `.build()` is actually called on the main thread.
public struct RouteReceivingModifier: ModifiableView {
    public typealias Base = UIView
    
    private let view: View
    private let configurator: @MainActor (UIView) -> Void
    
    public init(view: View, configurator: @escaping @MainActor (UIView) -> Void) {
        self.view = view
        self.configurator = configurator
    }
    
    @MainActor
    public var modifiableView: UIView {
        let built = view.build()
        configurator(built)
        return built
    }
    
    @MainActor
    fileprivate static func configure<E>(_ view: UIView, handler: @escaping @MainActor (E) -> Bool) {
        // We use the same closure receiver used by EventRouting.swift ModifiableView.onReceiveRoute
        view.associatedReceiver = ClosureRouteReceiver(handler: handler)
    }
    
    @MainActor
    fileprivate static func configure<E, Target: AnyObject>(_ view: UIView, target: Target, handler: @escaping @MainActor (Target, E) -> Bool) {
        view.associatedReceiver = TargetedClosureRouteReceiver(target: target, handler: handler)
    }
    
    @MainActor
    fileprivate static func configure<E>(_ view: UIView, handler: @escaping @MainActor (E, UIResponder?) -> Bool) {
        view.associatedReceiver = SenderClosureRouteReceiver(handler: handler)
    }
    
    @MainActor
    fileprivate static func configure<E, Target: AnyObject>(_ view: UIView, target: Target, handler: @escaping @MainActor (Target, E, UIResponder?) -> Bool) {
        view.associatedReceiver = TargetedSenderClosureRouteReceiver(target: target, handler: handler)
    }
}



/// An abstract representation of a UI component that knows how to build a tangible `UIView`.
///
/// Types conforming to this protocol can be used inside `ViewResultBuilder` blocks to assemble UI hierarchically.
public protocol View: ViewConvertable {
    func build() -> UIView
    func callAsFunction() -> UIView
}

// Allow any view to be automatically be ViewConvertable
extension View {
    public func asViews() -> [View] {
        [build()]
    }
    public func callAsFunction() -> UIView {
        build()
    }
}

/// A specialized `View` that exposes an underlying `UIView` of a specific type (`Base`) for modification.
///
/// Conform to this protocol when you want to use the standard chainable `ViewModifier` methods
/// (like `.hidden()`, `.backgroundColor()`, etc.) on a custom object wrapping a `UIView`.
public protocol ModifiableView: View {
    associatedtype Base: UIView
    var modifiableView: Base { get }
}

// Standard "builder" modifiers for all view types
extension ModifiableView {
    
    /// Returns the underlying base `UIView` instance.
    public func asBaseView() -> Base {
        modifiableView
    }
    
    /// Returns the underlying base `UIView` instance, fulfilling the `View` protocol.
    public func build() -> UIView {
        modifiableView
    }
    
    /// Captures a reference to the underlying `UIView`, allowing it to be stored in a variable.
    ///
    /// - Parameter view: An `inout` reference to store the view.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func reference<V:UIView>(_ view: inout V?) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { view = $0 as? V }
    }
    
    /// Performs a generic modification closure on the underlying `UIView`.
    ///
    /// - Parameter modifier: A closure containing the modification logic.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func with(_ modifier: (_ view: Base) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView, modifier: modifier)
    }
    
    /// Performs a generic modification closure on the underlying `UIView`. Alias for `with`.
    ///
    /// - Parameter modifier: A closure containing the modification logic.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func perform(_ modifier: (_ view: Base) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView, modifier: modifier)
    }
    
    /// Toggles the visibility (`isHidden`) state of the underlying `UIView`.
    ///
    /// - Parameter isVisible: A boolean determining if the view should be visible.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func visible(_ isVisible: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.isHidden = !isVisible }
    }
    
    /// Configures the view to support `_ShimmerView` loading states.
    ///
    /// - Parameters:
    ///   - is_ShimmerAble: A boolean enabling shimmer animations on this view.
    ///   - bgColor: The background color used during the shimmer state.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func shimmerable(
        _ is_ShimmerAble: Bool,
        bgColor: UIColor = UIColor(white: 0.90, alpha: 1.0)
    ) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.isShimmerable = is_ShimmerAble
            $0.shimmerConfig = .init(
                background: bgColor,
                pausesOnBackground: false
            )
        }
    }
}

/// A generic wrapper type used to chain sequential modifications to a `UIView`.
///
/// Each builder method (e.g. `.backgroundColor(:)`) returns a `ViewModifier` retaining the original underlying `UIView`.
public struct ViewModifier<Base:UIView>: ModifiableView {
    
    /// The underlying view being modified.
    public let modifiableView: Base
    
    /// Initializes with an existing base view.
    public init(_ view: Base) {
        self.modifiableView = view
    }
    
    /// Initializes by building an abstract `View` into its tangible `UIView` form.
    public init(_ view: View) where Base == UIView {
        self.modifiableView = view()
    }
    
    /// Initializes with an existing base view and immediately applies a custom modifier closure to it.
    public init(_ view: Base, modifier: (_ view: Base) -> Void) {
        self.modifiableView = view
        modifier(view)
    }
    
    /// Initializes with an existing base view and modifies a specific property via its `ReferenceWritableKeyPath`.
    public init<Value>(_ view: Base, keyPath: ReferenceWritableKeyPath<Base, Value>, value: Value) {
        self.modifiableView = view
        self.modifiableView[keyPath: keyPath] = value
    }
}



/// A convenience utility for instantiating and configuring a `UIView` subclass in a single expression.
///
/// - Parameters:
///   - instance: The view instance to modify.
///   - modify: A closure exposing the instance for inline configuration.
/// - Returns: The configured `UIView` instance.
public func Modified<T:UIView>( _ instance: T, modify: ((_ instance: T) -> Void)? = nil) -> T {
    // common modifications
    instance.translatesAutoresizingMaskIntoConstraints = false
    // user modifications
    modify?(instance)
    return instance
}



/// A protocol that enables building custom composite views declaratively.
///
/// Conforming objects implement the `body` property using the `ViewResultBuilder` syntax
/// to combine existing primitive views into higher-level, reusable components.
public protocol ViewBuilder: ModifiableView {
    
    /// The declarative body of the composite view component.
    var body: View { get }
}

extension ViewBuilder {
    // adapt viewbuilder to enable basic modifications
    public var modifiableView: UIView {
        body()
    }
    // allow basic conversion to UIView
    public func build() -> UIView {
        body()
    }
}



/// A central configuration store for default styling properties across Construkt builders.
///
/// By providing ambient constants here, components like `Button` and `Label` can inherit standard
/// application aesthetics without declaring style modifiers explicitly on every instance.
public struct ViewBuilderEnvironment {
    static public var defaultButtonFont: UIFont?
    static public var defaultButtonColor: UIColor?
    static public var defaultLabelFont: UIFont?
    static public var defaultLabelColor: UIColor?
    static public var defaultLabelSecondaryColor: UIColor?
    static public var defaultSeparatorColor: UIColor?
}
