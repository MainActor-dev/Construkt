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
import ObjectiveC.runtime

public protocol SkeletonView {
    func setAnimatedSkeletonView(_ isShowing: Bool)
}

public protocol SkeletonDisplayableStatus {
    var isSkeletonShowing: Bool { get set }
}

extension SkeletonView where Self: UIView {
    
    private func setSkeletonStatus(isShowing: Bool) {
        if var view = self as? SkeletonDisplayableStatus {
            view.isSkeletonShowing = isShowing
        }
    }
    
    public func setAnimatedSkeletonView(_ isShowing: Bool) {
        isShowing ? _startShimmer(in: self) : _stopShimmer(in: self)
    }
    
    /// Start shimmering on this view with the given configuration.
    private func startShimmer(_ config: SkeletonConfig = SkeletonConfig()) {
        if let layer = shimmerLayer as? SkeletonLayer {
            layer.apply(config: config)
            layer.start()
            return
        }
        let layer = SkeletonLayer()
        layer.apply(config: config)
        layer.frame = bounds
        layer.masksToBounds = true
        layer.cornerRadius = config.cornerRadius
        layer.maskedCorners = config.maskedCorners
        
        if config.putLayerToBack {
            self.layer.insertSublayer(layer, at: 0)
        } else {
            self.layer.addSublayer(layer)
        }
        
        shimmerLayer = layer

        if config.autoLayoutFollowsBounds {
            ensureLayoutObserver()
        }
        layer.start()
    }

    private func updateShimmer(_ config: SkeletonConfig) {
        guard let layer = shimmerLayer as? SkeletonLayer else { return }
        layer.apply(config: config)
        layer.start()
    }

    private func stopShimmer() {
        (shimmerLayer as? SkeletonLayer)?.stop(removeFromSuperlayer: true)
        shimmerLayer = nil
        removeLayoutObserverIfNeeded()
    }
    
    /// Start shimmer on all matching subviews under `root`.
    /// Precedence: view.shimmerConfigOverride ?? defaultConfig
    public func _startShimmer(
        in root: UIView,
        defaultConfig: SkeletonConfig = .init()
    ) {
        for v in skeletonViews(in: root) {
            v.startShimmer(v.skeletonConfig ?? defaultConfig)
        }
        setSkeletonStatus(isShowing: true)
    }

    /// Stop shimmer on all matching subviews under `root`.
    public func _stopShimmer(in root: UIView) {
        for v in skeletonViews(in: root) {
            v.stopShimmer()
        }
        setSkeletonStatus(isShowing: false)
    }

    /// Recursive finder that returns only the desired subclasses.
    public func skeletonViews(in view: UIView) -> [UIView] {
        var results: [UIView] = []
        for sub in view.subviews {
            if sub.isSkeletonable { results.append(sub) }
            results += skeletonViews(in: sub)
        }
        return results
    }
}

extension UIView: SkeletonView {}

private var shimmerOverrideKey: UInt8 = 0
private var shimmerableKey: UInt8 = 0

public extension UIView {
    /// Set this per view instance to give it a unique shimmer look.
    var skeletonConfig: SkeletonConfig? {
        get { objc_getAssociatedObject(self, &shimmerOverrideKey) as? SkeletonConfig }
        set { objc_setAssociatedObject(self, &shimmerOverrideKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var isSkeletonable: Bool {
        get { (objc_getAssociatedObject(self, &shimmerableKey) as? Bool ?? false) }
        set { objc_setAssociatedObject(self, &shimmerableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
