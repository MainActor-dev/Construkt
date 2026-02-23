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
import RxCocoa


/// A builder component that wraps a `UIButton`, providing declarative methods for titles, colors, fonts,
/// and RxSwift tap handlers.
public struct ButtonView: ModifiableView {
    
    public let modifiableView = Modified(UIButton()) {
        $0.setTitleColor(ViewBuilderEnvironment.defaultButtonColor ?? $0.tintColor, for: .normal)
        $0.titleLabel?.font = ViewBuilderEnvironment.defaultButtonFont ?? .preferredFont(forTextStyle: .headline)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    // lifecycle
    public init(_ title: String? = nil) {
        modifiableView.setTitle(title, for: .normal)
    }
    
    public init(_ title: String? = nil, action: @escaping (_ context: ViewBuilderContext<UIButton>) -> Void) {
        modifiableView.setTitle(title, for: .normal)
        onTap(action)
    }
}


/// Standard modifiers for any `UIButton` conforming to `ModifiableView`.
extension ModifiableView where Base: UIButton {

    /// Adjusts the horizontal content alignment of the button.
    ///
    /// - Parameter alignment: The alignment enum value to set.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func alignment(_ alignment: UIControl.ContentHorizontalAlignment) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.contentHorizontalAlignment, value: alignment)
    }

    /// Sets the background color of the button for a specific control state, by synthesizing a solid color image.
    ///
    /// - Parameters:
    ///   - color: The color to apply.
    ///   - state: The control state triggering the color.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func backgroundColor(_ color: UIColor, for state: UIControl.State) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.setBackgroundImage(UIImage(color: color), for: state) }
    }

    /// Sets the title color of the button.
    ///
    /// - Parameters:
    ///   - color: The color to apply to the text.
    ///   - state: The control state triggering the color, defaulting to `.normal`.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func color(_ color: UIColor, for state: UIControl.State = .normal) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.setTitleColor(color, for: state) }
    }

    /// Applies a specific `UIFont` to the title label.
    ///
    /// - Parameter font: The font to apply.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func font(_ font: UIFont?) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.titleLabel?.font = font }
    }

    /// Applies a standard dynamic type font style to the title label.
    ///
    /// - Parameter style: The text style, e.g. `.headline`, `.body`.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func font(_ style: UIFont.TextStyle) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.titleLabel?.font = .preferredFont(forTextStyle: style) }
    }

    /// Attaches an `RxSwift` tap handler to the button, automatically throttled to prevent double taps.
    ///
    /// - Parameter handler: A closure providing the builder context for contextual access.
    /// - Returns: A modified view wrapper.
    @discardableResult
    public func onTap(_ handler: @escaping (_ context: ViewBuilderContext<UIButton>) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { [unowned modifiableView] view in
            view.rx.tap
                .throttle(.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
                .subscribe(onNext: { () in handler(ViewBuilderContext(view: modifiableView)) })
                .disposed(by: view.rxDisposeBag)
        }
    }

}

extension UIButton: ViewBuilderPaddable {
    
    public func setPadding(_ padding: UIEdgeInsets) {
        self.contentEdgeInsets = padding
    }

}
