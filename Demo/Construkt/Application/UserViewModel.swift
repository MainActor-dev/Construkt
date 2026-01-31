import Foundation
import RxSwift
import RxCocoa
import Factory

class UserViewModel {
    
    // Use the Reusable Generic State
    @Variable private(set) var state = LoadableState<[User]>.initial
    
    // Internal
    private let client = NetworkClient(interceptors: [LoggerInterceptor()])
    
    func load() {
        state = .loading
        
        Task {
            do {
                // Simulate network delay for demo
                try await Task.sleep(nanoseconds: 1_000_000_000) // 5s
                
                let users: [User] = try await client.request(UsersEndpoint.getUsers)
                
                await MainActor.run {
                    if users.isEmpty {
                        self.state = .empty("No users found.")
                    } else {
                        self.state = .loaded(users)
                    }
                }
            } catch {
                await MainActor.run {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
}
