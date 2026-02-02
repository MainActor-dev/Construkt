import UIKit
import Construkt

struct LoadingView: ViewBuilder {
    var body: View {
        CenteredView {
            VStackView(spacing: 16) {
                With(UIActivityIndicatorView(style: .large)) {
                    $0.startAnimating()
                    $0.color = .gray
                }
                LabelView("Loading...")
                    .font(.systemFont(ofSize: 14))
                    .color(.secondaryLabel)
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
    let message: String
    
    var body: View {
        CenteredView {
            LabelView(message)
                .font(.systemFont(ofSize: 16))
                .color(.secondaryLabel)
                .alignment(.center)
        }
        .backgroundColor(.systemBackground)
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
