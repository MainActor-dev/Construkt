
import UIKit

// Make it public so it can be seen from other modules if needed, though they are in the same app target.
struct CustomNavigationBar: ViewBuilder {
    
    // Configuration
    var title: String?
    var onBack: (() -> Void)?
    var tintColor: UIColor = .white
    
    // Custom Slots
    var leadingViews: [View] = []
    var customTitleView: View?
    var trailingViews: [View] = []
    
    // Standard: Simply Back + Title
    init(title: String? = nil, onBack: (() -> Void)? = nil, tintColor: UIColor = .white) {
        self.title = title
        self.onBack = onBack
        self.tintColor = tintColor
    }
    
    // Flexible: Custom Leading + Custom Title + Custom Trailing
    init(leading: [View] = [], customTitle: View? = nil, trailing: [View] = []) {
        self.leadingViews = leading
        self.customTitleView = customTitle
        self.trailingViews = trailing
        self.tintColor = .white
    }
    
    // Convenience: Home Pattern (Custom Title + Trailing)
    init(customTitle: View, trailing: [View] = []) {
        self.customTitleView = customTitle
        self.trailingViews = trailing
        self.tintColor = .white
    }

    var body: View {
        var views: [ViewConvertable] = []
        
        // Slot: Leading (Custom Back Button, etc)
        if !leadingViews.isEmpty {
            views.append(HStackView(leadingViews).spacing(8).alignment(.center))
        } else if let onBack {
             // Default Back Button
            let backIcon = HStackView {
                ImageView(UIImage(systemName: "chevron.left"))
                    .tintColor(tintColor)
                    .size(width: 24, height: 24)
                    .contentMode(.scaleAspectFit)
            }
            .onTapGesture { _ in onBack() }
            .padding(insets: .init(top: 8, left: 0, bottom: 8, right: 8))
            
            views.append(backIcon)
        }
        
        // Slot: Center (Title)
        // We need a clever way to center this if using flex layout.
        // The previous implementation used Spacer() to push trailing.
        
        // If we have a custom title view, we add it. 
        // If we want it perfectly centered, we might need a ZStack or a 3-column grid.
        // But Hstack with Spacers is the current approach.
        
        if let customTitleView {
            views.append(customTitleView)
        } else if let title {
            let label = LabelView(title)
                .font(.systemFont(ofSize: 17, weight: .semibold))
                .color(tintColor)
            views.append(label)
        }
        
        // Spring
        views.append(SpacerView())
        
        // Slot: Trailing
        if !trailingViews.isEmpty {
            views.append(HStackView(trailingViews).spacing(12).alignment(.center))
        }
        
        return HStackView(views)
            .alignment(.center)
            .padding(h: 16, v: 8) // Match previous padding
            .with {
                $0.backgroundColor = .clear
            }
    }
}
