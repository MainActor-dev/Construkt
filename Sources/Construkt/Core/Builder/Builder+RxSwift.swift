//
//  Builder+RxSwift.swift
//  ViewBuilder
//
//  Created by Michael Long on 11/9/21.
//

import UIKit
import RxSwift
import RxCocoa


/// A protocol for wrapping types that emit standard, one-way RxSwift `Observable` events.
public protocol RxBinding {
    associatedtype T
    func asObservable() -> Observable<T>
}

extension Observable: RxBinding {
    // previously defined
}




/// A protocol extending `RxBinding` for types that act as both observers and observables, 
/// facilitating two-way UI bindings (e.g. `BehaviorRelay`).
public protocol RxBidirectionalBinding: RxBinding {
    associatedtype T
    func asRelay() -> BehaviorRelay<T>
}

extension BehaviorRelay: RxBidirectionalBinding {
    public func asRelay() -> BehaviorRelay<Element> { self }
}



extension ViewModifier {
    
    public init<B:RxBinding, T>(_ view: Base, binding: B, handler: @escaping (_ view: Base, _ value: T) -> Void) where B.T == T {
        self.modifiableView = view
        binding.asObservable()
            .observe(on: ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak view] value in
                if let view = view {
                    handler(view, value)
                }
            })
            .disposed(by: view.rxDisposeBag)
    }
        
    public init<B:RxBinding, T:Equatable>(_ view: Base, binding: B, keyPath: ReferenceWritableKeyPath<Base, T>) where B.T == T {
        self.modifiableView = view
        binding.asObservable()
            .observe(on: ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak view] value in
                if let view = view, view[keyPath: keyPath] != value {
                    view[keyPath: keyPath] = value
                }
            })
            .disposed(by: view.rxDisposeBag)
    }

}

extension ModifiableView {

    @discardableResult
    public func bind<B:RxBinding, T>(keyPath: ReferenceWritableKeyPath<Base, T>, binding: B) -> ViewModifier<Base> where B.T == T {
        ViewModifier(modifiableView) {
            binding.asObservable()
                .observe(on: ConcurrentMainScheduler.instance)
                .subscribe(onNext: { [weak modifiableView] value in
                    modifiableView?[keyPath: keyPath] = value
                })
                .disposed(by: $0.rxDisposeBag)
        }
    }

    @discardableResult
    public func onReceive<B:RxBinding, T>(_ binding: B, handler: @escaping (_ context: ViewBuilderValueContext<Base, T>) -> Void)
        -> ViewModifier<Base> where B.T == T {
            ViewModifier(modifiableView) {
                binding.asObservable()
                    .observe(on: ConcurrentMainScheduler.instance)
                    .subscribe(onNext: { [weak modifiableView] value in
                        if let view = modifiableView {
                            handler(ViewBuilderValueContext(view: view, value: value))
                        }
                    })
                    .disposed(by: $0.rxDisposeBag)
            }
    }

    /// Explicitly injects a parent `DisposeBag` to manage the Rx lifecycle of this component.
    ///
    /// - Note: When provided, this overrides the lazily created view-scoped `rxDisposeBag`. 
    /// To prevent prematurely cancelling earlier bindings in the builder chain, applying this modifier 
    /// should generally occur *before* subsequent `.bind` or `.onReceive` modifiers.
    @discardableResult
    public func disposed(by bag: DisposeBag) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { view in
            objc_setAssociatedObject(view, &NSObject.RxDisposeBagAttributesKey, bag, .OBJC_ASSOCIATION_RETAIN)
        }
    }

}

extension NSObject {

    fileprivate static var RxDisposeBagAttributesKey: UInt8 = 0

    /// Returns a generic RxSwift `DisposeBag` stored dynamically on the `NSObject` class via the Objective-C runtime.
    ///
    /// - Important: `ViewBuilder` uses this internally to manage subscription lifecycles. 
    /// Because the bag is retained by the parent `UIView` (or NSObject) object, it means all Rx streams binding to builders
    /// will intrinsically outlive the declarative function stack and bind strictly to the view's lifecycle. 
    /// If you wish to explicitly manage this, use the `.disposed(by:)` modifier on the builder to inject your own bag.
    public var rxDisposeBag: DisposeBag {
        if let disposeBag = objc_getAssociatedObject(self, &NSObject.RxDisposeBagAttributesKey) as? DisposeBag {
            return disposeBag
        }
        let disposeBag = DisposeBag()
        objc_setAssociatedObject(self, &NSObject.RxDisposeBagAttributesKey, disposeBag, .OBJC_ASSOCIATION_RETAIN)
        return disposeBag
    }

}

