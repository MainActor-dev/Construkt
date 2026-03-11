import Foundation

/// Convert URLs to routes and back for deep linking support.
public struct DeepLinkMapper {
    public init() {}

    public func route(from url: URL) -> AppRoute? {
        if url.host == "home" { return .home }
        if url.host == "explore" { return .explore }
        if url.host == "search" { return .search }
        
        // e.g. construkt://movie/123
        if url.host == "movie", url.pathComponents.count > 1 {
            let id = url.lastPathComponent
            return .movieDetail(movieId: Int(id) ?? 0)
        }
        
        return nil
    }

    public func url(from route: AppRoute) -> URL? {
        switch route {
        case .home:
            return URL(string: "construkt://home")
        case .explore:
            return URL(string: "construkt://explore")
        case .search:
            return URL(string: "construkt://search")
        case .movieDetail(let id):
            return URL(string: "construkt://movie/\(id)")
        default:
            return nil
        }
    }
}
