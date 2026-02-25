//
//  Slider.swift
//  Construkt
//

import UIKit

public class _SliderView: UISlider {
    
}

/// A wrapped slider (UISlider) equivalent to SwiftUI's `Slider`.
public struct Slider: ModifiableView {
    
    public let modifiableView = Modified(_SliderView())
    
    public init(value: Float = 0.0, in range: ClosedRange<Float> = 0.0...1.0) {
        modifiableView.minimumValue = range.lowerBound
        modifiableView.maximumValue = range.upperBound
        modifiableView.value = value
        modifiableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func value<Binding: MutableViewBinding>(_ binding: Binding) -> Self where Binding.Value == Float {
        // Initial setup
        modifiableView.value = binding.value
        
        // Two-way reactive sync
        binding.observe(on: .main) { [weak modifiableView] newValue in
            if modifiableView?.value != newValue {
                modifiableView?.setValue(newValue, animated: true)
            }
        }.store(in: modifiableView.cancelBag)
        
        modifiableView.addAction(UIAction { action in
            guard let view = action.sender as? _SliderView else { return }
            var bound = binding
            bound.value = view.value
        }, for: .valueChanged)
        
        return self
    }
    
    public func minimumTrackTintColor(_ color: UIColor) -> Self {
        modifiableView.minimumTrackTintColor = color
        return self
    }
    
    public func maximumTrackTintColor(_ color: UIColor) -> Self {
        modifiableView.maximumTrackTintColor = color
        return self
    }
    
    public func thumbTintColor(_ color: UIColor) -> Self {
        modifiableView.thumbTintColor = color
        return self
    }
    
    public func isContinuous(_ continuous: Bool) -> Self {
        modifiableView.isContinuous = continuous
        return self
    }
}
