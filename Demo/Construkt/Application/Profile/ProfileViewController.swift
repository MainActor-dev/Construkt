import UIKit
import ConstruktKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("#0A0A0A")
        view.embed(body)
    }
    
    @objc private func didTapSettings() {
        print("Settings tapped")
    }
    
    // MARK: - Layout
    
    private var body: View {
        ZStackView {
            VerticalScrollView {
                VStackView {
                    ProfileHeroSection()
                    ProfilePremiumBanner()
                    ProfileGeneralSettingsSection()
                    ProfileAccountSettingsSection()
                    ProfileVersionInfo()
                }
                .spacing(24)
                .padding(top: 24, left: 24, bottom: 100, right: 24)
            }
            .with {
                $0.showsVerticalScrollIndicator = false
            }
            ProfileNavbar()
        }
    }
}
