import UIKit
import RxSwift

struct UsersTableView: ViewBuilder {
    let users: [User]
    
    var body: View {
        TableView(DynamicItemViewBuilder(users) { user in
            TableViewCell(title: user.name, subtitle: user.email)
                .accessoryType(.disclosureIndicator)
                .onSelect { context in
                    // Demo action
                    print("Selected \(user.name)")
                    return false
                }
        })
        .separatorStyle(.singleLine)
        .perform { view in
             // In a cleaner implementation, we would bind the data source directly.
             // Here we can access the underlying TableView and force an update if needed.
             // But primarily, the StateContainer will call `update(with:)` on this view.
             
             // However, `TableView` creates `BuilderInternalTableView`.
             // We need to ensure that when `StateContainer` calls `activeView.update(with: state)`,
             // it reaches the `BuilderInternalTableView`.
             // `View` is a closure returning `UIView`.
             // So `activeView` IS `BuilderInternalTableView`.
             
             if let tableView = view as? BuilderInternalTableView {
                 // For true "Smart Update", we should update the builder's items here.
                 // This requires `BuilderInternalTableView` to expose a data updating method.
                 // For now, the `update` method on `BuilderInternalTableView` does a reload.
                 // We need to pass the new users to it.
                 // Ideally, `DynamicItemViewBuilder` should be replaceable.
                 
                 // Protocol Hack for PoC:
                 // We need to inject the new `users` list into the existing `tableView.builder`.
                 if var builder = tableView.builder as? DynamicItemViewBuilder<User> {
                      builder.items = users
                      tableView.set(builder) // Re-set builder triggers reload
                 }
             }
        }
    }
}

struct LoadingView: ViewBuilder {
    var body: View {
        CenteredView {
            VStackView(spacing: 16) {
                With(UIActivityIndicatorView(style: .large)) {
                    $0.startAnimating()
                    $0.color = .gray
                }
                LabelView("Loading Users...")
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
