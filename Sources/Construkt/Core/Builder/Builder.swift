//
//  Builder.swift
//  ViewBuilder
//
//  Created by Michael Long on 11/8/21.
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
    public func asBaseView() -> Base {
        modifiableView
    }
    
    public func build() -> UIView {
        modifiableView
    }
    
    @discardableResult
    public func reference<V:UIView>(_ view: inout V?) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { view = $0 as? V }
    }
    
    @discardableResult
    public func with(_ modifier: (_ view: Base) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView, modifier: modifier)
    }
    
    @discardableResult
    public func perform(_ modifier: (_ view: Base) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView, modifier: modifier)
    }
    
    @discardableResult
    public func visible(_ isVisible: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.isHidden = !isVisible }
    }
    
    @discardableResult
    public func skeletonable(
        _ isSkeletonAble: Bool,
        bgColor: UIColor = UIColor(white: 0.90, alpha: 1.0)
    ) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.isSkeletonable = isSkeletonAble
            $0.skeletonConfig = .init(
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
    public let modifiableView: Base
    public init(_ view: Base) {
        self.modifiableView = view
    }
    public init(_ view: View) where Base == UIView {
        self.modifiableView = view()
    }
    public init(_ view: Base, modifier: (_ view: Base) -> Void) {
        self.modifiableView = view
        modifier(view)
    }
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
