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

    /// Sets the default embed placement policy (e.g., center vs. top edge) for children inside the wrapper views dynamically.
    ///
    /// - Parameter position: The `EmbedPosition` configuration logic.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func defaultPosition(_ position: UIView.EmbedPosition) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.position, value: position)
    }

    /// Dictates whether the dynamic container should observe `safeAreaInsets` actively.
    ///
    /// - Parameter safeArea: `true` to confine children to the safe area.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func defaultSafeArea(_ safeArea: Bool) -> ViewModifier<Base> {
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
