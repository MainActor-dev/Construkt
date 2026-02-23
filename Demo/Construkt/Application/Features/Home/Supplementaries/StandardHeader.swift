import UIKit
import ConstruktKit

struct StandardHeader: ViewBuilder {
    let title: String
    let actionTitle: String?
    var onAction: (() -> Void)? = nil
    
    var body: View {
        HStackView() {
            LabelView(title)
                .font(.systemFont(ofSize: 18, weight: .semibold))
                .color(.white)
                .skeletonable(true)
            
            SpacerView()
            
            if let action = actionTitle {
                ButtonView(action) { _ in onAction?() }
                    .font(.systemFont(ofSize: 14))
                    .color(.lightGray)
                    .skeletonable(true)
            }
        }
        .alignment(.center)
    }
}

