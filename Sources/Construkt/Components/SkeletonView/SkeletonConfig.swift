//
//  👨‍💻 Created by @thatswiftdev on 26/09/25.
//
//  © 2025, https://github.com/thatswiftdev. All rights reserved.
//
//
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

import UIKit

/// The visual styling and animation configuration for the shimmer effect.
public struct SkeletonConfig: Equatable {
    /// Supported directions for the shimmer gradient sweep.
    public enum Direction {
        case leftToRight, rightToLeft, topToBottom, bottomToTop
    }

    /// Base (background) color of the skeleton.
    public var background: UIColor
    /// Highlight color of the moving sheen.
    public var highlight: UIColor

    /// Corner radius applied to the shimmer layer.
    public var cornerRadius: CGFloat
    
    public var maskedCorners: CACornerMask

    /// Width of the highlight band as a fraction of the gradient axis (0.10...0.80).
    /// For the simple "locations" animation, this controls the gap between the outer and middle stop.
    /// w = 0.50 gives the classic [-1, -0.5, 0] → [1, 1.5, 2] look.
    public var highlightWidth: CGFloat

    /// Animation duration (seconds) for one pass across.
    public var duration: CFTimeInterval

    /// Delay before the first loop starts (seconds).
    public var loopDelay: CFTimeInterval

    /// Movement direction (sets gradient start/end points only).
    public var direction: Direction

    /// Whether the shimmer layer should track view bounds changes.
    public var autoLayoutFollowsBounds: Bool

    /// Whether to pause animation when app goes to background.
    public var pausesOnBackground: Bool
    
    public var putLayerToBack: Bool

    public init(
        background: UIColor = UIColor(white: 0.90, alpha: 1.0),
        highlight: UIColor = UIColor(white: 1.0,  alpha: 1.0),
        cornerRadius: CGFloat = 8,
        maskedCorners: CACornerMask = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ],
        highlightWidth: CGFloat = 0.5,
        duration: CFTimeInterval = 1.5,
        loopDelay: CFTimeInterval = 0.0,
        direction: Direction = .leftToRight,
        autoLayoutFollowsBounds: Bool = true,
        pausesOnBackground: Bool = true,
        putLayerToBack: Bool = false
    ) {
        self.background = background
        self.highlight = highlight
        self.cornerRadius = cornerRadius
        self.maskedCorners = maskedCorners
        self.highlightWidth = max(0.10, min(0.80, highlightWidth))
        self.duration = max(0.2, duration)
        self.loopDelay = max(0.0, loopDelay)
        self.direction = direction
        self.autoLayoutFollowsBounds = autoLayoutFollowsBounds
        self.pausesOnBackground = pausesOnBackground
        self.putLayerToBack = putLayerToBack
    }
}

