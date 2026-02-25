import UIKit
import ma_ios_common

@MainActor
public final class AppCoordinator: BaseCoordinator {
    private let window: UIWindow
    private let factory: ScreenFactoryProtocol
    private let tabBarController = UITabBarController()
    
    public init(window: UIWindow, router: RouterProtocol, factory: ScreenFactoryProtocol) {
        self.window = window
        self.factory = factory
        super.init(router: router)
    }
    
    public func start() {
        let homeNav = NavigationController()
        let homeRouter = Router(navigationController: homeNav)
        let homeCoordinator = HomeCoordinator(router: homeRouter, factory: factory)
        addChild(homeCoordinator)
        
        // Setup Home Tab
        homeCoordinator.start()
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        let exploreNav = NavigationController()
        let exploreRouter = Router(navigationController: exploreNav)
        let exploreCoordinator = ExploreCoordinator(router: exploreRouter, factory: factory)
        addChild(exploreCoordinator)
        
        // Setup Explore Tab
        exploreCoordinator.start()
        exploreNav.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "text.magnifyingglass"))
        
        tabBarController.viewControllers = [homeNav, exploreNav]
        
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
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
