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


/// A protocol defining an encapsulated style definition that can be applied to a `UIView`.
public protocol BuilderStyle {
    associatedtype Base: UIView
    func apply(to view: Base)
}


extension ModifiableView {

    @discardableResult
    public func style<Style:BuilderStyle>(_ style: Style) -> ViewModifier<Base> where Style.Base == Base {
        ViewModifier(modifiableView) { style.apply(to: $0) }
    }

    @discardableResult
    public func style<Style:BuilderStyle>(_ style: Style) -> ViewModifier<Base> where Style.Base == UIView {
        ViewModifier(modifiableView) { style.apply(to: $0) }
    }

}

//func test() {
//    LabelView("Some text")
//        .style(StyleLabelAccentTitle())
//    ButtonView("Some text")
//        .style(StyleButtonFilled())
//}
