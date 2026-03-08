import UIKit
import SwiftUI

/// Abstraction for presenting either UIKit or SwiftUI screens uniformly
///
/// Enables coordinators and routers to navigate without knowing implementation details.
/// UIViewController conforms automatically, while SwiftUI views use HostingPresentable.
@MainActor
public protocol Presentable {
    func toViewController() -> UIViewController
}

// MARK: - UIKit Conformance

extension UIViewController: Presentable {
    public func toViewController() -> UIViewController {
        return self
    }
}

// MARK: - SwiftUI Support

/// Wraps a SwiftUI View as a Presentable for use with Router
@MainActor
public struct HostingPresentable<Content: View>: Presentable {
    public let view: Content
    public let title: String?
    
    public init(view: Content, title: String? = nil) {
        self.view = view
        self.title = title
    }
    
    public func toViewController() -> UIViewController {
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = title
        return hostingController
    }
}

/// Convenience extension for creating HostingPresentable from any SwiftUI View
@MainActor
public extension View {
    func asPresentable(title: String? = nil) -> HostingPresentable<Self> {
        return HostingPresentable(view: self, title: title)
    }
}
