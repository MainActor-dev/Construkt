import Foundation
import Factory

extension Container {
    static let userViewModel = Factory(scope: .shared) {
        UserViewModel()
    }
}
