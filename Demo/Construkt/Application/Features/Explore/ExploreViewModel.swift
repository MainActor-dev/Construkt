import Foundation
import ConstruktKit

public struct ExploreGenre: Hashable, Identifiable {
    public let id: String
    public let name: String
    public let colorHex: String
}

public struct ExploreCollection: Hashable, Identifiable {
    public let id: String
    public let topic: String
    public let title: String
    public let imageURL: String
}

public struct ExploreArrival: Hashable, Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let imageURL: String
}

public final class ExploreViewModel {
    @Variable public var searchQuery: String = ""
    @Variable public var isSearching: Bool = false
    
    @Variable public var genres: [ExploreGenre] = [] // Will hold suffix(4) for the Explore View
    @Variable public var allGenres: [ExploreGenre] = [] // All genres to pass to MovieList
    
    @Variable public var collections: [ExploreCollection] = []
    @Variable public var arrivals: [ExploreArrival] = []
    
    private let service: MovieServiceProtocol
    
    public init(service: MovieServiceProtocol = MovieService()) {
        self.service = service
    }
    
    public func loadData() {

        
        Task {
            do {
                let genreResponse = try await service.getGenres()
                let colors = ["#FF3B30", "#5AC8FA", "#FF9500", "#AF52DE"] // Vibrant iOS-like colors
                await MainActor.run {
                    self.allGenres = genreResponse.genres.enumerated().map { index, genre in
                        ExploreGenre(
                            id: String(genre.id),
                            name: genre.name,
                            colorHex: colors[index % colors.count]
                        )
                    }
                    self.genres = Array(self.allGenres.prefix(4))
                }
            } catch {
                print("Failed to fetch genres: \(error)")
            }
            
            do {
                let popular = try await service.getPopularMovies(page: 1)
                await MainActor.run {
                    self.collections = popular.results.prefix(5).map { movie in
                        ExploreCollection(
                            id: String(movie.id),
                            topic: "TRENDING",
                            title: movie.title,
                            imageURL: movie.backdropURL?.absoluteString ?? ""
                        )
                    }
                }
            } catch {
                print("Failed to fetch collections: \(error)")
            }
            
            do {
                let nowPlaying = try await service.getNowPlayingMovies(page: 1)
                await MainActor.run {
                    self.arrivals = nowPlaying.results.prefix(10).map { movie in
                        ExploreArrival(
                            id: String(movie.id),
                            title: movie.title,
                            subtitle: "Score: \(String(format: "%.1f", movie.voteAverage)) • \(movie.releaseDate ?? "Recently Added")",
                            imageURL: movie.backdropURL?.absoluteString ?? ""
                        )
                    }
                }
            } catch {
                print("Failed to fetch arrivals: \(error)")
            }
        }
    }
}
