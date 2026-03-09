//
//  Presentable.swift
//  Construkt
//

import UIKit

/// A type-erased protocol indicating an object can be presented by UIKit.
public protocol Presentable {
    func toPresentable() -> UIViewController
}

extension UIViewController: Presentable {
    public func toPresentable() -> UIViewController { self }
}
