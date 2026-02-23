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
    
    public init<Binding:ViewBinding>(_ binding: Binding) where Binding.Value == Bool {
        isOn(bind: binding)
    }
    
    public init<Binding:MutableViewBinding>(_ binding: Binding) where Binding.Value == Bool {
        isOn(bidirectionalBind: binding)
    }
    
}


/// Extension providing declarative subscription mapping to `UISwitch` control events and properties.
extension ModifiableView where Base: UISwitch {
    
    /// Binds the switch state downstream.
    @discardableResult
    public func isOn<Binding:ViewBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.Value == Bool {
        ViewModifier(modifiableView, binding: binding, keyPath: \.isOn)
    }
    
    /// Bi-directionally binds the switch state with a mutable upstream state container.
    @discardableResult
    public func isOn<Binding:MutableViewBinding>(bidirectionalBind binding: Binding) -> ViewModifier<Base> where Binding.Value == Bool {
        ViewModifier(modifiableView) { switchView in
            binding.observe(on: .main) { [weak switchView] value in
                if switchView?.isOn != value { switchView?.isOn = value }
            }.store(in: switchView.cancelBag)
            
            switchView.addAction(UIAction { [weak switchView] _ in
                if let isOn = switchView?.isOn, isOn != binding.value {
                    var mutableBinding = binding
                    mutableBinding.value = isOn
                }
            }, for: .valueChanged)
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
        ViewModifier(modifiableView) { switchView in
            switchView.addAction(UIAction { [weak switchView] _ in
                guard let view = switchView else { return }
                handler(ViewBuilderValueContext(view: view, value: view.isOn))
            }, for: .valueChanged)
        }
    }

    
}
