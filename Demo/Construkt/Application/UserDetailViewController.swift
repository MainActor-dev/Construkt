import UIKit
import RxSwift

final class UserDetailViewController: UIViewController {
    
    let user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.name
        view.backgroundColor = .systemBackground
        
        view.embed(
            VerticalScrollView {
                // Outer Container to fill ScrollView height if needed
                VStackView {
                    SpacerView()
                    
                    VStackView(spacing: 24) {
                        // Avatar / Header
                        VStackView(spacing: 8) {
                            CircleView(diameter: 80)
                                .backgroundColor(.systemGray5)
                            
                            LabelView(user.name)
                                .font(.boldSystemFont(ofSize: 24))
                                .alignment(.center)
                            
                            LabelView(user.email)
                                .font(.systemFont(ofSize: 16))
                                .color(.secondaryLabel)
                                .alignment(.center)
                        }
                        .alignment(.center)
                        
                        DividerView()
                        
                        // Details
                        VStackView(spacing: 16) {
                            DetailRow(label: "Website", value: user.website)
                        }
                        .alignment(.center) // Center the rows container
                    }
                    .padding(20)
                    .alignment(.center)
                    
                    SpacerView()
                }
                .alignment(.center)
            },
            safeArea: true
        )
    }
}

// Helper builder for rows
struct DetailRow: ViewBuilder {
    let label: String
    let value: String
    
    var body: View {
        HStackView(spacing: 12) {
            LabelView(label)
                .font(.systemFont(ofSize: 16, weight: .medium))
                .color(.secondaryLabel)
                .width(100)
            
            LabelView(value)
                .font(.systemFont(ofSize: 16))
                .numberOfLines(0) // dynamic height
        }
    }
}

struct CircleView: ModifiableView {
    let modifiableView = UIView()
    
    init(diameter: CGFloat) {
        modifiableView.translatesAutoresizingMaskIntoConstraints = false
        modifiableView.heightAnchor.constraint(equalToConstant: diameter).isActive = true
        modifiableView.widthAnchor.constraint(equalToConstant: diameter).isActive = true
        modifiableView.layer.cornerRadius = diameter / 2
        modifiableView.clipsToBounds = true
    }
}
