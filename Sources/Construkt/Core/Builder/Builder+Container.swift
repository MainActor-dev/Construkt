//
//  Build+Container.swift
//  ViewBuilder
//
//  Created by Michael Long on 9/28/20.
//  Copyright © 2020 Michael Long. All rights reserved.
//

import UIKit
import RxSwift

/// A lightweight builder component that manages an arbitrary child view layout.
///
/// It provides a straightforward layer to host and dynamically swap content, or layer
/// them similarly to a SwiftUI `ZStack`.
public struct ContainerView: ModifiableView {

    public var modifiableView = Modified(BuilderInternalContainerView(frame: .zero)) {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = true
    }

    public init(_ view: View? = nil) {
        modifiableView.views = view
    }

    public init(@ViewResultBuilder _ builder: () -> ViewConvertable) {
        modifiableView.views = builder()
    }

}

/// An alias for `ContainerView` emphasizing its capability to swap child views dynamically based on state.
public typealias DynamicContainerView = ContainerView

extension DynamicContainerView {
    public init<Value, Binding:RxBinding>(_ binding: Binding, @ViewResultBuilder _ builder: @escaping (_ value: Value) -> ViewConvertable)
    where Binding.T == Value {
        binding.asObservable()
            .subscribe(onNext: { [weak modifiableView] value in
                modifiableView?.transition(to: builder(value))
            })
            .disposed(by: modifiableView.rxDisposeBag)
    }

}

extension ModifiableView where Base: BuilderInternalContainerView {

    @discardableResult
    func defaultPosition(_ position: UIView.EmbedPosition) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.position, value: position)
    }

    @discardableResult
    func defaultSafeArea(_ safeArea: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.safeArea, value: safeArea)
    }

}

/// A custom internal `UIView` subclass dedicated to orchestrating its children under
/// a `ContainerView` or `ZStackView`.
public class BuilderInternalContainerView: UIView, ViewBuilderEventHandling {

    fileprivate var views: ViewConvertable?
    fileprivate var padding: UIEdgeInsets = .zero
    fileprivate var position: EmbedPosition = .fill
    fileprivate var safeArea: Bool = false

    convenience public init(_ view: View?) {
        self.init(frame: .zero)
        self.views = view
    }

    convenience public init(@ViewResultBuilder _ builder: () -> ViewConvertable) {
        self.init(frame: .zero)
        self.views = builder()
    }

    public func transition(to views: ViewConvertable?) {
        if superview == nil {
            self.views = views
        } else if let view = views?.asViews().first {
            transition(to: view)
        }
    }

    override public func didMoveToSuperview() {
        embed(views?.asViews() ?? [], padding: padding, safeArea: safeArea)
        super.didMoveToSuperview()
    }

    override public func didMoveToWindow() {
        optionalBuilderAttributes()?.commonDidMoveToWindow(self)
    }

}

extension BuilderInternalContainerView: ViewBuilderPaddable {

    public func setPadding(_ padding: UIEdgeInsets) {
        self.padding = padding
    }

}
