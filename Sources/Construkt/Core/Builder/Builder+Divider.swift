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

// Custom builder fot UILabel
public struct DividerView: ModifiableView {

    public let modifiableView = Modified(BuilderInternalDividerView(frame: .zero)) {
        let subview = UIView(frame: .zero)
        $0.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13, *) {
            subview.backgroundColor = ViewBuilderEnvironment.defaultSeparatorColor ?? UIColor.secondaryLabel
        } else {
            subview.backgroundColor = ViewBuilderEnvironment.defaultSeparatorColor ?? UIColor.black
        }
        subview.topAnchor.constraint(equalTo: $0.topAnchor, constant: 4.0).isActive = true
        subview.leftAnchor.constraint(equalTo: $0.leftAnchor).isActive = true
        subview.rightAnchor.constraint(equalTo: $0.rightAnchor).isActive = true
        subview.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        subview.bottomAnchor.constraint(equalTo: $0.bottomAnchor, constant: -4.5).isActive = true
        $0.backgroundColor = .clear
    }

    // lifecycle
    public init() {}

}

extension ModifiableView where Base: BuilderInternalDividerView {

    @discardableResult
    public func color(_ color: UIColor?) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.subviews.first?.backgroundColor = color }
    }

}

public class BuilderInternalDividerView: UIView {}
