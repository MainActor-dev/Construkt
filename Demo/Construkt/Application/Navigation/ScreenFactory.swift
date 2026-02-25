import UIKit
import ma_ios_common

@MainActor
public protocol ScreenFactoryProtocol {
    func makeScreen(for route: AppRoute) -> Presentable
}

@MainActor
public final class ScreenFactory: ScreenFactoryProtocol {
    public init() {}
    
    public func makeScreen(for route: AppRoute) -> Presentable {
        switch route {
        case .home:
            return HomeViewController()
        case .explore:
            return ExploreViewController()
        case .movieDetail(let movieId):
            // Fallback for now, could initialize a specific Movie if injected
            return UIViewController() // Replace with MovieDetailViewController later
        }
    }
}
