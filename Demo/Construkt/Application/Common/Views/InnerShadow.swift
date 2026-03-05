import UIKit
import ConstruktKit

/// A declarative component that applies an inner shadow.
public struct InnerShadow: ViewBuilder {
    private let color: UIColor
    private let radius: CGFloat
    private let offsetX: CGFloat
    private let offsetY: CGFloat
    
    public init(color: UIColor, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.offsetX = x
        self.offsetY = y
    }
    
    public var body: View {
        let shadowView = _InnerShadowView(color: color, blurRadius: radius, offset: CGSize(width: offsetX, height: offsetY))
        return Modified(shadowView)
    }
}

public class _InnerShadowView: UIView {
    private let shadowLayer = CAShapeLayer()
    
    private let shadowColorObj: UIColor
    private let blurRadius: CGFloat
    private let offset: CGSize
    
    public init(color: UIColor, blurRadius: CGFloat, offset: CGSize) {
        self.shadowColorObj = color
        self.blurRadius = blurRadius
        self.offset = offset
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        
        shadowLayer.fillRule = .evenOdd
        shadowLayer.shadowColor = shadowColorObj.cgColor
        shadowLayer.shadowOpacity = 1.0 // Base opacity comes from the UIColor alpha
        shadowLayer.shadowRadius = blurRadius
        shadowLayer.shadowOffset = offset
        
        // This is necessary to clip the inner shadow to the bounds, avoiding outer bleeding
        self.layer.masksToBounds = true
        self.layer.addSublayer(shadowLayer)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Calculate the maximum bleed distance of the shadow to avoid arbitrary large numbers
        let maxBleed = max(blurRadius, max(abs(offset.width), abs(offset.height)))
        let safeInset = -(maxBleed + 10)
        
        // Strategy for Inner Shadows using Core Animation:
        // We create a very large outer rect, and cut a hole exactly the size of our bounds.
        // The shadow from the outer rect bleeds inwards into our bounds.
        
        let path = UIBezierPath(rect: bounds.insetBy(dx: safeInset, dy: safeInset))
        let innerPath = UIBezierPath(rect: bounds).reversing()
        path.append(innerPath)
        
        shadowLayer.path = path.cgPath
    }
}
