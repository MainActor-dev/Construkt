//
//  WalkthroughOverlay.swift
//  Construkt
//
//  A spotlight-style walkthrough/coach marks overlay for Construkt apps.
//  Renders a dimmed full-screen overlay with a cutout hole highlighting a target view,
//  plus a tooltip with description text and navigation controls.
//

import UIKit
import ConstruktKit


// MARK: - WalkthroughStep

/// The target to highlight in a walkthrough step.
enum WalkthroughTarget {
    /// Highlights a specific UIView by its accessibilityIdentifier.
    case view(id: String)
    /// Highlights an entire section (header + items + footer) in a UICollectionView.
    case collectionViewSection(collectionView: UICollectionView, sectionIndex: Int)
}

/// A single step in the walkthrough sequence.
struct WalkthroughStep {
    /// The target to highlight.
    let target: WalkthroughTarget
    /// The title displayed in the tooltip.
    let title: String
    /// The description text displayed in the tooltip.
    let description: String
    /// Where the tooltip appears relative to the spotlight cutout.
    let tooltipPosition: TooltipPosition
    /// Padding around the cutout spotlight.
    let spotlightPadding: CGFloat
    /// An optional async closure executed before the step is shown (e.g. to scroll to the target).
    let prepare: (() async -> Void)?
    
    enum TooltipPosition {
        case above
        case below
    }
    
    init(
        target: WalkthroughTarget,
        title: String,
        description: String,
        tooltipPosition: TooltipPosition = .below,
        spotlightPadding: CGFloat = 8,
        prepare: (() async -> Void)? = nil
    ) {
        self.target = target
        self.title = title
        self.description = description
        self.tooltipPosition = tooltipPosition
        self.spotlightPadding = spotlightPadding
        self.prepare = prepare
    }
}


// MARK: - WalkthroughOverlayView

/// A full-screen overlay that highlights views one at a time with a spotlight cutout effect.
///
/// Uses a CAShapeLayer mask to "cut out" the target rect from a semi-transparent dimmed background.
/// Automatically finds target views by accessibility identifier and animates between steps.
final class WalkthroughOverlayView: UIView {
    
    // MARK: Properties
    
    private(set) var steps: [WalkthroughStep]
    private var currentStepIndex: Int = 0
    private var onDismiss: (() -> Void)?
    
    // Layers
    private let dimmingLayer = CAShapeLayer()
    
    // Subviews
    private let tooltipContainer = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let stepCountLabel = UILabel()
    private let skipButton = UIButton(type: .system)
    
    // Constraints for tooltip positioning
    private var tooltipTopConstraint: NSLayoutConstraint?
    private var tooltipCenterXConstraint: NSLayoutConstraint?
    
    // MARK: Init
    
    init(steps: [WalkthroughStep], onDismiss: (() -> Void)? = nil) {
        self.steps = steps
        self.onDismiss = onDismiss
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public API
    
    /// Replace the steps and restart the walkthrough from step 0.
    func setSteps(_ newSteps: [WalkthroughStep]) {
        self.steps = newSteps
        self.currentStepIndex = 0
    }
    
    /// Kick off (or restart) the walkthrough from the first step.
    func start() {
        guard !steps.isEmpty else { return }
        currentStepIndex = 0
        isHidden = false
        showCurrentStep(animated: false)
    }
    
    // MARK: Setup
    
    private func setupViews() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        // Dimming layer
        dimmingLayer.fillRule = .evenOdd
        dimmingLayer.fillColor = UIColor.black.withAlphaComponent(0.75).cgColor
        layer.addSublayer(dimmingLayer)
        
        // Tooltip container
        tooltipContainer.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        tooltipContainer.layer.cornerRadius = 16
        tooltipContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        tooltipContainer.layer.borderWidth = 1
        tooltipContainer.layer.shadowColor = UIColor.black.cgColor
        tooltipContainer.layer.shadowRadius = 20
        tooltipContainer.layer.shadowOpacity = 0.5
        tooltipContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        tooltipContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tooltipContainer)
        
        // Title label
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tooltipContainer.addSubview(titleLabel)
        
        // Description label
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = UIColor(white: 0.7, alpha: 1.0)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        tooltipContainer.addSubview(descriptionLabel)
        
        // Step count label
        stepCountLabel.font = .systemFont(ofSize: 12, weight: .medium)
        stepCountLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
        stepCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tooltipContainer.addSubview(stepCountLabel)
        
        // Action button (Next / Done)
        actionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        actionButton.setTitleColor(.black, for: .normal)
        actionButton.backgroundColor = .white
        actionButton.layer.cornerRadius = 20
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        tooltipContainer.addSubview(actionButton)
        
        // Skip button
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        skipButton.setTitleColor(UIColor(white: 0.5, alpha: 1.0), for: .normal)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        addSubview(skipButton)
        
        // Layout — tooltip
        let topConstraint = tooltipContainer.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        self.tooltipTopConstraint = topConstraint
        
        NSLayoutConstraint.activate([
            tooltipContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tooltipContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            topConstraint,
            
            titleLabel.topAnchor.constraint(equalTo: tooltipContainer.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: tooltipContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: tooltipContainer.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: tooltipContainer.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: tooltipContainer.trailingAnchor, constant: -20),
            
            stepCountLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            stepCountLabel.leadingAnchor.constraint(equalTo: tooltipContainer.leadingAnchor, constant: 20),
            stepCountLabel.bottomAnchor.constraint(equalTo: tooltipContainer.bottomAnchor, constant: -20),
            
            actionButton.centerYAnchor.constraint(equalTo: stepCountLabel.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: tooltipContainer.trailingAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 40),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            // Skip button — top right corner
            skipButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            skipButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
        
        // Add content insets to action button
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    // MARK: Lifecycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        
        // Start invisible, fade in
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
        
        // Delay showing the first step to allow layout to settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showCurrentStep(animated: false)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dimmingLayer.frame = bounds
        
        // Re-render spotlight if we're already showing a step
        if !steps.isEmpty && currentStepIndex < steps.count {
            updateSpotlight(for: steps[currentStepIndex], animated: false)
        }
    }

    // MARK: Step Display
    
    private func showCurrentStep(animated: Bool) {
        guard currentStepIndex < steps.count else {
            dismiss()
            return
        }
        
        let step = steps[currentStepIndex]
        
        // Update tooltip content
        titleLabel.text = step.title
        descriptionLabel.text = step.description
        stepCountLabel.text = "\(currentStepIndex + 1) of \(steps.count)"
        
        let isLast = currentStepIndex == steps.count - 1
        actionButton.setTitle(isLast ? "Done" : "Next", for: .normal)
        skipButton.isHidden = isLast
        
        // Disable interactions while preparing
        isUserInteractionEnabled = false
        
        Task {
            // Execute the preparation block (e.g. scrolling)
            if let prepare = step.prepare {
                await prepare()
                
                // Allow UI to settle after scroll
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
            
            // Re-enable interactions and update spotlight
            await MainActor.run {
                self.isUserInteractionEnabled = true
                self.updateSpotlight(for: step, animated: animated)
            }
        }
    }
    
    private func updateSpotlight(for step: WalkthroughStep, animated: Bool) {
        // Resolve the target frame based on the target type
        guard let targetFrame = resolveFrame(for: step.target) else {
            // Target not found — show a full-screen dim with centered tooltip
            updateDimmingPath(cutoutRect: nil, cornerRadius: 0, animated: animated)
            tooltipTopConstraint?.constant = bounds.midY - 80
            return
        }
        
        let padding = step.spotlightPadding
        let spotlightRect = targetFrame.insetBy(dx: -padding, dy: -padding)
        let cornerRadius: CGFloat = 12
        
        updateDimmingPath(cutoutRect: spotlightRect, cornerRadius: cornerRadius, animated: animated)
        
        // Position tooltip above or below the spotlight
        let tooltipSpacing: CGFloat = 16
        let tooltipHeight: CGFloat = 150 // estimated
        
        switch step.tooltipPosition {
        case .below:
            tooltipTopConstraint?.constant = spotlightRect.maxY + tooltipSpacing
        case .above:
            tooltipTopConstraint?.constant = spotlightRect.minY - tooltipHeight - tooltipSpacing
        }
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.layoutIfNeeded()
            }
        }
    }
    
    private func updateDimmingPath(cutoutRect: CGRect?, cornerRadius: CGFloat, animated: Bool) {
        let fullPath = UIBezierPath(rect: bounds)
        
        if let cutout = cutoutRect {
            let cutoutPath = UIBezierPath(roundedRect: cutout, cornerRadius: cornerRadius)
            fullPath.append(cutoutPath)
        }
        
        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = dimmingLayer.path
            animation.toValue = fullPath.cgPath
            animation.duration = 0.35
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            dimmingLayer.add(animation, forKey: "path")
        }
        
        dimmingLayer.path = fullPath.cgPath
    }
    
    // MARK: Target Resolution
    
    private func resolveFrame(for target: WalkthroughTarget) -> CGRect? {
        guard let window = self.window else { return nil }
        
        switch target {
        case .view(let id):
            guard let targetView = window.firstSubview(where: { $0.accessibilityIdentifier == id }) else { return nil }
            return targetView.convert(targetView.bounds, to: self)
            
        case .collectionViewSection(let collectionView, let sectionIndex):
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewCompositionalLayout else { return nil }
            
            var boundingBox: CGRect?
            
            // 1. Add Header (if exists)
            if let headerAttrs = layout.layoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                at: IndexPath(item: 0, section: sectionIndex)
            ) {
                boundingBox = headerAttrs.frame
            }
            
            // 2. Add all Items
            let itemCount = collectionView.numberOfItems(inSection: sectionIndex)
            for item in 0..<itemCount {
                if let attr = layout.layoutAttributesForItem(at: IndexPath(item: item, section: sectionIndex)) {
                    boundingBox = boundingBox?.union(attr.frame) ?? attr.frame
                }
            }
            
            // 3. Add Footer (if exists)
            if let footerAttrs = layout.layoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                at: IndexPath(item: 0, section: sectionIndex)
            ) {
                boundingBox = boundingBox?.union(footerAttrs.frame) ?? footerAttrs.frame
            }
            
            guard let localFrame = boundingBox else { return nil }
            return collectionView.convert(localFrame, to: self)
        }
    }
    
    // MARK: Actions
    
    @objc private func nextTapped() {
        currentStepIndex += 1
        
        if currentStepIndex >= steps.count {
            dismiss()
        } else {
            showCurrentStep(animated: true)
        }
    }
    
    @objc private func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            self.onDismiss?()
        }
    }
    
    // MARK: Touch Handling
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Allow touches on the action button and skip button
        let buttonHit = actionButton.hitTest(convert(point, to: actionButton), with: event)
        if buttonHit != nil { return buttonHit }
        
        let skipHit = skipButton.hitTest(convert(point, to: skipButton), with: event)
        if skipHit != nil { return skipHit }
        
        // Consume all other touches (block interaction with views behind)
        return self
    }
}


// MARK: - Construkt Integration

/// A Construkt-compatible wrapper for the walkthrough overlay.
struct WalkthroughOverlay: ModifiableView {
    
    let modifiableView: WalkthroughOverlayView
    
    /// Creates a walkthrough overlay with the given steps.
    ///
    /// - Parameters:
    ///   - steps: The ordered walkthrough steps to display.
    ///   - onDismiss: Called when the walkthrough is dismissed (completed or skipped).
    init(steps: [WalkthroughStep], onDismiss: (() -> Void)? = nil) {
        let view = WalkthroughOverlayView(steps: steps, onDismiss: onDismiss)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.modifiableView = view
    }
    
    /// Creates a walkthrough overlay that starts hidden. 
    /// Use `.with { }` to call `setSteps(_:)` and `start()` when ready.
    init(onDismiss: (() -> Void)? = nil) {
        let view = WalkthroughOverlayView(steps: [], onDismiss: onDismiss)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        self.modifiableView = view
    }
}

// MARK: - Extensions

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}
