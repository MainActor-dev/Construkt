//
//  Construkt+Combine.swift
//  Construkt
//
//  Created for Construkt core compatibility.
//

import Foundation
import Combine
import ConstruktKit

/// Makes Combine `Publisher` intrinsically compatible with Construkt's agnostic `ViewBinding` architecture.
/// This allows codebases using Combine to pass publishers directly into builder components.
extension Publisher where Failure == Never {
    
    public func observe(on targetQueue: DispatchQueue?, _ handler: @escaping (Output) -> Void) -> AnyCancellableLifecycle {
        var publisher: AnyPublisher<Output, Never> = self.eraseToAnyPublisher()
        
        if let queue = targetQueue {
            publisher = publisher.receive(on: queue).eraseToAnyPublisher()
        }
        
        let cancellable = publisher.sink { value in
            handler(value)
        }
        
        return CombineAdapterCancellable(cancellable)
    }
}

#if swift(>=5.10)
extension AnyPublisher: @retroactive ViewBinding where Failure == Never {
    public typealias Value = Output
}

extension CurrentValueSubject: @retroactive ViewBinding where Failure == Never {
    public typealias Value = Output
}

extension CurrentValueSubject: @retroactive MutableViewBinding where Failure == Never {
}

extension Published.Publisher: @retroactive ViewBinding where Failure == Never {
    public typealias Value = Output
}
#else
extension AnyPublisher: ViewBinding where Failure == Never {
    public typealias Value = Output
}

extension CurrentValueSubject: ViewBinding where Failure == Never {
    public typealias Value = Output
}

extension CurrentValueSubject: MutableViewBinding where Failure == Never {
}

extension Published.Publisher: ViewBinding where Failure == Never {
    public typealias Value = Output
}
#endif

private final class CombineAdapterCancellable: AnyCancellableLifecycle {
    let cancellable: AnyCancellable
    
    init(_ cancellable: AnyCancellable) {
        self.cancellable = cancellable
    }
    
    func cancel() {
        cancellable.cancel()
    }
}

extension AnyCancellable {
    public func store(in cancelBag: CancelBag) {
        cancelBag.insert(CombineAdapterCancellable(self))
    }
}

extension ViewBinding {
    /// Bridges Construkt agnostic ViewBindings into Combine Publishers.
    public func asPublisher() -> AnyPublisher<Value, Never> {
        if let pub = self as? AnyPublisher<Value, Never> { return pub }
        
        let subject = PassthroughSubject<Value, Never>()
        var lifecycle: AnyCancellableLifecycle?
        
        return subject
            .handleEvents(
                receiveSubscription: { _ in
                    lifecycle = self.observe(on: nil) { value in
                        subject.send(value)
                    }
                },
                receiveCancel: {
                    lifecycle?.cancel()
                    lifecycle = nil
                }
            )
            .eraseToAnyPublisher()
    }
}
