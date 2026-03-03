//
//  👨‍💻 Created by @thatswiftdev on 26/09/25.
//
//  © 2025, https://github.com/thatswiftdev. All rights reserved.
//

import UIKit

/// A compositional layout decoration view that dynamically hosts a `ViewConvertable`
/// UIKit hierarchy requested from the `DecorationRegistry`.
public class CustomBackgroundReusableView: UICollectionReusableView {
    
    private var hostedView: UIView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let kind = layoutAttributes.representedElementKind else { return }
        
        // Ensure lazy instantiation of the hierarchy once per reusable instance
        if hostedView == nil {
            // Dynamic Traversal: Extract the provider natively from the underlying Section model
            var responder: UIResponder? = self
            while responder != nil {
                if let wrapper = responder as? CollectionViewWrapperView {
                    if let sectionController = wrapper.sectionController(for: layoutAttributes.indexPath.section),
                       let provider = sectionController.decorationProviders[kind] {
                        
                        let view = provider().asViews().first?.build() ?? UIView()
                        host(view)
                    }
                    break
                }
                responder = responder?.next
            }
        }
    }
    
    private func host(_ view: UIView) {
        hostedView?.removeFromSuperview()
        hostedView = view
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        // Decorations can dynamically change contents occasionally, 
        // though typically backgrounds are static for the section.
        // We retain the hostedview to avoid constant rebuilding unless elementKind changes entirely.
    }
}
