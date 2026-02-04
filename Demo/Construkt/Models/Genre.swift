import Foundation

public struct Genre: Codable, Identifiable, Equatable, Hashable {
    public let id: Int
    public let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    static var placeholder: Genre {
        .init(id: -1, name: "Genre")
    }
}

public struct GenreResponse: Codable {
    public let genres: [Genre]
}
