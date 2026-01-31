import Foundation

struct Todo: Decodable {
    let id: Int
    let title: String
    let completed: Bool
}

enum TodosEndpoint: Endpoint {
    case getTodo(id: Int)
    
    var path: String {
        switch self {
        case .getTodo(let id):
            return "todos/\(id)"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
}
