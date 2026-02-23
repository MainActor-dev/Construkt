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

/// A builder component that wraps a `UISwitch`, offering declarative two-way bindings to its value.
public struct SwitchView: ModifiableView {
    
    public let modifiableView: UISwitch = Modified(UISwitch()) {
        $0.onTintColor = ViewBuilderEnvironment.defaultButtonColor
        $0.contentHuggingPriority(.required, for: .horizontal)
    }
    
    // lifecycle
    public init(_ isOn: Bool = true) {
        modifiableView.isOn = isOn
    }
    
    public init<Binding:RxBinding>(_ binding: Binding) where Binding.T == Bool {
        isOn(bind: binding)
    }
    
    public init<Binding:RxBidirectionalBinding>(_ binding: Binding) where Binding.T == Bool {
        isOn(bidirectionalBind: binding)
    }
    
}


/// Extension providing declarative subscription mapping to `UISwitch` control events and properties.
extension ModifiableView where Base: UISwitch {
    
    /// Binds the switch state downstream.
    @discardableResult
    public func isOn<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == Bool {
        ViewModifier(modifiableView, binding: binding, keyPath: \.isOn)
    }
    
    /// Bi-directionally binds the switch state with a mutable upstream state container.
    @discardableResult
    public func isOn<Binding:RxBidirectionalBinding>(bidirectionalBind binding: Binding) -> ViewModifier<Base> where Binding.T == Bool {
        ViewModifier(modifiableView) { switchView in
            let relay = binding.asRelay()
            switchView.rxDisposeBag.insert(
                relay
                    .observe(on: ConcurrentMainScheduler.instance)
                    .subscribe(onNext: { [weak switchView] value in
                        if let view = switchView, view.isOn != value {
                            view.isOn = value
                        }
                    }),
                switchView.rx.isOn
                    .subscribe(onNext: { [weak relay] value in
                        if let relay = relay, relay.value != value {
                            relay.accept(value)
                        }
                    })
            )
        }
    }
    
    /// Sets the color of the switch when it is turned on.
    @discardableResult
    public func onTintColor(_ color: UIColor?) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.onTintColor, value: color)
    }
        
    /// Reacts continuously to user-driven changes to the switch value.
    @discardableResult
    public func onChange(_ handler: @escaping (_ context: ViewBuilderValueContext<UISwitch, Bool>) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.rx.isOn
                .changed
                .subscribe(onNext: { [unowned modifiableView] value in
                    handler(ViewBuilderValueContext(view: modifiableView, value: modifiableView.isOn))
                })
                .disposed(by: $0.rxDisposeBag)
        }
    }

    
}
