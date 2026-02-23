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

/// A flexible empty space view designed to push sibling views apart in a `StackView`.
public struct SpacerView: ModifiableView {

    public var modifiableView = Modified(UIView())
    
    /// Initializes a flexible spacer that tries to expand horizontally and vertically.
    public init() {
        modifiableView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        modifiableView.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    /// Initializes a flexible spacer with a minimum height for vertical stacks.
    public init(h: CGFloat = 16) {
        modifiableView.heightAnchor.constraint(greaterThanOrEqualToConstant: h).isActive = true
        modifiableView.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    /// Initializes a flexible spacer with a minimum width for horizontal stacks.
    public init(w: CGFloat = 8) {
        modifiableView.widthAnchor.constraint(greaterThanOrEqualToConstant: w).isActive = true
        modifiableView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
}

/// A rigid empty space view designed to hold a static footprint in a `StackView` layout without expanding.
public struct FixedSpacerView: ModifiableView {

    public var modifiableView = Modified(UIView())
    
    /// Initializes a rigid spacer that heavily resists stretching or compressing.
    public init() {
        modifiableView.setContentHuggingPriority(.required, for: .horizontal)
        modifiableView.setContentHuggingPriority(.required, for: .vertical)
    }

    /// Initializes a rigid vertical spacer locked to a specific height.
    public init(_ height: CGFloat = 16) {
        modifiableView.heightAnchor.constraint(equalToConstant: height).isActive = true
        modifiableView.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    /// Initializes a rigid horizontal spacer locked to a specific width.
    public init(width: CGFloat = 8) {
        modifiableView.widthAnchor.constraint(equalToConstant: width).isActive = true
        modifiableView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
}
