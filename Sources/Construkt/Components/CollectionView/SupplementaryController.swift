//
//  👨‍💻 Created by @thatswiftdev on 04/02/26.
//
//  © 2026, https://github.com/thatswiftdev. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public struct SupplementaryController {
    public var id: AnyHashable
    let elementKind: String
    var dequeue: (UICollectionView, IndexPath) -> UICollectionReusableView
    var isHidden: Bool = false
    
    public init<ViewType: UICollectionReusableView>(
        id: AnyHashable = UUID(),
        elementKind: String,
        viewType: ViewType.Type,
        configure: @escaping (ViewType) -> Void
    ) {
        self.id = id
        self.elementKind = elementKind
        
        let registration = SupplementaryRegistrationCache.register(viewType: ViewType.self, elementKind: elementKind)
        
        self.dequeue = { collectionView, indexPath in
            let view = collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
            configure(view)
            return view
        }
    }
}

class SupplementaryRegistrationCache {
    static var cache = [String: Any]()
    
    static func register<ViewType: UICollectionReusableView>(viewType: ViewType.Type, elementKind: String) -> UICollectionView.SupplementaryRegistration<ViewType> {
        let key = "\(String(describing: ViewType.self))_\(elementKind)"
        
        if let existing = cache[key] as? UICollectionView.SupplementaryRegistration<ViewType> {
            return existing
        }
        
        // Dummy registration with no-op handler
        let registration = UICollectionView.SupplementaryRegistration<ViewType>(elementKind: elementKind) { _, _, _ in }
        
        cache[key] = registration
        return registration
    }
}
    
extension SupplementaryController {
    internal func asSkeleton() -> SupplementaryController {
        var copy = self
        // Ensure skeleton has a different ID to force section reload
        copy.id = UUID()
        let originalDequeue = self.dequeue
        copy.dequeue = { collectionView, indexPath in
            let view = originalDequeue(collectionView, indexPath)
            view.setAnimatedSkeletonView(true)
            return view
        }
        return copy
    }
}
