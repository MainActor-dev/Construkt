import UIKit
import ConstruktKit

struct MovieDetailNavBar: ViewBuilder {
    
    let title: AnyViewBinding<String>
    let scrollOffset: AnyViewBinding<CGFloat>
    let onBack: (UIView) -> Void
    var onFavorite: (() -> Void)?
    var onShare: (() -> Void)?
    
    private enum Layout {
        static let fadeDistance: CGFloat = 100
        static let titleFadeStart: CGFloat = 300
        static let titleFadeEnd: CGFloat = 350
    }
    
    var body: View {
        ZStackView {
            GradientView(colors: [.black.withAlphaComponent(0.8), .black.withAlphaComponent(0.3)])
                .height(100)
                .alpha(0) // Start transparent
                .onReceive(scrollOffset) { context in
                    context.view.alpha = context.value.scrollProgress(over: Layout.fadeDistance)
                }
            
            CustomNavigationBar(
                leading: [
                    ButtonView()
                        .with { $0.setImage(UIImage(systemName: "arrow.left"), for: .normal) }
                        .tintColor(.white)
                        .backgroundColor(UIColor.black.withAlphaComponent(0.3), for: .normal)
                        .cornerRadius(20)
                        .size(width: 40, height: 40)
                        .onTap { context in onBack(context.view) },
                    LabelView(title)
                        .font(.systemFont(ofSize: 17, weight: .semibold))
                        .color(.white)
                        .alignment(.center)
                        .alpha(0)
                        .numberOfLines(1)
                        .contentCompressionResistancePriority(.defaultLow, for: .horizontal)
                        .onReceive(scrollOffset) { context in
                            context.view.alpha = (context.value - Layout.titleFadeStart)
                                .scrollProgress(over: Layout.titleFadeEnd - Layout.titleFadeStart)
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
