//
//  ProgressView.swift
//  Construkt
//

import UIKit

public class _ProgressView: UIProgressView {
    
}

/// A wrapped progress view (UIProgressView) equivalent to SwiftUI's `ProgressView` (determinate).
/// For an indeterminate spinner, use `ActivityIndicator`.
public struct ProgressView: ModifiableView {
    
    public let modifiableView = Modified(_ProgressView(progressViewStyle: .default))
    
    public init(value: Float = 0.0, total: Float = 1.0) {
        modifiableView.translatesAutoresizingMaskIntoConstraints = false
        // Normalize the progress to 0.0 ... 1.0 based on the total
        let normalized = total > 0 ? (value / total) : 0
        modifiableView.progress = max(0.0, min(1.0, normalized))
    }
    
    public func value<Binding: ViewBinding>(_ binding: Binding, total: Float = 1.0) -> Self where Binding.Value == Float {
        // Initial normalized setup based on current bound value
        // Note: ViewBinding doesn't guarantee a `.value` property synchronously, 
        // but it will immediately fire if it's a CurrentValueSubject/BehaviorRelay under the hood.
        
        // One-way reactive sync
        binding.observe(on: .main) { [weak modifiableView] newValue in
            let normalized = total > 0 ? (newValue / total) : 0
            modifiableView?.setProgress(max(0.0, min(1.0, normalized)), animated: true)
        }.store(in: modifiableView.cancelBag)
        
        return self
    }
    
    public func progressViewStyle(_ style: UIProgressView.Style) -> Self {
        modifiableView.progressViewStyle = style
        return self
    }
    
    public func progressTintColor(_ color: UIColor) -> Self {
        modifiableView.progressTintColor = color
        return self
    }
    
    public func trackTintColor(_ color: UIColor) -> Self {
        modifiableView.trackTintColor = color
        return self
    }
    
    public func progressImage(_ image: UIImage?) -> Self {
        modifiableView.progressImage = image
        return self
    }
    
    public func trackImage(_ image: UIImage?) -> Self {
        modifiableView.trackImage = image
        return self
    }
}
