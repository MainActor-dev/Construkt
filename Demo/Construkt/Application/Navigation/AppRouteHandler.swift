import UIKit
import ConstruktKit

@available(iOS 15.0, *)
@MainActor
final class AppRouteHandler: ConstruktRouteHandler<AppRoute> {
    
    private let tabBarController: UITabBarController
    private let deepLinkMapper: DeepLinkMapper
    
    init(router: ConstruktRouter, tabBarController: UITabBarController, deepLinkMapper: DeepLinkMapper = .init()) {
        self.tabBarController = tabBarController
        self.deepLinkMapper = deepLinkMapper
        super.init(router: router)
    }
    
    func setupTabs() {
        // Setup Home Tab
        let homeNav = NavigationController()
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        let homeScreen = makeHomeViewController()
        homeNav.viewControllers = [homeScreen.toPresentable()]
        
        // Setup Explore Tab
        let exploreNav = NavigationController()
        exploreNav.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "text.magnifyingglass"))
        let exploreScreen = makeExploreViewController()
        exploreNav.viewControllers = [exploreScreen.toPresentable()]
        
        // Setup Profile Tab
        let profileNav = NavigationController()
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        let profileScreen = makeProfileViewController()
        profileNav.viewControllers = [profileScreen.toPresentable()]
        
        tabBarController.viewControllers = [homeNav, exploreNav, profileNav]
        
        // Styling TabBar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.tintColor = .white
        tabBarController.tabBar.unselectedItemTintColor = .gray
    }
    
    func switchToTab(_ tab: AppTab) {
        tabBarController.selectedIndex = tab.rawValue
    }
    
    // MARK: - Routing
    
    override func handle(_ route: AppRoute, sender: Any?) -> Bool {
        open(route, animated: true)
        return true
    }
    
    public func open(_ route: AppRoute, animated: Bool = true) {
        switch route {
        case .home:
            switchToTab(.home)
        case .explore, .search:
            switchToTab(.explore)
        case .movieDetail, .movieList, .web:
            if let selectedNav = activeNavigationController(for: tabBarController) {
                let proxyRouter = DefaultRouter(navigationController: selectedNav)
                let screen = makeScreen(for: route)
                
                if case .web = route {
                    proxyRouter.present(screen, style: .sheet(detents: [.medium, .large]), animated: animated, receiver: self)
                } else {
                    proxyRouter.push(screen, animated: animated, hideTabBar: true, completion: nil, receiver: self)
                }
            } else {
                switchToTab(.home)
            }
        }
    }
    
    public func handleDeepLink(_ url: URL) {
        guard let route = deepLinkMapper.route(from: url) else { return }
        open(route)
    }
    
    // MARK: - Helpers
    
    private func activeNavigationController(for viewController: UIViewController) -> UINavigationController? {
        if let nav = viewController as? UINavigationController {
            return nav
        }
        if let tab = viewController as? UITabBarController, let selected = tab.selectedViewController {
            return activeNavigationController(for: selected)
        }
        if let presented = viewController.presentedViewController {
            return activeNavigationController(for: presented)
        }
        return nil
    }
    
    // MARK: - Screen Factory Logic
    
    private func makeScreen(for route: AppRoute) -> ConstruktPresentable {
        switch route {
        case .home:
            return makeHomeViewController()
        case .explore:
            return makeExploreViewController()
        case .search:
            return SearchViewController()
        case .movieDetail(let movieId):
            guard let id = Int(movieId) else { return UIViewController() }
            let dummyMovie = Movie(id: id, title: "", overview: "", releaseDate: nil, posterPath: nil, backdropPath: nil, voteAverage: 0, genreIds: nil)
            return MovieDetailView(movie: dummyMovie)
                .onReceiveRoute(MovieDetailRoute.self, handler: { [unowned self] route in
                    switch route {
                    case .back:
                        if let selectedNav = activeNavigationController(for: tabBarController) {
                            selectedNav.popViewController(animated: true)
                        }
                        return true
                    case .similarMovie(let movie):
                        open(.movieDetail(movieId: String(movie.id)))
                        return true
                    }
                })
                .toPresentable()
            
        case .movieList(let title, let sectionTypeRaw, let genreId, let genreName, let allGenres):
            let sectionType = HomeSection(rawValue: sectionTypeRaw) ?? .categories
            var selectedGenre: Genre? = nil
            if let gId = genreId, let gName = genreName {
                selectedGenre = Genre(id: gId, name: gName)
            }
            
            let listViewModel = MovieListViewModel(
                title: title,
                sectionType: sectionType,
                genres: allGenres ?? (selectedGenre != nil ? [selectedGenre!] : []),
                selectedGenre: selectedGenre
            )
            return MovieListViewController(viewModel: listViewModel)
            
        case .web(let url):
            let vc = UIViewController()
            vc.title = url.absoluteString
            return vc
        }
    }
    
    
    private func makeHomeViewController() -> ConstruktPresentable {
        HomeView()
            .onReceiveRoute(HomeRoute.self)  { [unowned self] route in
                switch route {
                case .movieDetail(let movieId):
                    open(.movieDetail(movieId: movieId))
                case .movieList(let title, let sectionType, let genreId, let genreName, let allGenres):
                    open(.movieList(title: title, sectionTypeRaw: sectionType, genreId: genreId, genreName: genreName, allGenres: allGenres))
                case .search:
                    open(.search)
                }
                return true
            }
            .toPresentable()
    }
    
    private func makeExploreViewController() -> ConstruktPresentable {
        ExploreView()
            .onReceiveRoute(ExploreRoute.self) { [unowned self] route in
                switch route {
                case .movieDetail(let movieId):
                    open(.movieDetail(movieId: movieId))
                case .movieList(let title, let sectionType, let genreId, let genreName, let allGenres):
                    open(.movieList(title: title, sectionTypeRaw: sectionType, genreId: genreId, genreName: genreName, allGenres: allGenres))
                case .search:
                    open(.search)
                }
                return true
            }
            .toPresentable()
    }
    
    private func makeProfileViewController() -> ConstruktPresentable {
        return ProfileView().toPresentable()
    }
}
