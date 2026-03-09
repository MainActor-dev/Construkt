import UIKit

public class _GradientLabelView: UIView {
    public let label = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        label.backgroundColor = .clear
        layer.addSublayer(gradientLayer)
        
        // Use label as a mask
        self.mask = label
    }
    
    public override var intrinsicContentSize: CGSize {
        return label.intrinsicContentSize
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        label.frame = bounds
    }
    
    public func applyGradient(colors: [UIColor], start: CGPoint = CGPoint(x: 0, y: 0.5), end: CGPoint = CGPoint(x: 1, y: 0.5)) {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
    }
}

/// A declarative wrapper for `_GradientLabelView` to easily apply linear gradients to text.
public struct GradientLabelView: ModifiableView {
    public let modifiableView = Modified(_GradientLabelView())
    
    public init(_ text: String, colors: [UIColor]) {
        modifiableView.translatesAutoresizingMaskIntoConstraints = false
        modifiableView.label.text = text
        modifiableView.applyGradient(colors: colors)
    }
    
    public func font(_ font: UIFont) -> Self {
        modifiableView.label.font = font
        return self
    }
    
    public func alignment(_ alignment: NSTextAlignment) -> Self {
        modifiableView.label.textAlignment = alignment
        return self
    }
    
    public func numberOfLines(_ lines: Int) -> Self {
        modifiableView.label.numberOfLines = lines
        return self
    }
}
