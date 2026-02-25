//
//  LinearGradient.swift
//  Construkt
//

import UIKit

public class _GradientView: UIView {
    public override class var layerClass: AnyClass { CAGradientLayer.self }
    public var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
}

/// A declarative wrapper for `CAGradientLayer` to easily apply linear gradients.
public struct LinearGradient: ModifiableView {
    
    public let modifiableView = Modified(_GradientView())
    
    public init(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
        modifiableView.translatesAutoresizingMaskIntoConstraints = false
        modifiableView.isUserInteractionEnabled = false
        
        modifiableView.gradientLayer.colors = colors.map { $0.cgColor }
        modifiableView.gradientLayer.startPoint = startPoint
        modifiableView.gradientLayer.endPoint = endPoint
    }
    
    public func locations(_ locations: [NSNumber]) -> Self {
        modifiableView.gradientLayer.locations = locations
        return self
    }
}
