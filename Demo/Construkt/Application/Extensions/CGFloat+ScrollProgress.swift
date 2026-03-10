import CoreGraphics

extension CGFloat {
    /// Normalizes a scroll offset into the 0…1 range over a given distance.
    /// Useful for fade-in/out effects driven by scroll position.
    func scrollProgress(over distance: CGFloat) -> CGFloat {
        Swift.min(1.0, Swift.max(0.0, self / distance))
    }
}
