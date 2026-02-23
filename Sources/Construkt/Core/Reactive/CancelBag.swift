//
//  CancelBag.swift
//  Construkt
//
//  Created for Construkt core.
//

import Foundation

/// A container that retains `AnyCancellableLifecycle` tokens and automatically cancels them
/// when the bag itself is deallocated.
public final class CancelBag {
    private var cancellables: [AnyCancellableLifecycle] = []
    private let lock = NSLock()
    
    public init() {}
    
    public func insert(_ cancellable: AnyCancellableLifecycle) {
        lock.lock()
        defer { lock.unlock() }
        cancellables.append(cancellable)
    }
    
    public func cancel() {
        lock.lock()
        let items = cancellables
        cancellables.removeAll()
        lock.unlock()
        
        for item in items {
            item.cancel()
        }
    }
    
    deinit {
        cancel()
    }
}

public extension AnyCancellableLifecycle {
    /// Stores the lifecycle token in the provided `CancelBag`.
    func store(in bag: CancelBag) {
        bag.insert(self)
    }
}

public extension NSObject {
    fileprivate static var ViewBindingCancelBagKey: UInt8 = 0
    
    /// Returns a generic `CancelBag` stored dynamically on the `NSObject` class via the Objective-C runtime.
    /// This is the native, zero-dependency alternative to `rxDisposeBag`.
    var cancelBag: CancelBag {
        if let bag = objc_getAssociatedObject(self, &NSObject.ViewBindingCancelBagKey) as? CancelBag {
            return bag
        }
        let bag = CancelBag()
        objc_setAssociatedObject(self, &NSObject.ViewBindingCancelBagKey, bag, .OBJC_ASSOCIATION_RETAIN)
        return bag
    }
}
