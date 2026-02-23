//
//  Created by @thatswiftdev on 11/02/26.
//

import UIKit

/// A declarative builder wrapper around `UIActivityIndicatorView`, providing modifiers
/// for spinning styling and reactive bindings.
public struct ActivityIndicator: ModifiableView {
    
    public let modifiableView = Modified(UIActivityIndicatorView(style: .medium))
    
    public init(style: UIActivityIndicatorView.Style = .medium) {
        modifiableView.style = style
        modifiableView.hidesWhenStopped = true
    }
    
    public func color(_ color: UIColor) -> ActivityIndicator {
        modifiableView.color = color
        return self
    }
    
    public func style(_ style: UIActivityIndicatorView.Style) -> ActivityIndicator {
        modifiableView.style = style
        return self
    }

    public func animating<Binding:ViewBinding>(_ binding: Binding) -> ActivityIndicator where Binding.Value == Bool {
        binding.observe(on: .main) { [weak modifiableView] isAnimating in
            if isAnimating {
                modifiableView?.startAnimating()
            } else {
                modifiableView?.stopAnimating()
            }
        }.store(in: modifiableView.cancelBag)
        return self
    }
}
