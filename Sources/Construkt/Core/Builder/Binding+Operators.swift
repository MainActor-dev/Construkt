//
//  Binding+Operators.swift
//  Construkt
//
//  Created for Construkt core.
//

import Foundation

/// A type-erased `ViewBinding` used for returning dynamic functional compositions (like map).
public struct AnyViewBinding<T>: ViewBinding {
    public typealias Value = T
    private let _observe: (DispatchQueue?, @escaping (T) -> Void) -> AnyCancellableLifecycle
    
    public init(_ observe: @escaping (DispatchQueue?, @escaping (T) -> Void) -> AnyCancellableLifecycle) {
        self._observe = observe
    }
    
    public func observe(on queue: DispatchQueue?, _ handler: @escaping (T) -> Void) -> AnyCancellableLifecycle {
        return _observe(queue, handler)
    }
}

public extension ViewBinding {
    
    /// Transforms the emitted values using the provided closure.
    func map<U>(_ transform: @escaping (Value) -> U) -> AnyViewBinding<U> {
        return AnyViewBinding<U> { queue, handler in
            return self.observe(on: queue) { value in
                handler(transform(value))
            }
        }
    }
    
    /// Bypasses the queue switching of this binding for observation logic.
    func receive(on queue: DispatchQueue?) -> AnyViewBinding<Value> {
        return AnyViewBinding<Value> { _, handler in
            return self.observe(on: queue, handler)
        }
    }
    
}

public extension ViewBinding where Value: Equatable {
    
    /// Filters out consecutive duplicate values from being emitted.
    func distinctUntilChanged() -> AnyViewBinding<Value> {
        return AnyViewBinding<Value> { queue, handler in
            var lastValue: Value?
            let lock = NSLock()
            
            return self.observe(on: queue) { value in
                lock.lock()
                let isDistinct = (lastValue != value)
                if isDistinct {
                    lastValue = value
                }
                lock.unlock()
                
                if isDistinct {
                    handler(value)
                }
            }
        }
    }
    
}
