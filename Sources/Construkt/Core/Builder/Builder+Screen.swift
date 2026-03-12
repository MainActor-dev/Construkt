import UIKit

/// A high-level layout container that establishes a standard architecture for app screens.
/// It provides "slots" for content and common overlays like navigation bars.
public struct Screen: ViewBuilder {
    
    private let content: ViewConvertable
    private var navBar: ViewConvertable?
    private var bgColor: UIColor?
    private var bottomMargin: CGFloat = 0
    private var overlayContent: ViewConvertable?
    private var isContentUnderNavBar: Bool = true
    
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
    
    /// Adds additional content that sits outside the main content stack (e.g., floating buttons, overlays).
    public func overlay(@ViewResultBuilder _ overlay: () -> ViewConvertable) -> Screen {
        var copy = self
        copy.overlayContent = overlay()
        return copy
    }
    
    /// Determines whether the main content extends underneath the navigation bar or sits strictly below it.
    /// Default is `false` (content sits below the navigation bar).
    public func contentUnderNavBar(_ under: Bool = true) -> Screen {
        var copy = self
        copy.isContentUnderNavBar = under
        return copy
    }
    
    public var body: View {
        ZStackView {
            // Back layer: overlay content (behind everything)
            if let overlayContent = overlayContent {
                overlayContent
            }
            
            if !isContentUnderNavBar {
                // Content fills entire screen (stretches under navBar)
                content
                
                // Navbar floats on top
                if let navBar = navBar {
                    ContainerView { navBar }
                        .position(.top)
                }
            } else {
                // Front layer: navbar + content (content sits strictly below navBar)
                VStackView(spacing: 0) {
                    if let navBar = navBar {
                        navBar
                    }
                    ContainerView {
                        content
                    }
                    .contentHuggingPriority(.defaultLow, for: .vertical)
                    .contentCompressionResistancePriority(.defaultLow, for: .vertical)
                }
            }
        }
        .backgroundColor(bgColor)
    }
}
