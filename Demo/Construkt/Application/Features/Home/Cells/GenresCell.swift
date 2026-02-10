import UIKit

struct GenresCell: ViewBuilder {
    let id: Int
    let genre: Genre
    var isSelected: Bool = false
    
    var body: View {
        ZStackView {
            HStackView(spacing: 8) {
                LabelView(genre.name)
                    .font(.systemFont(ofSize: 14, weight: .medium))
                    .color(isSelected ? .black : .white)
                    .alignment(.center)
                    .padding(insets: .init(top: 8, left: 16, bottom: 8, right: 16))
            }
        }
        .backgroundColor(UIColor(white: 1.0, alpha: isSelected ? 1.0 : 0.1))
        .cornerRadius(20)
        .border(color: UIColor(white: 1.0, alpha: 0.2), lineWidth: 1)
        .skeletonable(true)
    }
}
