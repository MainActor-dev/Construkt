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


/// Protocol adopted by custom `.padding()`-compatible views (like `StackView` or `Label`) that natively
/// support internal content margins.
public protocol ViewBuilderPaddable {
    func setPadding(_ padding: UIEdgeInsets)
}


/// Extensions giving natively paddable views SwiftUI-style fluent padding injection methods.
extension ModifiableView where Base: ViewBuilderPaddable {
    
    @discardableResult
    public func padding(_ value: CGFloat) -> ViewModifier<Base> {
        padding(insets: UIEdgeInsets(top: value, left: value, bottom: value, right: value))
    }
    
    @discardableResult
    public func padding(h: CGFloat, v: CGFloat) -> ViewModifier<Base> {
        padding(insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }
    
    @discardableResult
    public func padding(
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) -> ViewModifier<Base> {
        padding(insets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }
    
    @discardableResult
    public func padding(insets: UIEdgeInsets) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.setPadding(insets) }
    }
    
}

