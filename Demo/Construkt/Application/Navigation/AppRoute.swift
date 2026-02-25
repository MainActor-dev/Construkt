import Foundation
import ma_ios_common

public enum AppRoute: Codable, Equatable, Sendable {
    case home
    case explore
    case movieDetail(movieId: String)
    case movieList(title: String, sectionTypeRaw: String, genreId: Int?, genreName: String?, allGenres: [Genre]?)
    case search
}
