//
//  GradientView.swift
//  Construkt
//
//  Created by User on 2026-02-03.
//

import UIKit
import ConstruktKit

public struct GradientView: ModifiableView {
    
    public let modifiableView: UIView
    
    public init(
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0),
        endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)
    ) {
        self.modifiableView = GradientViewInternal(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
}

private class GradientViewInternal: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    init(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        super.init(frame: .zero)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
