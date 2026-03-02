//
//  👨‍💻 Created by @thatswiftdev on 04/02/26.
//
//  © 2026, https://github.com/thatswiftdev. All rights reserved.
//

import UIKit

public class CollectionBackgroundReusableView: UICollectionReusableView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor(red: 28/255.0, green: 28/255.0, blue: 30/255.0, alpha: 1.0)
        layer.cornerRadius = 16
        clipsToBounds = true
    }
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let kind = layoutAttributes.representedElementKind ?? ""
        
        // Expected format: "background_HEXVALUE" where HEXVALUE is e.g., "FF0000" or "FF0000FF"
        if kind.hasPrefix("background_"), let underscoreIndex = kind.firstIndex(of: "_") {
            let hexValue = String(kind[kind.index(after: underscoreIndex)...])
            self.backgroundColor = UIColor(hexValue)
        } else {
            // Default Construkt dark theme fallback
            self.backgroundColor = UIColor(red: 28/255.0, green: 28/255.0, blue: 30/255.0, alpha: 1.0)
        }
    }
}
