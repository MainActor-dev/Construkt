import Foundation
import ConstruktKit

public struct ExploreGenre: Hashable, Identifiable {
    public let id: String
    public let name: String
    public let imageURL: String
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
    
    @Variable public var genres: [ExploreGenre] = []
    @Variable public var collections: [ExploreCollection] = []
    @Variable public var arrivals: [ExploreArrival] = []
    
    private let service: MovieServiceProtocol
    
    public init(service: MovieServiceProtocol = MovieService()) {
        self.service = service
    }
    
    public func loadData() {
        genres = [
            .init(id: "28", name: "Action", imageURL: "https://images.unsplash.com/photo-1552083375-1447ce886485?q=80&w=400&auto=format&fit=crop"),
            .init(id: "18", name: "Drama", imageURL: "https://images.unsplash.com/photo-1485846234645-a62644f84728?q=80&w=400&auto=format&fit=crop"),
            .init(id: "27", name: "Horror", imageURL: "https://images.unsplash.com/photo-1509248961158-e54f6934749c?q=80&w=400&auto=format&fit=crop"),
            .init(id: "35", name: "Comedy", imageURL: "https://images.unsplash.com/photo-1543584756-8f40a802e14f?q=80&w=400&auto=format&fit=crop")
        ]
        
        Task {
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
