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

/// A builder component that wraps a `UILabel`, exposing a declarative API for configuring text,
/// fonts, colors, and reactive bindings.
public struct LabelView: ModifiableView {
    
    public let modifiableView = Modified(BuilderInternalUILabel()) {
        $0.font = ViewBuilderEnvironment.defaultLabelFont ?? UIFont.preferredFont(forTextStyle: .callout)
        $0.textColor = ViewBuilderEnvironment.defaultLabelColor ?? $0.textColor
        $0.textAlignment = .left
        $0.adjustsFontForContentSizeCategory = true
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    // lifecycle
    public init(_ text: String?) {
        modifiableView.text = text
    }
    
    public init<Binding:RxBinding>(_ binding: Binding) where Binding.T == String {
        self.text(bind: binding)
    }

    public init<Binding:RxBinding>(_ binding: Binding) where Binding.T == String? {
        self.text(bind: binding)
    }

    public init(_ text: Variable<String>) {
        self.text(bind: text)
    }

    public init(_ text: Variable<String?>) {
        self.text(bind: text)
    }

    // deprecated
    public init(_ text: String?, configuration: (_ view: Base) -> Void) {
        modifiableView.text = text
        configuration(modifiableView)
    }
    
}


/// Standard modifiers for any `UILabel` conforming to `ModifiableView`.
extension ModifiableView where Base: UILabel {
    
    @discardableResult
    public func alignment(_ alignment: NSTextAlignment) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.textAlignment, value: alignment)
    }

    @discardableResult
    public func color(_ color: UIColor?) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.textColor, value: color)
    }
    
    @discardableResult
    public func font(_ font: UIFont?) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.font, value: font)
    }
    
    @discardableResult
    public func font(_ style: UIFont.TextStyle) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.font, value: .preferredFont(forTextStyle: style))
    }

    @discardableResult
    public func lineBreakMode(_ mode: NSLineBreakMode) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.lineBreakMode, value: mode)
    }

    @discardableResult
    public func numberOfLines(_ numberOfLines: Int) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.numberOfLines = numberOfLines
            $0.lineBreakMode = .byWordWrapping
        }
    }

}


extension ModifiableView where Base: UILabel {

    @discardableResult
    public func color<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == UIColor {
        ViewModifier(modifiableView, binding: binding, keyPath: \.textColor)
    }

    @discardableResult
    public func color<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == UIColor? {
        ViewModifier(modifiableView, binding: binding, keyPath: \.textColor)
    }

    @discardableResult
    public func text<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == String {
        ViewModifier(modifiableView, binding: binding) { $0.text = $1 } // binding non-optional to optional
    }

    @discardableResult
    public func text<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == String? {
        ViewModifier(modifiableView, binding: binding, keyPath: \.text)
    }

}


/// A custom subclass of `UILabel` designed to interface smoothly with `ViewBuilder` lifecycle
/// events and handle custom padding logic natively.
public class BuilderInternalUILabel: UILabel, ViewBuilderEventHandling {

    var labelMargins: UIEdgeInsets = .zero
    
    override public var intrinsicContentSize: CGSize {
        numberOfLines = 0       // don't forget!
        var s = super.intrinsicContentSize
        s.height = s.height + labelMargins.top + labelMargins.bottom
        s.width = s.width + labelMargins.left + labelMargins.right
        return s
    }

    override public func drawText(in rect:CGRect) {
        let r = rect.inset(by: labelMargins)
        super.drawText(in: r)
    }

    override public func textRect(forBounds bounds:CGRect, limitedToNumberOfLines n: Int) -> CGRect {
        let b = bounds
        let tr = b.inset(by: labelMargins)
        let ctr = super.textRect(forBounds: tr, limitedToNumberOfLines: 0)
        // that line of code MUST be LAST in this function, NOT first
        return ctr
    }

    override public func didMoveToWindow() {
        optionalBuilderAttributes()?.commonDidMoveToWindow(self)
    }

}

extension BuilderInternalUILabel: ViewBuilderPaddable {

    public func setPadding(_ padding: UIEdgeInsets) {
        labelMargins = padding
    }
    
}

