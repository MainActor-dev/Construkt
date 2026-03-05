import UIKit
import ConstruktKit

/// A lightweight builder component representing a vertical separator line (1px wide) typically used in horizontal stacks.
public struct VerticalDividerView: ModifiableView {
    public let modifiableView: BuilderInternalVerticalDividerView
    
    public init(width: CGFloat = 1.0, verticalInset: CGFloat = 0.0) {
        self.modifiableView = Modified(BuilderInternalVerticalDividerView(frame: .zero)) { view in
            view.intrinsicWidth = max(width, 8.0)
            
            let subview = UIView(frame: .zero)
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
            
            if #available(iOS 13, *) {
                subview.backgroundColor = ViewBuilderEnvironment.defaultSeparatorColor ?? UIColor.secondaryLabel
            } else {
                subview.backgroundColor = ViewBuilderEnvironment.defaultSeparatorColor ?? UIColor.black
            }
            
            // Pin top, bottom with insets, center horizontally, and set custom width.
            subview.topAnchor.constraint(equalTo: view.topAnchor, constant: verticalInset).isActive = true
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -verticalInset).isActive = true
            subview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            subview.widthAnchor.constraint(equalToConstant: width).isActive = true
            
            // Make the container view clear so only the line is visible
            view.backgroundColor = .clear
        }
    }
}

extension ModifiableView where Base: BuilderInternalVerticalDividerView {
    /// Sets the color of the vertical divider line.
    @discardableResult
    public func color(_ color: UIColor?) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.subviews.first?.backgroundColor = color }
    }
}

public class BuilderInternalVerticalDividerView: UIView {
    public var intrinsicWidth: CGFloat = 8.0
    // We override intrinsicContentSize to give the stack view a hint about our width.
    // The height is UIView.noIntrinsicMetric (-1) meaning it will stretch vertically.
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: intrinsicWidth, height: UIView.noIntrinsicMetric)
    }
}
