import UIKit
import ConstruktKit

enum ProfileSection: String, SectionControllerIdentifier {
    case hero
    case premium
    case general
    case account
    case version
    
    var uniqueId: String { rawValue }
}

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("#0A0A0A")
        view.embed(body)
    }
    
    // MARK: - Layout
    
    var body: View {
        ZStackView {
            CollectionView {
                heroSection
                premiumSection
                generalSettingsSection
                accountSettingsSection
                versionSection
            }
            ProfileNavbar()
        }
    }
    
    // MARK: - Sections
    
    private var heroSection: Section {
        Section(id: ProfileSection.hero) {
            Cell("hero", id: "hero") { item in
                ProfileHeroSection()
            }
        }
        .layout {
            .list(itemHeight: .estimated(200))
            .insets(top: 80, leading: 24, bottom: 0, trailing: 24)
        }
    }
    
    private var premiumSection: Section {
        Section(id: ProfileSection.premium) {
            Cell("premium", id: "premium") { item in
                ProfilePremiumBanner()
            }
        }
        .layout {
            .list(itemHeight: .estimated(80))
            .insets(top: 24, leading: 24, bottom: 0, trailing: 24)
        }
    }
    
    private var generalSettingsSection: Section {
        Section(id: ProfileSection.general) {
            Cell("general", id: "general") { item in
                ProfileGeneralSettingsSection()
            }
        }
        .layout {
            .list(itemHeight: .estimated(200))
            .insets(top: 24, leading: 24, bottom: 0, trailing: 24)
        }
    }
    
    private var accountSettingsSection: Section {
        Section(id: ProfileSection.account) {
            Cell("account", id: "account") { item in
                ProfileAccountSettingsSection()
            }
        }
        .layout {
            .list(itemHeight: .estimated(200))
            .insets(top: 24, leading: 24, bottom: 0, trailing: 24)
        }
    }
    
    private var versionSection: Section {
        Section(id: ProfileSection.version) {
            Cell("version", id: "version") { item in
                ProfileVersionInfo()
            }
        }
        .layout {
            .list(itemHeight: .estimated(40))
            .insets(top: 24, leading: 24, bottom: 100, trailing: 24)
        }
    }
}
