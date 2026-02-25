//
//  BlurView.swift
//  Construkt
//

import UIKit

/// A declarative wrapper for `UIVisualEffectView` to apply blur effects.
public struct BlurView: ModifiableView {
    
    public let modifiableView: UIVisualEffectView
    
    public init(style: UIBlurEffect.Style) {
        let effect = UIBlurEffect(style: style)
        self.modifiableView = Modified(UIVisualEffectView(effect: effect))
        self.modifiableView.translatesAutoresizingMaskIntoConstraints = false
        self.modifiableView.isUserInteractionEnabled = false
    }
    
    /// Adds a vibrancy effect on top of the blur view.
    public func vibrancy(_ vibrancyEffect: UIVibrancyEffect, @ViewResultBuilder content: @escaping () -> [View]) -> Self {
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = content().map { $0.build() }
        views.forEach { child in
            vibrancyView.contentView.addSubview(child)
            child.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                child.topAnchor.constraint(equalTo: vibrancyView.contentView.topAnchor),
                child.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor),
                child.trailingAnchor.constraint(equalTo: vibrancyView.contentView.trailingAnchor),
                child.bottomAnchor.constraint(equalTo: vibrancyView.contentView.bottomAnchor)
            ])
        }
        
        modifiableView.contentView.addSubview(vibrancyView)
        NSLayoutConstraint.activate([
            vibrancyView.topAnchor.constraint(equalTo: modifiableView.contentView.topAnchor),
            vibrancyView.leadingAnchor.constraint(equalTo: modifiableView.contentView.leadingAnchor),
            vibrancyView.trailingAnchor.constraint(equalTo: modifiableView.contentView.trailingAnchor),
            vibrancyView.bottomAnchor.constraint(equalTo: modifiableView.contentView.bottomAnchor)
        ])
        
        return self
    }
}
