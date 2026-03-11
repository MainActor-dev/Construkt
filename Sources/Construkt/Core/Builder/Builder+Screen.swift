import UIKit

/// A high-level layout container that establishes a standard architecture for app screens.
/// It provides "slots" for content and common overlays like navigation bars.
public struct Screen: ViewBuilder {
    
    private let content: ViewConvertable
    private var navBar: ViewConvertable?
    private var bgColor: UIColor?
    private var bottomMargin: CGFloat = 0
    
    public init(@ViewResultBuilder content: () -> ViewConvertable) {
        self.content = content()
    }
    
    /// Adds a navigation bar overlay, pinned to the top.
    public func navigationBar(@ViewResultBuilder bar: () -> ViewConvertable) -> Screen {
        var copy = self
        copy.navBar = bar()
        return copy
    }
    
    /// Sets the background color for the entire screen.
    public func backgroundColor(_ color: UIColor?) -> Screen {
        var copy = self
        copy.bgColor = color
        return copy
    }
    
    /// Adds a margin to the bottom of the content area (e.g., for tab bars).
    public func contentMargins(bottom: CGFloat) -> Screen {
        var copy = self
        copy.bottomMargin = bottom
        return copy
    }
    
    public var body: View {
        ZStackView {
            content
            if let navBar = navBar {
                navBar
            }
        }
        .backgroundColor(bgColor)
    }
}
