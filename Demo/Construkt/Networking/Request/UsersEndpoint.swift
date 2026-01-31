import Foundation

struct User: Decodable, Equatable {
    let id: Int
    let name: String
    let email: String
    let website: String
}

enum UsersEndpoint: Endpoint {
    case getUsers
    
    var path: String {
        switch self {
        case .getUsers:
            return "users"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
}
