import UIKit

struct FilterCell: ViewBuilder {
    let title: String
    let isSelected: Bool
    
    var body: View {
        ContainerView {
            LabelView(title)
                .font(.systemFont(ofSize: 14, weight: .medium))
                .color(isSelected ? .black : .white)
                .alignment(.center)
        }
        .backgroundColor(isSelected ? .white : UIColor(white: 1, alpha: 0.1))
        .cornerRadius(16)
        .border(color: UIColor(white: 1, alpha: 0.2), lineWidth: 1)
        .padding(top: 8, left: 16, bottom: 8, right: 16)
    }
}
