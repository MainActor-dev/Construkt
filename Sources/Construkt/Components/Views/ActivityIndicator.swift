//
//  Created by @thatswiftdev on 11/02/26.
//

import UIKit
import RxSwift
import RxCocoa

public struct ActivityIndicator: ModifiableView {
    
    public let modifiableView = Modified(UIActivityIndicatorView(style: .medium))
    
    public init(style: UIActivityIndicatorView.Style = .medium) {
        modifiableView.style = style
        modifiableView.hidesWhenStopped = true
    }
    
    public func color(_ color: UIColor) -> ActivityIndicator {
        modifiableView.color = color
        return self
    }
    
    public func style(_ style: UIActivityIndicatorView.Style) -> ActivityIndicator {
        modifiableView.style = style
        return self
    }

    public func animating<B: RxBinding>(_ binding: B) -> ActivityIndicator where B.T == Bool {
        binding
            .asObservable()
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: modifiableView.rx.isAnimating)
            .disposed(by: modifiableView.rxDisposeBag)
        return self
    }
}
