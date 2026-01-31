import UIKit
import Factory
import RxSwift

final class RootViewController: UIViewController {
    
    @Injected(Container.userViewModel) var viewModel: UserViewModel
    
    // Tracks the current main view for transition(to:)
    var mainView: UIView?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Construkt Users"
        view.backgroundColor = .systemBackground
        
        setupSubscriptions()
    }
    
    func setupSubscriptions() {
        viewModel.$state
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .initial:
                    self.viewModel.load()
                    
                case .loading:
                    self.transition(to: LoadingView())
                    
                case .loaded(let users):
                    self.transition(to: UsersTableView(users: users).reference(&self.mainView))
                    
                case .empty(let message):
                    self.transition(to: EmptyView(message: message))
                    
                case .error(let error):
                    self.transition(to: ErrorView(message: error))
                }
            })
            .disposed(by: disposeBag)
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
