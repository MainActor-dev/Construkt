import UIKit
import ma_ios_common

@MainActor
enum AppTab: Int {
    case home = 0
    case explore = 1
    case profile = 2
}

@MainActor
final class AppCoordinator: BaseCoordinator {
    private let factory: ScreenFactoryProtocol
    private let tabBarController = UITabBarController()
    
    init(router: RouterProtocol, factory: ScreenFactoryProtocol) {
        self.factory = factory
        super.init(router: router)
    }
    
    func start() {
        let homeNav = NavigationController()
        let homeRouter = Router(navigationController: homeNav)
        let homeCoordinator = HomeCoordinator(router: homeRouter, factory: factory)
        addChild(homeCoordinator)
        
        // Setup Home Tab
        homeCoordinator.onSwitchToExplore = { [weak self] in
            self?.switchToTab(.explore)
        }
        homeCoordinator.start()
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        let exploreNav = NavigationController()
        let exploreRouter = Router(navigationController: exploreNav)
        let exploreCoordinator = ExploreCoordinator(router: exploreRouter, factory: factory)
        addChild(exploreCoordinator)
        
        // Setup Explore Tab
        exploreCoordinator.start()
        exploreNav.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "text.magnifyingglass"))
        
        let profileNav = NavigationController()
        let profileRouter = Router(navigationController: profileNav)
        let profileCoordinator = ProfileCoordinator(router: profileRouter, factory: factory)
        addChild(profileCoordinator)
        
        // Setup Profile Tab
        profileCoordinator.start()
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        
        tabBarController.viewControllers = [homeNav, exploreNav, profileNav]
        
        // Styling TabBar roughly (can refine later with custom subclass)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        tabBarController.tabBar.tintColor = .white
        tabBarController.tabBar.unselectedItemTintColor = .gray
    }
    
    func switchToTab(_ tab: AppTab) {
        tabBarController.selectedIndex = tab.rawValue
    }
    
    override func rootViewController() -> UIViewController {
        tabBarController
    }
}
