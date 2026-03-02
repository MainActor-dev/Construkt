//
//  UIColor+Extensions.swift
//  Builder
//
//  Created by Michael Long on 11/26/21.
//

import UIKit

extension UIColor {

    /// Returns a lighter variation of the current color by the specified percentage.
    public func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: abs(percentage))
    }

    /// Returns a darker variation of the current color by the specified percentage.
    public func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage))
    }

    private func adjust(by percentage: CGFloat = 30.0) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        }
        return self
    }
    
    // MARK: - Hex String Support
    
    /// Initializes a UIColor using a hex string representation (e.g. "#FF0000" or "FF0000").
    public convenience init(_ hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let r, g, b, a: CGFloat
        if hexString.count == 8 {
            r = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgbValue & 0x000000FF) / 255.0
        } else if hexString.count == 6 {
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        } else {
            // Fallback to light gray on invalid hex
            r = 0.8; g = 0.8; b = 0.8; a = 1.0
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }

    /// Converts the current UIColor object into an RGB or RGBA hex string.
    public func toHexString(includeAlpha: Bool = false) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return "000000" // Fallback
        }
        
        if includeAlpha {
            return String(format: "%02lX%02lX%02lX%02lX",
                          lroundf(Float(r) * 255.0),
                          lroundf(Float(g) * 255.0),
                          lroundf(Float(b) * 255.0),
                          lroundf(Float(a) * 255.0))
        } else {
            return String(format: "%02lX%02lX%02lX",
                          lroundf(Float(r) * 255.0),
                          lroundf(Float(g) * 255.0),
                          lroundf(Float(b) * 255.0))
        }
    }
}
