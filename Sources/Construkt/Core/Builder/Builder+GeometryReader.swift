//
//  Builder+GeometryReader.swift
//  Construkt
//
//  A SwiftUI-equivalent GeometryReader for the Construkt declarative UIKit framework.
//  Provides child views with a GeometryProxy describing the container's dimensions,
//  enabling size-dependent layouts, proportional sizing, and adaptive content.
//

import UIKit


// MARK: - GeometryProxy

/// An immutable snapshot of the GeometryReader container's layout metrics.
///
/// Passed into the GeometryReader's builder closure each time the container's bounds change.
/// Use it to create geometry-dependent layouts such as proportional sizing, adaptive breakpoints,
/// and coordinate-space conversions.
public struct GeometryProxy {

    /// The laid-out size (width × height) of the GeometryReader container.
    public let size: CGSize

    /// The safe area insets of the container at the time of layout.
    public let safeAreaInsets: UIEdgeInsets

    /// Weak reference to the container view for coordinate conversion.
    private weak var containerView: UIView?

    internal init(size: CGSize, safeAreaInsets: UIEdgeInsets, containerView: UIView) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
        self.containerView = containerView
    }

    /// Returns the container's frame converted into the coordinate space of the given target view.
    ///
    /// - Parameter targetView: The view whose coordinate space to convert into.
    ///   Pass `nil` to get the frame in the window's coordinate space.
    /// - Returns: The converted frame, or `.zero` if the container is no longer in the hierarchy.
    public func frame(in targetView: UIView? = nil) -> CGRect {
        guard let container = containerView else { return .zero }
        if let target = targetView {
            return container.convert(container.bounds, to: target)
        } else {
            return container.convert(container.bounds, to: nil) // window coordinates
        }
    }

}


// MARK: - GeometryReaderInternalView

/// An internal `UIView` subclass that observes its own layout and rebuilds child content
/// whenever the resolved geometry changes.
///
/// Modeled after `BuilderInternalContainerView` — children are built lazily on `didMoveToSuperview()`
/// and rebuilt on `layoutSubviews()` whenever `bounds.size` changes.
public class GeometryReaderInternalView: UIView, ViewBuilderRouteReceiving {

    fileprivate let builder: (GeometryProxy) -> ViewConvertable
    fileprivate var lastBuiltSize: CGSize = .zero
    fileprivate var position: UIView.EmbedPosition = .fill
    fileprivate var safeArea: Bool = false
    fileprivate var padding: UIEdgeInsets = .zero
    fileprivate var hasMovedToSuperview: Bool = false

    init(builder: @escaping (GeometryProxy) -> ViewConvertable) {
        self.builder = builder
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override public func didMoveToSuperview() {
        hasMovedToSuperview = true
        rebuildIfNeeded()
        super.didMoveToSuperview()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        rebuildIfNeeded()
    }

    override public func didMoveToWindow() {
        optionalBuilderAttributes()?.commonDidMoveToWindow(self)
    }

    // MARK: Hit Testing

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        // Pass through if the container itself is hit (not a subview),
        // the background is clear, and it has no gesture recognizers.
        if hitView == self && backgroundColor == .clear {
            if let recognizers = gestureRecognizers, !recognizers.isEmpty {
                return hitView
            }
            return nil
        }

        return hitView
    }

    // MARK: Rebuild Logic

    fileprivate func rebuildIfNeeded() {
        guard hasMovedToSuperview, superview != nil else { return }
        let currentSize = bounds.size
        guard currentSize != .zero, currentSize != lastBuiltSize else { return }
        lastBuiltSize = currentSize

        let proxy = GeometryProxy(
            size: currentSize,
            safeAreaInsets: safeAreaInsets,
            containerView: self
        )

        let views = builder(proxy).asViews()
        subviews.forEach { $0.removeFromSuperview() }
        embed(views, padding: padding, safeArea: safeArea)
    }

}

// MARK: - ViewBuilderPaddable

extension GeometryReaderInternalView: ViewBuilderPaddable {

    public func setPadding(_ padding: UIEdgeInsets) {
        self.padding = padding
    }

}

// MARK: - GeometryReaderInternalView Modifier Extensions

extension ModifiableView where Base: GeometryReaderInternalView {

    /// Sets the default embed placement policy for children inside the GeometryReader.
    ///
    /// - Parameter position: The `EmbedPosition` configuration (e.g., `.center`, `.fill`).
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func defaultPosition(_ position: UIView.EmbedPosition) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.position, value: position)
    }

    /// Dictates whether the GeometryReader should respect `safeAreaInsets` when embedding children.
    ///
    /// - Parameter safeArea: `true` to confine children to the safe area.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func defaultSafeArea(_ safeArea: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.safeArea, value: safeArea)
    }

}


// MARK: - GeometryReader (Public API)

/// A declarative container view that provides its child content with geometry information
/// about the container's dimensions and position.
///
/// Use `GeometryReader` to create layouts that depend on the available space, such as
/// proportional sizing, adaptive breakpoints, or coordinate-aware positioning.
///
/// ```swift
/// GeometryReader { proxy in
///     ImageView(heroImage)
///         .height(proxy.size.height * 0.6)
///         .width(proxy.size.width)
/// }
///
/// GeometryReader { proxy in
///     if proxy.size.width > 500 {
///         HStackView {
///             SidebarView()
///             ContentView()
///         }
///     } else {
///         VStackView {
///             ContentView()
///         }
///     }
/// }
/// ```
public struct GeometryReader: ModifiableView {

    public var modifiableView: GeometryReaderInternalView

    /// Creates a geometry-aware container whose content is a function of the available space.
    ///
    /// - Parameter builder: A closure that receives a `GeometryProxy` and returns the child view hierarchy.
    ///   This closure is re-evaluated whenever the container's bounds change.
    public init(@ViewResultBuilder _ builder: @escaping (GeometryProxy) -> ViewConvertable) {
        self.modifiableView = Modified(GeometryReaderInternalView(builder: builder)) {
            $0.backgroundColor = .clear
            $0.isUserInteractionEnabled = true
        }
    }

}
