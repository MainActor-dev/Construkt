import UIKit

struct LoadingView: ViewBuilder {
    var body: View {
        CenteredView {
            VStackView(spacing: 16) {
                With(UIActivityIndicatorView(style: .large)) {
                    $0.startAnimating()
                    $0.color = .white
                }
                LabelView("Loading...")
                    .font(.systemFont(ofSize: 14))
                    .color(.white)
                    .alignment(.center)
            }
            .alignment(.center)
        }
        .backgroundColor(.systemBackground)
    }
}

struct ErrorView: ViewBuilder {
    let message: String
    
    var body: View {
        CenteredView {
            VStackView(spacing: 8) {
                LabelView("Something went wrong")
                    .font(.boldSystemFont(ofSize: 18))
                    .alignment(.center)
                LabelView(message)
                    .font(.systemFont(ofSize: 14))
                    .color(.secondaryLabel)
                    .numberOfLines(0)
                    .alignment(.center)
            }
            .padding(32)
            .alignment(.center)
        }
        .backgroundColor(.systemBackground)
    }
}

struct EmptyView: ViewBuilder {
    let title: String
    let subtitle: String
    let buttonTitle: String
    var onAction: (() -> Void)? = nil
    
    var body: View {
        VStackView {
            ImageView(systemName: "square.dashed")
                .tintColor(.gray)
                .contentMode(.scaleAspectFit)
                .width(64)
                .height(64)
            LabelView(title)
                .font(.systemFont(ofSize: 20, weight: .bold))
                .color(.lightGray)
                .alignment(.center)
            LabelView(subtitle)
                .font(.systemFont(ofSize: 14))
                .color(.gray)
                .alignment(.center)
            SpacerView(h: 12)
            ButtonView(buttonTitle) { _ in onAction?() }
                .font(.systemFont(ofSize: 15, weight: .bold))
                .color(.black)
                .backgroundColor(.white)
                .cornerRadius(12)
                .height(40)
                .width(128)
        }
        .spacing(12)
        .alignment(.center)
    }
}

// Utility View for centering content
struct CenteredView: ModifiableView {
    let modifiableView = Modified(UIView())
    
    init(@ViewResultBuilder _ builder: () -> [View]) {
        let views = builder()
        let content: View
        if views.count == 1 {
            content = views[0]
        } else {
            content = VStackView { views }
        }
        modifiableView.addConstrainedSubview(content(), position: .center, padding: .zero)
    }
}
