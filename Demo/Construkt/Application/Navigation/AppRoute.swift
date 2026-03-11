import Foundation


public enum AppRoute: Codable, Equatable, Hashable, Sendable {
    case home
    case explore
    case movieDetail(movieId: String)
    case movieList(title: String, sectionTypeRaw: String, genreId: Int?, genreName: String?, allGenres: [Genre]?)
    case search
    case web(url: URL)
}
