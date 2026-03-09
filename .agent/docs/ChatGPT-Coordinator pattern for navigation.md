# Coordinator pattern for navigation

**User:** Bayu Kurniawan (sikubaycom@gmail.com)  
**Created:** 11/9/2025 20:20:29  
**Updated:** 11/13/2025 6:17:43  
**Exported:** 11/13/2025 6:20:32  
**Link:** [https://chatgpt.com/g/g-p-690367128ba48191857e302f8eca16cb/c/69109519-f348-8322-ab08-ad0e1d0fbddc](https://chatgpt.com/g/g-p-690367128ba48191857e302f8eca16cb/c/69109519-f348-8322-ab08-ad0e1d0fbddc)  

## Prompt:
Create an advanced Coordinator pattern (but not over-engineered) for navigation that works with both UIKit and SwiftUI applications. And it has everything to offer from such pattern.

## Response:
Request for GPT-5 Pro

Reasoned for 5m 40s

Below is a **compact but fully‑featured Coordinator** you can drop into new or existing projects. It:

*   works in **UIKit-only**, **SwiftUI-only**, or **hybrid** apps
*   supports **typed routes**, **deep links**, **child flows**, **modals/sheets**, **tabs**, **state restoration**, **dependency injection**, and **async/await flow results**
*   lets you push either **UIViewController** _or_ **SwiftUI View** without caring which one you have

> Target: iOS 15+. Swift 5.9+.  
> Copy the files as shown (names are just suggestions). Everything below compiles together.

* * *

1) Presentable — unify UIKit & SwiftUI
--------------------------------------

**Presentable.swift**

```swift
import UIKit
import SwiftUI

/// A type-erased thing that can be presented by UIKit.
public protocol Presentable {
    func toPresentable() -> UIViewController
}

extension UIViewController: Presentable {
    public func toPresentable() -> UIViewController { self }
}

/// Wrap any SwiftUI View as a Presentable.
public struct HostingPresentable<Content: View>: Presentable {
    private let view: Content
    private let title: String?

    public init(_ view: Content, title: String? = nil) {
        self.view = view
        self.title = title
    }

    public func toPresentable() -> UIViewController {
        let vc = UIHostingController(rootView: view)
        vc.title = title
        return vc
    }
}

public extension View {
    /// Turns a SwiftUI View into a Presentable you can push or present.
    func asPresentable(title: String? = nil) -> Presentable {
        HostingPresentable(self, title: title)
    }
}
```

* * *

2) Router — navigation primitives (push / present / sheets)
-----------------------------------------------------------

**Router.swift**

```swift
import UIKit

public enum ModalStyle {
    case sheet(detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
               prefersGrabberVisible: Bool = true)
    case fullScreen
    case formSheet
    case custom((UIViewController) -> Void) // configure presentation yourself
}

public protocol Router: AnyObject {
    var navigationController: UINavigationController { get }
    func setRoot(_ module: Presentable, hideBar: Bool, animated: Bool)
    func push(_ module: Presentable, animated: Bool, completion: (() -> Void)?)
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
    func present(_ module: Presentable, style: ModalStyle, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

public final class DefaultRouter: NSObject, Router, UINavigationControllerDelegate {
    public let navigationController: UINavigationController
    private var completions: [UIViewController: () -> Void] = [:]

    public init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }

    public func setRoot(_ module: Presentable, hideBar: Bool = false, animated: Bool = true) {
        let vc = module.toPresentable()
        navigationController.setViewControllers([vc], animated: animated)
        navigationController.isNavigationBarHidden = hideBar
    }

    public func push(_ module: Presentable, animated: Bool = true, completion: (() -> Void)? = nil) {
        let vc = module.toPresentable()
        if let completion { completions[vc] = completion }
        navigationController.pushViewController(vc, animated: animated)
    }

    public func pop(animated: Bool = true) {
        if let vc = navigationController.popViewController(animated: animated) {
            runCompletion(for: vc)
        }
    }

    public func popToRoot(animated: Bool = true) {
        let popped = navigationController.popToRootViewController(animated: animated) ?? []
        popped.forEach(runCompletion(for:))
    }

    public func present(_ module: Presentable,
                        style: ModalStyle = .sheet(),
                        animated: Bool = true,
                        completion: (() -> Void)? = nil) {
        let vc = module.toPresentable()
        switch style {
        case let .sheet(detents, grabber):
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.detents = detents
                sheet.prefersGrabberVisible = grabber
            }
        case .fullScreen:
            vc.modalPresentationStyle = .fullScreen
        case .formSheet:
            vc.modalPresentationStyle = .formSheet
        case .custom(let configure):
            configure(vc)
        }
        topMostViewController().present(vc, animated: animated, completion: completion)
    }

    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        topMostViewController().dismiss(animated: animated, completion: completion)
    }

    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController, animated: Bool) {
        guard let fromVC = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(fromVC) else { return }
        runCompletion(for: fromVC)
    }

    private func runCompletion(for vc: UIViewController) {
        completions.removeValue(forKey: vc)?()
    }

    private func topMostViewController(base: UIViewController? = nil) -> UIViewController {
        let base = base ?? navigationController
        if let presented = base.presentedViewController { return topMostViewController(base: presented) }
        if let nav = base as? UINavigationController { return nav.visibleViewController.map { topMostViewController(base: $0) } ?? nav }
        if let tab = base as? UITabBarController { return tab.selectedViewController.map { topMostViewController(base: $0) } ?? tab }
        return base
    }
}
```

* * *

3) Coordinator core + results (async)
-------------------------------------

**Coordinator.swift**

```swift
import Foundation

public protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    func start()
}

public extension Coordinator {
    func store(_ child: Coordinator) { children.append(child) }
    func free(_ child: Coordinator) { children.removeAll { $0 === child } }
}

/// When you want a flow to return a result (e.g. Auth -> .signedIn user)
@MainActor
public protocol FlowCoordinator: Coordinator {
    associatedtype Result
    func start() async -> Result
}
```

* * *

4) Routes you can encode, restore, and deep‑link
------------------------------------------------

**AppRoute.swift**

```swift
import Foundation

/// Typed navigation you can codably serialize for state restoration / deep links.
public enum AppRoute: Hashable, Codable {
    case onboarding
    case home
    case product(id: UUID)
    case settings
    case web(url: URL) // example: deep link to external content
}

/// Convert URLs to routes and back. Extend as needed.
public struct DeepLinkMapper {
    public init() {}

    public func route(from url: URL) -> AppRoute? {
        // myapp://product/<uuid>
        if url.host == "product", let id = UUID(uuidString: url.lastPathComponent) {
            return .product(id: id)
        }
        // myapp://settings
        if url.host == "settings" { return .settings }
        return nil
    }

    public func url(from route: AppRoute) -> URL? {
        switch route {
        case .product(let id): return URL(string: "myapp://product/\(id.uuidString)")
        case .settings: return URL(string: "myapp://settings")
        default: return nil
        }
    }
}
```

* * *

5) Screen factory (DI-friendly)
-------------------------------

Keep view construction in one place so coordinators stay thin.

**ScreenFactory.swift**

```swift
import UIKit
import SwiftUI
import SafariServices

public protocol ScreenFactory {
    func screen(for route: AppRoute) -> Presentable
}

public final class DefaultScreenFactory: ScreenFactory {
    public init() {}

    public func screen(for route: AppRoute) -> Presentable {
        switch route {
        case .onboarding:
            return OnboardingView().asPresentable(title: "Welcome")

        case .home:
            return HomeView().asPresentable(title: "Home")

        case let .product(id):
            return ProductView(productID: id).asPresentable(title: "Product")

        case .settings:
            return SettingsViewController() // UIKit example

        case let .web(url):
            return SFSafariViewController(url: url)
        }
    }
}
```

Example stub screens to make it compile:

**ExampleScreens.swift**

```swift
import SwiftUI
import UIKit

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Onboarding").font(.largeTitle)
            Text("Explain your value prop here.")
        }.padding()
    }
}

struct HomeView: View {
    var body: some View {
        List {
            Text("Home")
            Text("Tap a product from coordinator in real app…")
        }
    }
}

struct ProductView: View {
    let productID: UUID
    var body: some View {
        VStack(spacing: 12) {
            Text("Product")
            Text(productID.uuidString).font(.footnote.monospaced())
        }.padding()
    }
}

/// UIKit example
final class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Settings"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
```

* * *

6) AppCoordinator (root), with deep links + restoration
-------------------------------------------------------

**AppCoordinator.swift**

```swift
import UIKit

@MainActor
public final class AppCoordinator: Coordinator {
    public var children: [Coordinator] = []
    private let router: Router
    private let screens: ScreenFactory
    private let deepLinkMapper: DeepLinkMapper

    /// Keep a serializable path for restoration.
    private(set) var currentPath: [AppRoute] = []

    public init(router: Router, screens: ScreenFactory, deepLinkMapper: DeepLinkMapper = .init()) {
        self.router = router
        self.screens = screens
        self.deepLinkMapper = deepLinkMapper
    }

    public func start() {
        // Decide initial stack (e.g., isLoggedIn ? .home : .onboarding)
        setRoot(.home)
    }

    // MARK: Public navigation API

    public func open(_ route: AppRoute, animated: Bool = true) {
        currentPath.append(route)
        router.push(screens.screen(for: route), animated: animated, completion: nil)
    }

    public func present(_ route: AppRoute, as style: ModalStyle = .sheet(), animated: Bool = true) {
        router.present(screens.screen(for: route), style: style, animated: animated, completion: nil)
    }

    public func handleDeepLink(_ url: URL) {
        guard let route = deepLinkMapper.route(from: url) else { return }
        navigate(to: route)
    }

    public func navigate(to route: AppRoute) {
        // You can get smarter here: decide push vs present per route
        switch route {
        case .settings:
            present(route, as: .formSheet)
        default:
            open(route)
        }
    }

    // MARK: Restoration

    public func saveRestorationData() -> Data? {
        try? JSONEncoder().encode(currentPath)
    }

    public func restore(from data: Data) {
        guard let saved = try? JSONDecoder().decode([AppRoute].self, from: data) else { return }
        setRoot(saved.first ?? .home)
        for route in saved.dropFirst() { open(route, animated: false) }
    }

    // MARK: Internals

    private func setRoot(_ route: AppRoute, hideBar: Bool = false) {
        currentPath = [route]
        router.setRoot(screens.screen(for: route), hideBar: hideBar, animated: false)
    }
}
```

* * *

7) Child flow example that returns a result (Auth)
--------------------------------------------------

**AuthCoordinator.swift**

```swift
import Foundation
import SwiftUI

enum AuthResult { case signedIn(userID: String), cancelled }

@MainActor
final class AuthCoordinator: FlowCoordinator {
    var children: [Coordinator] = []

    private let router: Router
    private let screens: ScreenFactory

    init(router: Router, screens: ScreenFactory) {
        self.router = router
        self.screens = screens
    }

    func start() { /* not used for result-based flows */ }

    func start() async -> AuthResult {
        // Show a simple SwiftUI sign-in screen
        let view = SignInView()
        router.present(view.asPresentable(title: "Sign In"), style: .sheet(), animated: true, completion: nil)

        // Wait asynchronously for user action (in a real app, inject a SignInService)
        let userID = await SignInViewModel.shared.waitForSignIn()
        router.dismiss(animated: true, completion: nil)
        return userID.map { .signedIn(userID: $0) } ?? .cancelled
    }
}

// MARK: Toy Sign-in primitives to compile

@MainActor
final class SignInViewModel: ObservableObject {
    static let shared = SignInViewModel()
    private var continuation: CheckedContinuation<String?, Never>?

    func signalSignedIn(userID: String) { continuation?.resume(returning: userID) }
    func signalCancelled() { continuation?.resume(returning: nil) }

    func waitForSignIn() async -> String? {
        await withCheckedContinuation { (c: CheckedContinuation<String?, Never>) in
            self.continuation = c
        }
    }
}

struct SignInView: View {
    @ObservedObject var model = SignInViewModel.shared
    var body: some View {
        VStack(spacing: 12) {
            Text("Please sign in").font(.title2)
            Button("Continue as Demo User") { model.signalSignedIn(userID: "demo") }
            Button("Cancel") { model.signalCancelled() }
        }.padding()
    }
}
```

* * *

8) Tabs (optional but often needed)
-----------------------------------

**TabBarCoordinator.swift**

```swift
import UIKit

@MainActor
final class TabBarCoordinator: Coordinator {
    var children: [Coordinator] = []
    private let screens: ScreenFactory
    private let tabBarController = UITabBarController()

    init(screens: ScreenFactory) { self.screens = screens }

    func start() {
        let homeNav = UINavigationController()
        let settingsNav = UINavigationController()

        let homeRouter = DefaultRouter(navigationController: homeNav)
        let settingsRouter = DefaultRouter(navigationController: settingsNav)

        let home = SimpleStackCoordinator(router: homeRouter, screens: screens, root: .home, title: "Home", systemImage: "house")
        let settings = SimpleStackCoordinator(router: settingsRouter, screens: screens, root: .settings, title: "Settings", systemImage: "gear")

        store(home); store(settings)
        home.start(); settings.start()

        tabBarController.viewControllers = [homeNav, settingsNav]
    }

    func rootController() -> UIViewController { tabBarController }
}

/// Minimal stack coordinator used by tabs
@MainActor
final class SimpleStackCoordinator: Coordinator {
    var children: [Coordinator] = []
    private let router: Router
    private let screens: ScreenFactory
    private let rootRoute: AppRoute
    private let title: String
    private let systemImage: String

    init(router: Router, screens: ScreenFactory, root: AppRoute, title: String, systemImage: String) {
        self.router = router; self.screens = screens; self.rootRoute = root
        self.title = title; self.systemImage = systemImage
    }

    func start() {
        let vc = screens.screen(for: rootRoute).toPresentable()
        vc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: systemImage), selectedImage: nil)
        router.setRoot(vc, hideBar: false, animated: false)
    }
}
```

* * *

9) SwiftUI integration: embed the Router’s UINavigationController
-----------------------------------------------------------------

Use this to drive navigation from SwiftUI while still enjoying the Coordinator.

**NavigationControllerView.swift**

```swift
import SwiftUI
import UIKit

/// Bridge: show any UINavigationController inside SwiftUI.
public struct NavigationControllerView: UIViewControllerRepresentable {
    public let navigationController: UINavigationController

    public init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        navigationController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
```

**SwiftUIAppBootstrap.swift**

```swift
import SwiftUI

@MainActor
final class AppBootstrap: ObservableObject {
    let router = DefaultRouter()
    let screens = DefaultScreenFactory()
    lazy var app = AppCoordinator(router: router, screens: screens)

    func start() { app.start() }
}

struct RootContainerView: View {
    @StateObject private var bootstrap = AppBootstrap()
    var body: some View {
        NavigationControllerView(bootstrap.router.navigationController)
            .onAppear { bootstrap.start() }
    }
}
```

Use `RootContainerView()` as your `WindowGroup` content in a SwiftUI app.

* * *

10) UIKit AppDelegate / SceneDelegate setup
-------------------------------------------

If you’re UIKit-first:

```swift
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let nav = UINavigationController()
        let router = DefaultRouter(navigationController: nav)
        let screens = DefaultScreenFactory()
        coordinator = AppCoordinator(router: router, screens: screens)
        coordinator.start()

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window

        // Deep link on cold start
        if let url = connectionOptions.urlContexts.first?.url {
            coordinator.handleDeepLink(url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        coordinator.handleDeepLink(url)
    }
}
```

* * *

What this gives you (and how to extend)
---------------------------------------

*   **Typed routes** (`AppRoute`) you can safely construct, encode, and restore.
*   **Single `Presentable`** abstraction that **pushes SwiftUI or UIKit** screens seamlessly.
*   **Router** with push/pop, modal sheets, full screen, form sheet, completions on pop.
*   **AppCoordinator** that owns the stack, handles **deep links**, and **state restoration**.
*   **Child flows with async results** (see `AuthCoordinator`).
*   **Tabs** with independent stacks (`TabBarCoordinator`).
*   **SwiftUI bridge** (`NavigationControllerView`) so SwiftUI apps can still use the same coordinators.
*   **DI-friendly `ScreenFactory`** so you can inject services and keep coordinators thin.

* * *

Common customizations
---------------------

*   **Decide push vs present per route** in `AppCoordinator.navigate(to:)`.
*   **Inject services** (networking, analytics) through `DefaultScreenFactory` constructor.
*   **Protect routes behind auth**: if not signed in, `await AuthCoordinator.start()` then continue.
*   **Global styling**: configure `UINavigationBarAppearance` where you create the `DefaultRouter`.
*   **Programmatic restoration**: persist `app.saveRestorationData()` in `sceneDidEnterBackground`, then call `restore(from:)` on next launch.

* * *

Minimal usage snippets
----------------------

**Push a product from anywhere (e.g., after a list tap):**

```swift
appCoordinator.open(.product(id: product.id))
```

**Present settings as a form sheet:**

```swift
appCoordinator.present(.settings, as: .formSheet)
```

**Handle a deep link URL:**

```swift
func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    appCoordinator.handleDeepLink(url)
    return true
}
```

* * *

This is “advanced” — deep links, results, tabs, restoration, DI — but **not over‑engineered**: one small abstraction (`Presentable`), one router implementation, lean coordinators, and typed routes. Add screens and services as your app grows; the navigation surface stays stable.

## Prompt:
What is the example use case of "restoration"

## Response:
Thought for 20s

Great question. In this coordinator, **restoration** means “bring the user back to exactly where they were—navigation-wise—after the app is killed or relaunched,” without asking them to redo the journey.

Here are concrete, real-world uses:

*   **Interrupted checkout:** User is on `Home → Product(id: A) → Cart → Checkout`. iOS kills your app in the background. On next launch, you restore that exact stack so they land **back at Checkout** and can finish paying.
*   **Deep drill inside a tab:** In a tabbed app, the user is on the **Search** tab, 4 levels deep with a filter applied. After relaunch, you restore **selected tab + the full push stack** so they don’t have to navigate again.
*   **Long forms/wizards:** Multi-step KYC or onboarding (step 5 of 7). After an update or crash, you restore directly to step 5 (and ideally the partially entered data).
*   **Context handoff:** User taps a push notification to a specific product, pokes around, gets interrupted; later they open the app icon and you restore to the **same product detail** rather than home.

### How it ties to the sample code

The example coordinator already exposes:

```swift
// AppCoordinator
public func saveRestorationData() -> Data?    // encodes [AppRoute]
public func restore(from data: Data)          // rebuilds the stack
```

You simply persist the encoded path when the app backgrounds, and rebuild it on next launch.

#### UIKit bootstrap (SceneDelegate)

```swift
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let nav = UINavigationController()
        let router = DefaultRouter(navigationController: nav)
        let screens = DefaultScreenFactory()
        coordinator = AppCoordinator(router: router, screens: screens)

        // Try to restore first; fall back to a fresh start.
        if let data = UserDefaults.standard.data(forKey: "navPath") {
            coordinator.restore(from: data)
        } else {
            coordinator.start()
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        if let data = coordinator.saveRestorationData() {
            UserDefaults.standard.set(data, forKey: "navPath")
        }
    }
}
```

#### SwiftUI bootstrap

```swift
@MainActor
final class AppBootstrap: ObservableObject {
    let router = DefaultRouter()
    let screens = DefaultScreenFactory()
    lazy var app = AppCoordinator(router: router, screens: screens)

    func start() {
        if let data = UserDefaults.standard.data(forKey: "navPath") {
            app.restore(from: data)
        } else {
            app.start()
        }
    }

    func persist() {
        if let data = app.saveRestorationData() {
            UserDefaults.standard.set(data, forKey: "navPath")
        }
    }
}

// e.g., in ScenePhase handling:
@Environment(\.scenePhase) private var phase
.onChange(of: phase) { newPhase in
    if newPhase == .background { bootstrap.persist() }
}
```

### Tips & gotchas

*   **When to clear:** On logout, delete the saved path so you don’t restore a protected screen for the next user.
*   **Versioning:** If your `AppRoute` evolves, keep a `version` field next to the saved data and handle migrations/fallbacks.
*   **Beyond navigation:** This restores the **route stack**. If you also need scroll position, filters, or form inputs, persist those alongside (e.g., as associated values inside routes or in your view models).

In short: restoration makes your app feel resilient and respectful of the user’s time—especially in flows that are multi-step, deep, or easily interrupted.

## Prompt:
How ScreenFactory will be used further?

## Response:
Thought for 13s

Great question. Think of `ScreenFactory` as the **single place where “a route becomes a screen.”** It keeps coordinators thin, centralizes dependency wiring, and makes testing easy. Here’s how you’ll use it going forward—with focused examples.

* * *

What you do with `ScreenFactory`
================================

1.  **Inject dependencies (DI) & build view models**
    *   Keep services out of coordinators.
*   Choose UIKit vs SwiftUI at build time, but the coordinator still pushes a `Presentable`.

```swift
public struct AppDependencies {
    let api: ProductsAPI
    let auth: AuthService
    let db: LocalStore
    let analytics: Analytics
}

public final class DefaultScreenFactory: ScreenFactory {
    private let deps: AppDependencies
    public init(deps: AppDependencies) { self.deps = deps }

    public func screen(for route: AppRoute) -> Presentable {
        switch route {
        case .home:
            let vm = HomeViewModel(api: deps.api, analytics: deps.analytics)
            return HomeView(viewModel: vm).asPresentable(title: "Home")

        case let .product(id):
            let vm = ProductViewModel(id: id, api: deps.api, db: deps.db)
            // Swap UIKit/SwiftUI freely:
            #if USE_UIKIT
            return ProductViewController(viewModel: vm)
            #else
            return ProductView(viewModel: vm).asPresentable(title: "Product")
            #endif

        case .settings:
            let vc = SettingsViewController(auth: deps.auth, analytics: deps.analytics)
            return vc

        case let .web(url):
            return WebWrapper(url: url) // e.g. SFSafariViewController
        default:
            return OnboardingView().asPresentable(title: "Welcome")
        }
    }
}
```

2.  **Gate routes (auth, paywall, feature flags)**
    *   Decide _here_ whether to send the user to the real screen or a fallback.

```swift
case .settings:
    if !deps.auth.isLoggedIn {
        return SignInView().asPresentable(title: "Sign In")
    }
    return SettingsViewController(auth: deps.auth)
```

3.  **Apply consistent theming & environment**
    *   Inject SwiftUI `.environment` or UIKit appearance without polluting coordinators.

```swift
case .home:
    let vm = HomeViewModel(api: deps.api, analytics: deps.analytics)
    return HomeView(viewModel: vm)
        .environmentObject(AppTheme.shared)    // SwiftUI
        .asPresentable(title: "Home")
```

4.  **Provide screen-level callbacks to the Coordinator**
    *   Pass closures that call back into the coordinator without the screen knowing it.

```swift
case let .product(id):
    let vm = ProductViewModel(id: id, api: deps.api, db: deps.db)
    vm.onShowReviews = { [weak deps] productID in
        deps?.analytics.track("open_reviews")
        // Ask the app coordinator to navigate; inject a light router if needed.
        deps?.router?.open(.web(url: URL(string:"https://…/\(productID)")!))
    }
    return ProductView(viewModel: vm).asPresentable(title: "Product")
```

5.  **Module boundaries / plugin-like registration**
    *   Let features register their own builders so `DefaultScreenFactory` stays small.

```swift
public typealias RouteBuilder = (AppRoute) -> Presentable?
private var builders: [String: RouteBuilder] = [:]   // key by module name

public func register(module name: String, builder: @escaping RouteBuilder) {
    builders[name] = builder
}

public func screen(for route: AppRoute) -> Presentable {
    for build in builders.values { if let p = build(route) { return p } }
    // fallback…
    return NotFoundView().asPresentable(title: "Not Found")
}
```

6.  **Testing & previews**
    *   **Unit tests**: replace the factory with a mock to assert navigation, no UI required.
*   **SwiftUI previews**: construct screens with preview dependencies.

```swift
final class MockScreenFactory: ScreenFactory {
    var lastRoute: AppRoute?
    func screen(for route: AppRoute) -> Presentable {
        lastRoute = route
        return DummyVC(title: "Mock \(route)")
    }
}

// In a coordinator test:
let factory = MockScreenFactory()
sut.open(.product(id: UUID()))
XCTAssertEqual(factory.lastRoute, .product(id: expected))
```

7.  **State restoration + decoding**
    *   When restoring `[AppRoute]`, the factory recreates the same screens without extra logic in the coordinator.

* * *

How coordinators consume it (day to day)
========================================

```swift
final class AppCoordinator: Coordinator {
    private let router: Router
    private let screens: ScreenFactory

    init(router: Router, screens: ScreenFactory) {
        self.router = router
        self.screens = screens
    }

    func start() {
        router.setRoot(screens.screen(for: .home), hideBar: false, animated: false)
    }

    func open(_ route: AppRoute) {
        router.push(screens.screen(for: route), animated: true, completion: nil)
    }

    func present(_ route: AppRoute, as style: ModalStyle = .sheet()) {
        router.present(screens.screen(for: route), style: style, animated: true, completion: nil)
    }
}
```

* * *

Practical patterns you’ll add over time
=======================================

*   **Analytics wrapper:** log `routeShown(route)` inside the factory right before returning the Presentable.
*   **A/B variants:** choose between `ProductAView` vs `ProductBView` based on a flag.
*   **Error surfaces:** route can encode error context; factory chooses an error screen.
*   **Cross-cutting decorators:** wrap VCs to embed a common container (e.g., pull-to-refresh host).

* * *

TL;DR
-----

Use `ScreenFactory` as the **composition root for UI**: it translates `AppRoute` → screen, wires **dependencies**, enforces **policies** (auth/flags), centralizes **theme/analytics**, enables **testing**, and keeps **coordinators ultra-thin**.

## Prompt:
If we're about to add new coordinator (i.e. AuthCoordinator) should new screen be added to the factory?

## Response:
Thought for 12s

Short answer: **not necessarily.**  
Add screens to the _app-wide_ `ScreenFactory` only if they should be globally addressable (via routes, deep links, or restoration). If the screens are **internal to a flow** (e.g., SignIn → OTP → Terms), keep them inside the `AuthCoordinator` (or give the feature its own tiny factory) and don’t bloat the global one.

Here’s a practical split:

When to add to the app `ScreenFactory`
--------------------------------------

Add new auth screens if any of these are true:

*   You want a **typed route** for them (e.g., `.auth(step:)`) for **deep link** or **state restoration**.
*   Multiple coordinators may navigate directly to a specific auth screen.
*   You want **global theming/analytics/DI** applied exactly like other app screens.

```swift
// Routes
enum AppRoute: Hashable, Codable {
    case auth(step: AuthStep)
    // …
}

enum AuthStep: Hashable, Codable { case signIn, otp(phone: String) }

// ScreenFactory
case let .auth(step):
    switch step {
    case .signIn:
        return SignInView(viewModel: SignInVM(deps: deps)).asPresentable(title: "Sign In")
    case let .otp(phone):
        return OTPView(viewModel: OTPVM(phone: phone, deps: deps)).asPresentable(title: "Verify")
    }
```

When **not** to add (keep it local to the coordinator)
------------------------------------------------------

If auth is a **private flow** that shouldn’t be addressed from the outside, let the coordinator build its own screens. This keeps the global factory lean.

```swift
protocol AuthScreenBuilding {
    func signIn() -> Presentable
    func otp(phone: String) -> Presentable
}

final class DefaultAuthScreens: AuthScreenBuilding {
    private let deps: AppDependencies
    init(deps: AppDependencies) { self.deps = deps }

    func signIn() -> Presentable {
        SignInView(viewModel: SignInVM(deps: deps)).asPresentable(title: "Sign In")
    }
    func otp(phone: String) -> Presentable {
        OTPView(viewModel: OTPVM(phone: phone, deps: deps)).asPresentable(title: "Verify")
    }
}

@MainActor
final class AuthCoordinator: FlowCoordinator {
    var children: [Coordinator] = []
    private let router: Router
    private let screens: AuthScreenBuilding

    init(router: Router, screens: AuthScreenBuilding) {
        self.router = router; self.screens = screens
    }

    func start() async -> AuthResult {
        router.present(screens.signIn(), style: .sheet(), animated: true, completion: nil)
        // … drive flow, push screens. No changes to the global ScreenFactory.
        // return .signedIn or .cancelled
    }
}
```

Hybrid (recommended in larger apps)
-----------------------------------

Compose feature-specific builders into the app factory so everything still benefits from shared DI, but **routing responsibility stays local**:

```swift
struct AppDependencies { let api: API; let auth: AuthService /* … */ }

final class DefaultScreenFactory: ScreenFactory {
    private let deps: AppDependencies
    private let authScreens: AuthScreenBuilding

    init(deps: AppDependencies) {
        self.deps = deps
        self.authScreens = DefaultAuthScreens(deps: deps) // composed sub-factory
    }

    func screen(for route: AppRoute) -> Presentable {
        switch route {
        case .home: /* … */
        case .settings: /* … */
        // If someday you decide to expose auth routes publicly:
        // case .auth(let step): return authScreens.screen(for: step)
        default: /* … */
        }
    }
}
```

Decision checklist
------------------

*   **Needs deep link or restoration to a specific auth step?** → Add route & put in global factory.
*   **Only used inside AuthCoordinator?** → Keep in a **feature-local factory** (or create views directly).
*   **Shared across modules / called from many places?** → Expose via app factory or a registered builder.
*   **You want to A/B or theme consistently at the app boundary?** → App factory.

This way, adding `AuthCoordinator` doesn’t automatically force you to grow the global `ScreenFactory`. You choose based on **addressability** (routes/deeplinks), **reuse**, and **separation of concerns**.



---
Powered by [ChatGPT Exporter](https://www.chatgptexporter.com)