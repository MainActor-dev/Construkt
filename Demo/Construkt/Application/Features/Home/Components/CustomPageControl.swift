import UIKit
import ConstruktKit

struct CustomPageControl<Binding: ViewBinding>: ViewConvertable where Binding.Value == Int {
    
    let count: Int
    let currentIndex: Binding
    
    func asViews() -> [View] {
        CenteredView {
            HStackView(spacing: 8) {
                (0..<count).map { index -> View in
                    DynamicContainerView(currentIndex) { current in
                        ContainerView() // empty container view to represent the dot
                            .backgroundColor(
                                current == index
                                ? UIColor.white
                                : UIColor.white.withAlphaComponent(0.5)
                            )
                            .width(current == index ? 24 : 8)
                            .height(8)
                            .cornerRadius(4)
                    }
                    .with { view in
                        view.layer.removeAllAnimations()
                        UIView.animate(withDuration: 0.3) {
                            view.layoutIfNeeded()
                        }
                    }
                }
            }
            .alignment(.center)
        }
        .asViews()
    }
}
