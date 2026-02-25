//
//  Toggle.swift
//  Construkt
//

import UIKit

public class _ToggleView: UISwitch {
    
}

/// A wrapped toggle switch (UISwitch) equivalent to SwiftUI's `Toggle`.
public struct Toggle: ModifiableView {
    
    public let modifiableView = Modified(_ToggleView())
    
    public init(isOn: Bool = false) {
        modifiableView.isOn = isOn
        modifiableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func isOn<Binding: MutableViewBinding>(_ binding: Binding) -> Self where Binding.Value == Bool {
        // Initial setup
        modifiableView.isOn = binding.value
        
        // Two-way reactive sync
        binding.observe(on: .main) { [weak modifiableView] newValue in
            if modifiableView?.isOn != newValue {
                modifiableView?.setOn(newValue, animated: true)
            }
        }.store(in: modifiableView.cancelBag)
        
        modifiableView.addAction(UIAction { action in
            guard let view = action.sender as? _ToggleView else { return }
            var bound = binding
            bound.value = view.isOn
        }, for: .valueChanged)
        
        return self
    }
    
    public func onTintColor(_ color: UIColor) -> Self {
        modifiableView.onTintColor = color
        return self
    }
    
    public func thumbTintColor(_ color: UIColor) -> Self {
        modifiableView.thumbTintColor = color
        return self
    }
}
