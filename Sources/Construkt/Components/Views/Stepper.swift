//
//  Stepper.swift
//  Construkt
//

import UIKit

public class _StepperView: UIStepper {
    
}

/// A wrapped stepper (UIStepper) equivalent to SwiftUI's `Stepper`.
public struct Stepper: ModifiableView {
    
    public let modifiableView = Modified(_StepperView())
    
    public init(value: Double = 0.0, in range: ClosedRange<Double> = 0.0...100.0, step: Double = 1.0) {
        modifiableView.minimumValue = range.lowerBound
        modifiableView.maximumValue = range.upperBound
        modifiableView.stepValue = step
        modifiableView.value = value
        modifiableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func value<Binding: MutableViewBinding>(_ binding: Binding) -> Self where Binding.Value == Double {
        // Initial setup
        modifiableView.value = binding.value
        
        // Two-way reactive sync
        binding.observe(on: .main) { [weak modifiableView] newValue in
            if modifiableView?.value != newValue {
                modifiableView?.value = newValue
            }
        }.store(in: modifiableView.cancelBag)
        
        modifiableView.addAction(UIAction { action in
            guard let view = action.sender as? _StepperView else { return }
            var bound = binding
            bound.value = view.value
        }, for: .valueChanged)
        
        return self
    }
    
    public func isContinuous(_ continuous: Bool) -> Self {
        modifiableView.isContinuous = continuous
        return self
    }
    
    public func autorepeat(_ repeatEnabled: Bool) -> Self {
        modifiableView.autorepeat = repeatEnabled
        return self
    }
    
    public func wraps(_ wraps: Bool) -> Self {
        modifiableView.wraps = wraps
        return self
    }
}
