import UIKit

struct HomeNavigationBar: ViewBuilder {
    let isLoading: AnyViewBinding<Bool>
    let onBackgroundReference: (UIView) -> Void
    
    var body: View {
        ZStackView {
            // Gradient Background
            GradientView(colors: [.black.withAlphaComponent(0.8), .black.withAlphaComponent(0.3)])
                .height(100)
                .alpha(0) // Start transparent
                .with { view in
                    onBackgroundReference(view)
                }
            
            // Navbar Content
            CustomNavigationBar(
                customTitle: LabelView("LUMIERE")
                    .font(.systemFont(ofSize: 24, weight: .bold))
                    .padding(insets: .init(top: 0, left: 4, bottom: 0, right: 0))
                    .color(bind: isLoading.map { isLoading in
                        return isLoading ? .gray : .white
                    }),
                trailing: [
                    ImageView(UIImage(systemName: "magnifyingglass"))
                        .tintColor(.white)
                        .size(width: 24, height: 24)
                        .contentMode(.scaleAspectFit),
                    ImageView(UIImage(systemName: "person.crop.circle.fill"))
                        .tintColor(.gray)
                        .size(width: 32, height: 32)
                        .cornerRadius(16)
                        .clipsToBounds(true)
                        .backgroundColor(UIColor(white: 1.0, alpha: 0.2))
                        .border(color: .white, lineWidth: 1)
                ]
            )
        }
        .position(.top) // Pin to top without filling screen
        .height(120) // Explicit height
    }
}
