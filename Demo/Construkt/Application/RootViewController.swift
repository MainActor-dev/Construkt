import UIKit
import Factory
import RxSwift

final class RootViewController: UIViewController {
    
    @Injected(Container.userViewModel) var viewModel: UserViewModel
    
    // Tracks the current main view for transition(to:)
    var mainView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Construkt Users"
        view.backgroundColor = .systemBackground
        
        let stateView = StateView(viewModel.$state) { [weak self] state in
            guard let self = self else { return LabelView("Loading...") }
            switch state {
            case .initial:
                return LabelView("Initializing...")
                    .alignment(.center)
            case .loading:
                return LoadingView()
            case .loaded(let users):
                return UsersTableView(users: users) { [weak self] user in
                    let detailVC = UserDetailViewController(user: user)
                    self?.navigationController?.pushViewController(detailVC, animated: true)
                }
                .reference(&self.mainView)
            case .empty(let message):
                return EmptyView(message: message)
            case .error(let error):
                return ErrorView(message: error)
            }
        }
        .onAppearOnce { [weak self] _ in
             self?.viewModel.load()
        }
        
        view.embed(stateView)
    }
    
}

#if DEBUG
import SwiftUI

struct RootViewController_Preview: SwiftUI.UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> RootViewController {
        return RootViewController()
    }
    
    func updateUIViewController(_ uiViewController: RootViewController, context: Context) {}
}

struct RootViewController_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        RootViewController_Preview()
            .edgesIgnoringSafeArea(.all)
    }
}
#endif
