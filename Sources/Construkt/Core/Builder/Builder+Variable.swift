//
//  👨‍💻 Created by @thatswiftdev on 23/02/26.
//  © 2026, https://github.com/thatswiftdev. All rights reserved.
//
//  Originally created by Michael Long
//  https://github.com/hmlongco/Builder

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

import Foundation
import RxSwift
import RxCocoa

/// A property wrapper that leverages RxSwift's `BehaviorRelay` to provide easy 
/// reactive bindings and local state management for custom views.
@propertyWrapper public struct Variable<T> {
    
    private var relay: BehaviorRelay<T>
    
    public init(_ relay: BehaviorRelay<T>) {
        self.relay = relay
    }
    
    /// Provides transparent get/set variable access while routing updates through the underlying reactive relay.
    public var wrappedValue: T {
        get { return relay.value }
        nonmutating set { relay.accept(newValue) }
    }
    
    /// Exposes the property wrapper instance directly, allowing bindings using the `$` syntax.
    public var projectedValue: Variable<T> {
        get { return self }
    }
    
}

extension Variable {
    
    public init(wrappedValue: T) {
        self.relay = BehaviorRelay<T>(value: wrappedValue)
    }
    
}

extension Variable where T:Equatable {
    
    public func onChange(_ observer: @escaping (_ value: T) -> ()) -> Disposable {
        relay
            .skip(1)
            .distinctUntilChanged()
            .subscribe { observer($0) }
    }

}

extension Variable: RxBinding {
    
    public func asObservable() -> Observable<T> {
        return relay.asObservable()
    }
    
    public func observe(on scheduler: ImmediateSchedulerType) -> Observable<T> {
        return relay.observe(on: scheduler)
    }
    
    public func bind(_ observable: Observable<T>) -> Disposable {
        return observable.bind(to: relay)
    }
        
}

extension Variable: RxBidirectionalBinding {
    public func asRelay() -> BehaviorRelay<T> {
        return relay
    }
    
}

//struct A: ViewBuilder {
//    @Variable var name = "Michael"
//    var body: View {
//        B(name: $name)
//    }
//}
//
//struct B: ViewBuilder  {
//    @Variable var name: String
//    var body: View {
//         LabelView(name)
//    }
//}
