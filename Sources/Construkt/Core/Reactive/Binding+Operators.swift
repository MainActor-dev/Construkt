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
    
    /// Creates a binding that immediately emits a constant value to every observer.
    public static func just(_ value: T) -> AnyViewBinding<T> {
        AnyViewBinding<T> { _, handler in
            handler(value)
            return EmptyCancellable()
        }
    }
    
    /// Combines two bindings, emitting the latest values from each whenever either changes.
    public static func combineLatest<A: ViewBinding, B: ViewBinding>(
        _ a: A, _ b: B
    ) -> AnyViewBinding<(A.Value, B.Value)> where T == (A.Value, B.Value) {
        AnyViewBinding<(A.Value, B.Value)> { queue, handler in
            let lock = NSLock()
            var latestA: A.Value?
            var latestB: B.Value?
            
            let tokenA = a.observe(on: queue) { aVal in
                lock.lock()
                latestA = aVal
                let b = latestB
                lock.unlock()
                if let b = b { handler((aVal, b)) }
            }
            let tokenB = b.observe(on: queue) { bVal in
                lock.lock()
                latestB = bVal
                let a = latestA
                lock.unlock()
                if let a = a { handler((a, bVal)) }
            }
            
            return CompoundCancellable([tokenA, tokenB])
        }
    }
}

/// Combines an array of bindings of arrays, emitting a flattened array whenever any source changes.
public func combineLatestBindings<U>(_ bindings: [AnyViewBinding<[U]>]) -> AnyViewBinding<[U]> {
    guard !bindings.isEmpty else { return .just([]) }
    if bindings.count == 1 { return bindings[0] }
    
    return AnyViewBinding<[U]> { queue, handler in
        let lock = NSLock()
        var latestValues: [[U]?] = Array(repeating: nil, count: bindings.count)
        var tokens: [AnyCancellableLifecycle] = []
        
        for (index, binding) in bindings.enumerated() {
            let token = binding.observe(on: queue) { value in
                lock.lock()
                latestValues[index] = value
                let allReady = latestValues.allSatisfy { $0 != nil }
                let combined: [[U]]? = allReady ? latestValues.compactMap { $0 } : nil
                lock.unlock()
                
                if let combined = combined {
                    handler(combined.flatMap { $0 })
                }
            }
            tokens.append(token)
        }
        
        return CompoundCancellable(tokens)
    }
}

/// An empty cancellable that does nothing — used by `.just()`.
private struct EmptyCancellable: AnyCancellableLifecycle {
    func cancel() {}
}

/// Groups multiple cancellables into one lifecycle token.
private final class CompoundCancellable: AnyCancellableLifecycle {
    private let tokens: [AnyCancellableLifecycle]
    init(_ tokens: [AnyCancellableLifecycle]) { self.tokens = tokens }
    func cancel() { tokens.forEach { $0.cancel() } }
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
    
    /// Transforms and filters emitted values, only forwarding non-nil results.
    func compactMap<U>(_ transform: @escaping (Value) -> U?) -> AnyViewBinding<U> {
        return AnyViewBinding<U> { queue, handler in
            return self.observe(on: queue) { value in
                if let transformed = transform(value) {
                    handler(transformed)
                }
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
