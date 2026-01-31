import Foundation
import RxSwift
import RxCocoa
import Factory

// Assuming Variable is available from the Builder/Construkt module. 
// If it's internal to the framework, I might need to import the module specifically.
// Given the file structure, it seems everything is compiled together or 'Construkt' is the module.
// I'll try without explicit import first, or import Construkt if known.

class UserViewModel {
    
    // Use the Reusable Generic State
    @Variable private(set) var state = LoadableState<[User]>.initial
    
    // Internal
    private let client = NetworkClient(interceptors: [LoggerInterceptor()])
    private let disposeBag = DisposeBag()
    
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
