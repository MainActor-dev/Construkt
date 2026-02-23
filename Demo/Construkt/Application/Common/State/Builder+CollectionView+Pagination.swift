import UIKit
import RxSwift
import RxCocoa
import Construkt

public extension CollectionView {
    /// - Returns: A configured `CollectionView`.
    func pagination<B: ObservableType>(
        model binding: B,
        threshold: CGFloat = 100,
        handler: @escaping (Int) -> Void
    ) -> CollectionView where B.Element == ListPaginationModel {
        
        let scrollViewObservable = modifiableView.rx.methodInvoked(#selector(CollectionViewWrapperView.scrollViewDidScroll(_:)))
            .map { $0.first as? UIScrollView }
            .compactMap { $0 }
        
        scrollViewObservable
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .withLatestFrom(binding) { ($0, $1) }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (scrollView, model) in
                guard scrollView.isDragging else { return }
                
                let offsetY = scrollView.contentOffset.y
                let contentHeight = scrollView.contentSize.height
                let frameHeight = scrollView.frame.height
                
                let triggerDistance = contentHeight - frameHeight - threshold
                
                if offsetY > triggerDistance {
                    if !model.isPaginating && !model.isLastPage {
                        handler(model.nextPage)
                    }
                }
            })
            .store(in: modifiableView.cancelBag)
        
        return self
    }
}
