import UIKit
import RxSwift
import RxCocoa
import Construkt

public extension CollectionView {
    func pagination<B: RxBinding>(
        model binding: B,
        threshold: CGFloat = 100,
        handler: @escaping (Int) -> Void
    ) -> CollectionView where B.T == ListPaginationModel {
        
        let scrollViewObservable =  modifiableView.rx.methodInvoked(#selector(CollectionViewWrapperView.scrollViewDidScroll(_:)))
            .map { $0.first as? UIScrollView }
            .compactMap { $0 }
        
        let stateObservable = binding.asObservable()
        
        scrollViewObservable
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .withLatestFrom(stateObservable) { ($0, $1) }
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
            .disposed(by: modifiableView.rxDisposeBag)
        
        return self
    }
}
