//
//  CircleView.swift
//  Construkt
//

import UIKit

public class _CircleView: UIView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        clipsToBounds = true
    }
}

public struct CircleView: ModifiableView {
    public let modifiableView = _CircleView()
    
    public init() {
        modifiableView.translatesAutoresizingMaskIntoConstraints = false
        modifiableView.backgroundColor = .clear
    }
}
