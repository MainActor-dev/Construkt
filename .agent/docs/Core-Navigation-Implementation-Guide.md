# Core Navigation Implementation Guide

This document outlines the recent enhancements made to the Core Navigation infrastructure in the Construkt application and provides a guide on how to implement them.

## 🚀 What's New

We've upgraded our Coordinator pattern to ensure type-safety, better modal management, and robust state restoration and deep linking capabilities. The new architecture revolves around the following core components:

1. **Router Enhancements**: 
   - `ModalStyle` now natively supports iOS 15 `UISheetPresentationController`, allowing you to easily configure sheet detents (e.g., `.medium()`, `.large()`) and grabber visibility natively.
   - `RouterProtocol.setRoot` now accepts a `hideBar` parameter to easily toggle the navigation bar visibility from the root.

2. **Coordinator Protocols**: 
   - `Coordinator`: A standard protocol requiring a `start()` method (`@MainActor`).
   - `FlowCoordinator`: A protocol for handling asynchronous flows that return a result. Ideal for authentication or complex multi-step forms where the caller needs to `await` completion.

3. **Type-Safe Routing (`AppRoute`)**: 
   - All navigation paths are now modeled using a strongly-typed `AppRoute` enum.
   - The enum conforms to `Codable`, `Equatable`, `Hashable`, and `Sendable` making it completely safe for state serialization.

4. **Deep Linking (`DeepLinkMapper`)**: 
   - A centralized utility that parses incoming `URL`s (e.g., `construkt://movie/123`) into an `AppRoute` and maps `AppRoute`s back to `URL`s.

5. **Screen Factory (`ScreenFactory`)**: 
   - Decouples UI assembly from the Coordinator. Instead of instantiating ViewControllers directly, Coordinators ask the Factory to return a `Presentable` for a given `AppRoute`.

6. **State Restoration**: 
   - The Root Coordinator (e.g., `AppCoordinator`) now maintains a `currentPath: [AppRoute]` array, effectively tracking the navigation stack. This array can be serialized into `Data` via `saveRestorationData()` and restored on subsequent application launches.

---

## 🛠️ How to Implement It

### 1. Defining a New Route

When adding a new screen, first define its route in `AppRoute.swift`:

```swift
public enum AppRoute: Codable, Equatable, Hashable, Sendable {
    case home
    case movieDetail(movieId: String)
    case web(url: URL)
    // Add new routes here...
}
```

### 2. Mapping Deep Links

Update `DeepLinkMapper.swift` so external URLs map directly to your new route:

```swift
public func route(from url: URL) -> AppRoute? {
    if url.host == "home" { return .home }
    
    // Parses: construkt://movie/123
    if url.host == "movie", url.pathComponents.count > 1 {
        let id = url.lastPathComponent
        return .movieDetail(movieId: id)
    }
    return nil
}

public func url(from route: AppRoute) -> URL? {
    // Implement the reverse mapping
}
```

### 3. Assembling Screens in the Factory

Update `ScreenFactory.swift` to construct and return the `Presentable` view for the route. This isolates dependency injection and view construction:

```swift
func makeScreen(for route: AppRoute) -> Presentable {
    switch route {
    case .home:
        return HomeViewController()
    case .movieDetail(let id):
        return MovieDetailViewController(movieId: id)
    case .web(let url):
        let vc = WebViewController(url: url)
        return vc
    }
}
```

### 4. Navigating in Coordinators

Inside your Coordinators, use the `ScreenFactory` to generate views and the `Router` to navigate:

```swift
@available(iOS 15.0, *)
@MainActor
final class HomeCoordinator: BaseCoordinator {
    private let factory: ScreenFactoryProtocol

    init(router: RouterProtocol, factory: ScreenFactoryProtocol) {
        self.factory = factory
        super.init(router: router)
    }

    override func start() {
        // Generating screen from Factory
        let homeVC = factory.makeScreen(for: .home)
        
        homeVC.onAction = { [weak self] action in
            switch action {
            case .movieSelected(let movie):
                // Type-safe routing using AppRoute
                let screen = self?.factory.makeScreen(for: .movieDetail(movieId: movie.id))
                self?.router.push(screen, animated: true, hideTabBar: true, onPop: nil)
            }
        }
        
        router.setRoot(homeVC, animated: false, onPop: nil)
    }
}
```

### 5. Presenting Advanced Modals (iOS 15+)

The `Router` now supports complex sheet configurations seamlessly using `ModalStyle`:

```swift
let modalVC = factory.makeScreen(for: .settings)
router.present(
    modalVC, 
    style: .sheet(
        detents: [.medium(), .large()], 
        prefersGrabberVisible: true
    ), 
    animated: true, 
    onDismiss: {
        print("Modal dismissed!")
    }
)
```

### 6. Managing Async Flows

If a coordinator represents an asynchronous task (like a Login flow), make it conform to `FlowCoordinator`:

```swift
@MainActor
final class LoginCoordinator: FlowCoordinator {
    typealias ResultType = Bool
    
    private let router: RouterProtocol
    
    init(router: RouterProtocol) {
        self.router = router
    }
    
    func start() async -> Bool {
        return await withCheckedContinuation { continuation in
            let loginVC = LoginViewController()
            loginVC.onLoginSuccess = {
                continuation.resume(returning: true)
            }
            router.present(loginVC, style: .fullScreen, animated: true, onDismiss: nil)
        }
    }
}

// Usage in parent coordinator:
// Task {
//     let success = await loginCoordinator.start()
//     if success { ... }
// }
```

### 7. State Restoration

Track state in your root coordinator by appending standard `AppRoute`s, then serialize it:

```swift
public func open(_ route: AppRoute) {
    currentPath.append(route)
    // Perform actual navigation resolving the route
}

// Save State
public func saveRestorationData() -> Data? {
    try? JSONEncoder().encode(currentPath)
}

// Restore State
public func restore(from data: Data) {
    guard let saved = try? JSONDecoder().decode([AppRoute].self, from: data) else { return }
    // Loop over `saved` array and simulate the pushes
}
```
