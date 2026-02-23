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

/// A property wrapper bridging the gap between declarative definitions and variable states.
/// It wraps a native `Property` internally, projecting a predictable memory model.
@propertyWrapper
public struct Variable<T> {
    
    private let property: Property<T>

    public var wrappedValue: T {
        get { property.value }
        set { property.value = newValue }
    }

    public var projectedValue: Property<T> {
        return property
    }

    public init(wrappedValue: T) {
        self.property = Property(wrappedValue)
    }
}

extension Variable: MutableViewBinding {
    public typealias Value = T
    
    public var value: T {
        get { property.value }
        set { property.value = newValue }
    }
    
    public func observe(on queue: DispatchQueue?, _ handler: @escaping (T) -> Void) -> AnyCancellableLifecycle {
        return property.observe(on: queue, handler)
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
