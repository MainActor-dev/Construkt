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

import UIKit
import RxSwift

public struct BuilderTapGestureContext<Base:UIView>: ViewBuilderContextProvider {
    public var view: Base
    public var gesture: UIGestureRecognizer
}

public struct BuilderSwipeGestureContext<Base:UIView>: ViewBuilderContextProvider {
    public var view: Base
    public var gesture: UISwipeGestureRecognizer
}

/// Provides declarative Rx-powered gesture recognizers (e.g., taps, swipes) for all builder views.
extension ModifiableView {

    @discardableResult
    public func onTapGesture(numberOfTaps: Int = 1, _ handler: @escaping (_ context: BuilderTapGestureContext<Base>) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { view in
            let gesture = UITapGestureRecognizer()
            gesture.numberOfTapsRequired = numberOfTaps
            view.addGestureRecognizer(gesture)
            view.isUserInteractionEnabled = true
            gesture.rx.event
                .asControlEvent()
                .throttle(.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
                .subscribe { [weak view, weak gesture] (e) in
                    guard let view = view, let gesture = gesture else { return }
                    let context = BuilderTapGestureContext(view: view, gesture: gesture)
                    handler(context)
                }
                .disposed(by: view.rxDisposeBag)
        }
    }

    @discardableResult
    public func onSwipeLeft(_ handler: @escaping (_ context: BuilderSwipeGestureContext<Base>) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { view in
            let gesture = UISwipeGestureRecognizer()
            gesture.direction = .left
            view.addGestureRecognizer(gesture)
            view.isUserInteractionEnabled = true
            gesture.rx.event
                .asControlEvent()
                .throttle(.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
                .subscribe { [weak view, weak gesture] (e) in
                    guard let view = view, let gesture = gesture else { return }
                    let context = BuilderSwipeGestureContext(view: view, gesture: gesture)
                    handler(context)
                }
                .disposed(by: view.rxDisposeBag)
        }
    }

    @discardableResult
    public func onSwipeRight(_ handler: @escaping (_ context: BuilderSwipeGestureContext<Base>) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { view in
            let gesture = UISwipeGestureRecognizer()
            gesture.direction = .right
            view.addGestureRecognizer(gesture)
            view.isUserInteractionEnabled = true
            gesture.rx.event
                .asControlEvent()
                .throttle(.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
                .subscribe { [weak view, weak gesture] (e) in
                    guard let view = view, let gesture = gesture else { return }
                    let context = BuilderSwipeGestureContext(view: view, gesture: gesture)
                    handler(context)
                }
                .disposed(by: view.rxDisposeBag)
        }
    }

    @discardableResult
    public func hideKeyboardOnBackgroundTap(cancelsTouchesInView: Bool = true) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { view in
            let gesture = UITapGestureRecognizer()
            gesture.numberOfTapsRequired = 1
            gesture.cancelsTouchesInView = cancelsTouchesInView
            view.addGestureRecognizer(gesture)
            gesture.rx.event
                .asControlEvent()
                .throttle(.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
                .subscribe { [weak view] _ in
                    view?.endEditing(true)
                }
                .disposed(by: view.rxDisposeBag)
        }
    }


}
