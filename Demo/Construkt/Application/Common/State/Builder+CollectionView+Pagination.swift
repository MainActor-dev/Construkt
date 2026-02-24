import UIKit
import ConstruktKit

public extension CollectionView {
    /// Adds native pagination support using a `ViewBinding<ListPaginationModel>`.
    /// Triggers `handler` when the user scrolls near the bottom.
    @discardableResult
    func pagination<B: ViewBinding>(
        model binding: B,
        threshold: CGFloat = 100,
        handler: @escaping (Int) -> Void
    ) -> CollectionView where B.Value == ListPaginationModel {
        // Store the binding and handler in the wrapper view for scroll observation
        let paginationTarget = PaginationTarget(binding: binding, threshold: threshold, handler: handler)
        
        return self.onScroll { scrollView in
            paginationTarget.handleScroll(scrollView)
        }.asCollectionView(self)
    }
}

// Helper to bridge ViewModifier back to CollectionView
private extension ViewModifier where Base == CollectionViewWrapperView {
    func asCollectionView(_ original: CollectionView) -> CollectionView {
        return original
    }
}

private final class PaginationTarget<B: ViewBinding>: NSObject where B.Value == ListPaginationModel {
    let binding: B
    let threshold: CGFloat
    let handler: (Int) -> Void
    private var lastTriggerTime: Date = .distantPast
    
    init(binding: B, threshold: CGFloat, handler: @escaping (Int) -> Void) {
        self.binding = binding
        self.threshold = threshold
        self.handler = handler
    }
    
    func handleScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }
        
        // Throttle: only check every 250ms
        let now = Date()
        guard now.timeIntervalSince(lastTriggerTime) > 0.25 else { return }
        lastTriggerTime = now
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        guard contentHeight > 0, frameHeight > 0 else { return }
        
        let triggerDistance = contentHeight - frameHeight - threshold
        
        if offsetY > triggerDistance {
            // Read current state — Property emits synchronously on observe
            var currentModel: ListPaginationModel?
            let token = binding.observe(on: nil) { model in
                currentModel = model
            }
            token.cancel()
            
            if let model = currentModel, !model.isPaginating, !model.isLastPage {
                handler(model.nextPage)
            }
        }
    }
}
