//
//  Builder+Image.swift
//  ViewBuilder
//
//  Created by Michael Long on 10/29/19.
//  Copyright © 2019 Michael Long. All rights reserved.
//

import UIKit
import RxSwift

public struct ImageView: ModifiableView {
    
    public let modifiableView = Modified(UIImageView())

    // lifecycle
    public init(_ image: UIImage?) {
        modifiableView.image = image
    }

    public init(named name: String) {
        modifiableView.image = UIImage(named: name)
    }

    @available(iOS 13, *)
    public init(systemName name: String) {
        modifiableView.image = UIImage(systemName: name)
    }

    public init(url: URL?, placeholder: UIImage? = nil) {
        modifiableView.setImage(from: url, placeholder: placeholder)
    }

    public init(url: String?, placeholder: UIImage? = nil) {
        if let urlString = url, let url = URL(string: urlString) {
            modifiableView.setImage(from: url, placeholder: placeholder)
        } else {
            modifiableView.image = placeholder
        }
    }

    public init<Binding:RxBinding>(_ image: Binding) where Binding.T == UIImage {
        self.image(bind: image)
    }

    public init<Binding:RxBinding>(_ image: Binding) where Binding.T == UIImage? {
        self.image(bind: image)
    }
    
    // deprecated
    public init(configuration: (_ view: UIImageView) -> Void) {
        configuration(modifiableView)
    }

}


// Custom UIImageView modifiers

extension ModifiableView where Base: UIImageView {

    @discardableResult
    public func tintColor(_ color: UIColor?) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.tintColor, value: color)
    }

}

extension ModifiableView where Base: UIImageView {

    @discardableResult
    public func image<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == UIImage {
        ViewModifier(modifiableView, binding: binding) { $0.image = $1 }
    }

    @discardableResult
    public func image<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == UIImage? {
        ViewModifier(modifiableView, binding: binding) { $0.image = $1 }
    }

}
