import UIKit
import ConstruktKit

class LaunchViewController: UIViewController {
    
    var onFinished: (() -> Void)?
    
    private weak var titleLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0)
        view.embed(body)
        
        // Start hidden for animation
        titleLabel?.alpha = 0
        titleLabel?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLaunch()
    }
    
    // MARK: - Layout
    
    var body: View {
        ZStackView {
            LabelView("Construkt")
                .reference(&titleLabel)
                .font(.systemFont(ofSize: 36, weight: .bold))
                .color(.white)
                .alignment(.center)
        }
        .position(.center)
    }
    
    // MARK: - Animation
    
    private func animateLaunch() {
        UIView.animate(
            withDuration: 0.6,
            delay: 0.1,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.titleLabel?.alpha = 1.0
            self.titleLabel?.transform = .identity
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.onFinished?()
            }
        }
    }
}
