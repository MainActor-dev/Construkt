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

import Foundation
import UIKit
import RxSwift
import RxCocoa

/// A builder component that wraps a `UITextField`, providing a declarative configuration interface
/// and bidirectional responsive bindings.
public struct TextField: ModifiableView {

    public let modifiableView: UITextField = Modified(UITextField()) {
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    // lifecycle
    public init() {

    }

    public init(_ text: String?) {
        modifiableView.text = text
    }
    
    public init<Binding:RxBinding>(_ binding: Binding) where Binding.T == String? {
        text(bind: binding)
    }

    public init<Binding:RxBidirectionalBinding>(_ binding: Binding) where Binding.T == String {
        text(bidirectionalBind: binding)
    }

    public init<Binding:RxBidirectionalBinding>(_ binding: Binding) where Binding.T == String? {
        text(bidirectionalBind: binding)
    }

}


extension ModifiableView where Base: UITextField {

    @discardableResult
    public func autocapitalizationType(_ type: UITextAutocapitalizationType) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.autocapitalizationType, value: type)
    }

    @discardableResult
    public func autocorrectionType(_ type: UITextAutocorrectionType) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.autocorrectionType, value: type)
    }

    @discardableResult
    public func enablesReturnKeyAutomatically(_ enabled: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.enablesReturnKeyAutomatically, value: enabled)
    }

    @discardableResult
    public func inputView(_ view: UIView?) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.inputView, value: view)
    }

    @discardableResult
    public func inputAccessoryView(_ view: UIView?) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.inputAccessoryView, value: view)
    }

    @discardableResult
    public func keyboardType(_ type: UIKeyboardType) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.keyboardType, value: type)
    }

    @discardableResult
    public func placeholder(_ placeholder: String?) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.placeholder, value: placeholder)
    }

    @discardableResult
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.returnKeyType, value: returnKeyType)
    }

    @discardableResult
    public func secureTextEntry(_ secure: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.isSecureTextEntry, value: secure)
    }

    @discardableResult
    public func textContentType(_ textContentType: UITextContentType) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.textContentType, value: textContentType)
    }

}

extension ModifiableView where Base: UITextField {

    @discardableResult
    public func text<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == String? {
        ViewModifier(modifiableView, binding: binding, keyPath: \.text)
    }

    @discardableResult
    public func text<Binding:RxBidirectionalBinding>(bidirectionalBind binding: Binding) -> ViewModifier<Base> where Binding.T == String {
        ViewModifier(modifiableView) { textField in
            let relay = binding.asRelay()
            textField.rxDisposeBag.insert(
                relay
                    .observe(on: ConcurrentMainScheduler.instance)
                    .subscribe(onNext: { [weak textField] text in
                        if let textField = textField, textField.text != text {
                            textField.text = text
                        }
                    }),
                textField.rx.text
                    .subscribe(onNext: { [weak relay] text in
                        if let relay = relay, relay.value != text {
                            relay.accept(text ?? "")
                        }
                    })
            )
        }
    }

    @discardableResult
    public func text<Binding:RxBidirectionalBinding>(bidirectionalBind binding: Binding) -> ViewModifier<Base> where Binding.T == String? {
        ViewModifier(modifiableView) { textField in
            let relay = binding.asRelay()
            textField.rxDisposeBag.insert(
                relay
                    .observe(on: ConcurrentMainScheduler.instance)
                    .subscribe(onNext: { [weak textField] text in
                        if let textField = textField, textField.text != text {
                            textField.text = text
                        }
                    }),
                textField.rx.text
                    .subscribe(onNext: { [weak relay] text in
                        if let relay = relay, relay.value != text {
                            relay.accept(text)
                        }
                    })
            )
        }
    }
}


/// Extension providing declarative subscription mapping to `UITextField` control events.
extension ModifiableView where Base: UITextField {
    public func onControlEvent(_ event: UIControl.Event,
                               handler: @escaping (_ context: ViewBuilderValueContext<UITextField, String?>) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.rx.controlEvent([event])
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [unowned modifiableView] () in
                    handler(ViewBuilderValueContext(view: modifiableView, value: modifiableView.text))
                })
                .disposed(by: $0.rxDisposeBag)
        }
    }

    @discardableResult
    public func onChange(_ handler: @escaping (_ context: ViewBuilderValueContext<UITextField, String?>) -> Void) -> ViewModifier<Base> {
        onControlEvent(.editingChanged, handler: handler)
    }

    @discardableResult
    public func onEditingDidBegin(_ handler: @escaping (_ context: ViewBuilderValueContext<UITextField, String?>) -> Void) -> ViewModifier<Base> {
        onControlEvent(.editingDidBegin, handler: handler)
    }

    @discardableResult
    public func onEditingDidEnd(_ handler: @escaping (_ context: ViewBuilderValueContext<UITextField, String?>) -> Void) -> ViewModifier<Base> {
        onControlEvent(.editingDidEnd, handler: handler)
    }

    @discardableResult
    public func onEditingDidEndOnExit(_ handler: @escaping (_ context: ViewBuilderValueContext<UITextField, String?>) -> Void) -> ViewModifier<Base> {
        onControlEvent(.editingDidEndOnExit, handler: handler)
    }

}
