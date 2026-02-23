import UIKit
import ConstruktKit

struct MovieDetailNavBar: ViewBuilder {
    
    let title: String
    let onBack: () -> Void
    var onFavorite: (() -> Void)?
    var onShare: (() -> Void)?
    
    var backgroundViewCapture: ((UIView) -> Void)?
    var titleLabelCapture: ((UIView) -> Void)?
    
    var body: View {
        ZStackView {
            GradientView(colors: [.black.withAlphaComponent(0.8), .black.withAlphaComponent(0.3)])
                .height(100)
                .alpha(0) // Start transparent
                .with { view in
                    backgroundViewCapture?(view)
                }
            
            CustomNavigationBar(
                leading: [
                    ButtonView()
                        .with { $0.setImage(UIImage(systemName: "arrow.left"), for: .normal) }
                        .tintColor(.white)
                        .backgroundColor(UIColor.black.withAlphaComponent(0.3), for: .normal)
                        .cornerRadius(20)
                        .size(width: 40, height: 40)
                        .onTap { _ in onBack() },
                    LabelView(title)
                        .font(.systemFont(ofSize: 17, weight: .semibold))
                        .color(.white)
                        .alignment(.center)
                        .alpha(0)
                        .with { view in
                            titleLabelCapture?(view)
                        }
                ],
                trailing: [
                    ButtonView()
                        .with { $0.setImage(UIImage(systemName: "heart"), for: .normal) }
                        .tintColor(.white)
                        .backgroundColor(UIColor.black.withAlphaComponent(0.3), for: .normal)
                        .cornerRadius(20)
                        .size(width: 40, height: 40)
                        .onTap { _ in onFavorite?() },
                    
                    ButtonView()
                        .with { $0.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal) }
                        .tintColor(.white)
                        .backgroundColor(UIColor.black.withAlphaComponent(0.3), for: .normal)
                        .cornerRadius(20)
                        .size(width: 40, height: 40)
                        .onTap { _ in onShare?() }
                ]
            )
        }
        .position(.top)
        .height(48)
    }
}
