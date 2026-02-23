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

/// A builder component that wraps a `UIImageView`, enabling simple instantiation from local
/// assets, system images, or remote URLs, and supporting reactive bindings.
public struct ImageView: ModifiableView {
    
    public let modifiableView = Modified(UIImageView())

    // lifecycle
    public init(_ image: UIImage?) {
        modifiableView.image = image
    }

    public init(named name: String) {
        modifiableView.image = UIImage(named: name)
    }

    @available(iOS 13, *)
    public init(systemName name: String) {
        modifiableView.image = UIImage(systemName: name)
    }

    public init(url: URL?, placeholder: UIImage? = nil) {
        modifiableView.setImage(from: url, placeholder: placeholder)
    }

    public init(url: String?, placeholder: UIImage? = nil) {
        if let urlString = url, let url = URL(string: urlString) {
            modifiableView.setImage(from: url, placeholder: placeholder)
        } else {
            modifiableView.image = placeholder
        }
    }

    public init<Binding:RxBinding>(_ image: Binding) where Binding.T == UIImage {
        self.image(bind: image)
    }

    public init<Binding:RxBinding>(_ image: Binding) where Binding.T == UIImage? {
        self.image(bind: image)
    }
    
    // deprecated
    public init(configuration: (_ view: UIImageView) -> Void) {
        configuration(modifiableView)
    }

}


/// Standard modifiers for any `UIImageView` conforming to `ModifiableView`.
extension ModifiableView where Base: UIImageView {

    @discardableResult
    public func tintColor(_ color: UIColor?) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.tintColor, value: color)
    }

}

extension ModifiableView where Base: UIImageView {

    @discardableResult
    public func image<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == UIImage {
        ViewModifier(modifiableView, binding: binding) { $0.image = $1 }
    }

    @discardableResult
    public func image<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == UIImage? {
        ViewModifier(modifiableView, binding: binding) { $0.image = $1 }
    }

}
