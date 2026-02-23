//
//  Construkt+RxSwift.swift
//  Construkt
//
//  Created for Construkt core compatibility.
//

import Foundation
import RxSwift
import RxCocoa
import ConstruktKit

/// Makes RxSwift `Observable` intrinsically compatible with Construkt's new agnostic `ViewBinding` architecture.
/// This allows existing codebases to continue passing Rx observables directly into builder components.
extension ObservableType {
    
    public func observe(on targetQueue: DispatchQueue?, _ handler: @escaping (Element) -> Void) -> AnyCancellableLifecycle {
        var observable: Observable<Element> = self.asObservable()
        
        // Map native Dispatch queues to Rx Schedulers if needed
        if targetQueue == .main {
            observable = observable.observe(on: MainScheduler.instance)
        } else if let queue = targetQueue {
            let scheduler = SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: "construkt.rxadapter")
            observable = observable.observe(on: scheduler)
        }
        
        let disposable = observable.subscribe(onNext: { value in
            handler(value)
        })
        
        return RxAdapterCancellable(disposable)
    }
}

extension Observable: ViewBinding {
    public typealias Value = Element
}

extension BehaviorRelay: MutableViewBinding {
    public typealias Value = Element
    
    public var value: Element {
        get { return self.value }
        set { self.accept(newValue) }
    }
}

private final class RxAdapterCancellable: AnyCancellableLifecycle {
    let disposable: Disposable
    
    init(_ disposable: Disposable) {
        self.disposable = disposable
    }
    
    func cancel() {
        disposable.dispose()
    }
}

extension Disposable {
    public func store(in cancelBag: CancelBag) {
        cancelBag.insert(RxAdapterCancellable(self))
    }
}

extension ViewBinding {
    /// Bridges Construkt agnostic ViewBindings into RxSwift Observables.
    public func asObservable() -> Observable<Value> {
        if let obs = self as? Observable<Value> { return obs }
        return Observable.create { observer in
            let lifecycle = self.observe(on: nil) { value in
                observer.onNext(value)
            }
            return Disposables.create { lifecycle.cancel() }
        }
    }
}
