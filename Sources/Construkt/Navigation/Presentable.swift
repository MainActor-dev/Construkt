//
//  ConstruktPresentable.swift
//  Construkt
//

import UIKit

/// A type-erased protocol indicating an object can be presented by UIKit.
public protocol ConstruktPresentable {
    func toPresentable() -> UIViewController
}

extension UIViewController: ConstruktPresentable {
    public func toPresentable() -> UIViewController { self }
}
