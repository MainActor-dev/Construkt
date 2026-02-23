import UIKit
import RxSwift
import RxCocoa

// MARK: - API Protocols

/// Protocol allowing states to define their relationship for optimization.
public protocol EquivalentState {
    /// Returns true if `self` is just a modification of `previous` (e.g. data update)
    /// and represents the same "Layout" or "View Type".
    /// If true, the Container might try to call `update(to:)` instead of rebuilding.
    /// Note: 'previous' is Any to avoid Self requirements hindering conditional casting.
    func isModification(of previous: Any) -> Bool
}

/// Optional protocol to provide a stable cache key, ignoring dynamic data.
/// Example: return "loaded" for .loaded(users), ensuring we don't cache 100 variations of user lists.
public protocol CacheKeyProviding {
    var cacheKey: String { get }
}

public protocol UpdatableView {
    func update(with state: Any)
}

// ... (Rest of file)



// MARK: - StateContainer

public class StateContainer<State: Equatable>: UIView {
    
    // Configuration
    public var transitionDuration: TimeInterval = 0.2
    
    // Internal
    private let disposeBag = DisposeBag()
    private var currentState: State?
    private var activeView: UIView? // Tracks the currently active view to prevent race conditions
    private let builder: (State) -> ViewConvertable
    
    // Cache for View Reuse (Optimization)
    // Key: String description of the state (or a dedicated key)
    private var viewCache: [String: UIView] = [:]
    
    // MARK: - Lifecycle
    
    public init(
        _ variable: Variable<State>,
        @ViewResultBuilder builder: @escaping (State) -> ViewConvertable
    ) {
        self.builder = builder
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        variable.observe(on: .main) { [weak self] state in
            self?.transition(to: state)
        }.store(in: cancelBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Transition Logic
    
    private func transition(to state: State) {
        // 1. Check for Smart Update (Stability)
        if let current = currentState,
           let equivalentNew = state as? EquivalentState,
           equivalentNew.isModification(of: current),
           let activeView = self.activeView as? UpdatableView {
            // Update in place without destroying view hierarchy (Preserves Scroll/Focus)
            activeView.update(with: state)
            self.currentState = state
            return
        }
        
        // 2. Standard Transition (Swap)
        // Check cache first
        let cacheKey = cacheKey(for: state)
        let newView: UIView
        
        if let cached = viewCache[cacheKey] {
            newView = cached
        } else {
            // Build fresh
            let content = builder(state)
            // Convert to UIView. If result implies multiple views, wrap in host.
            // Simplified: assuming builder returns single view or we take first.
            // For robustness, we wrap single items or stacks.
            let views = content.asViews()
            if views.count == 1 {
                newView = views[0].build()
            } else {
                // Fallback for multi-view return -> Wrap in logical container
                let stack = BuilderInternalUIStackView()
                stack.axis = .vertical
                stack.alignment = .fill
                stack.distribution = .fill
                views.forEach { stack.addArrangedSubview($0.build()) }
                newView = stack
            }
            
            // Cache if appropriate (e.g. Loading state is constant)
            // For now, we cache everything. In production, we might limit cache size.
            viewCache[cacheKey] = newView
        }
        
        performSwap(to: newView)
        self.currentState = state
    }
    
    private func performSwap(to newView: UIView) {
        // Update the active view reference immediately
        self.activeView = newView
        
        // If it's already the active view (e.g. resuming cached view), ensure it's visible
        if subviews.contains(newView) {
             subviews.forEach { $0.isHidden = ($0 != newView) }
             newView.isHidden = false
             newView.alpha = 1.0
             return
        }
        
        // Add and Animate
        newView.translatesAutoresizingMaskIntoConstraints = false
        newView.alpha = 0.0
        self.embed(newView) // Helper to add subview with constraints
        
        UIView.animate(withDuration: transitionDuration) {
            newView.alpha = 1.0
        } completion: { [weak self] _ in
            guard let self = self else { return }
            // Hide others instead of removing (to keep cache valid)
            // CRITICAL FIX: Only hide views that are NOT the currently active view.
            // This prevents a previous animation completion from hiding the view that just started animating.
            self.subviews.forEach {
                if $0 != self.activeView {
                    $0.isHidden = true
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func cacheKey(for state: State) -> String {
        if let provider = state as? CacheKeyProviding {
            return provider.cacheKey
        }
        // Fallback: Default string description (Safe, but might split cache by data)
        return String(describing: state)
    }
    
    private func embed(_ view: UIView) {
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
// MARK: - ViewBuilderEventHandling conforming
    open override func didMoveToWindow() {
         optionalBuilderAttributes()?.commonDidMoveToWindow(self)
    }
}
extension StateContainer: ViewBuilderEventHandling {}

// Wrapper to allow usage in Builder
public struct StateView<T: Equatable>: ModifiableView {
    public let modifiableView: StateContainer<T>
    
    public init(_ variable: Variable<T>, @ViewResultBuilder builder: @escaping (T) -> ViewConvertable) {
        self.modifiableView = StateContainer(variable, builder: builder)
    }
}
