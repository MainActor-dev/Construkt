//
//  TextEditor.swift
//  Construkt
//

import UIKit

public class _TextEditorView: UITextView {
    // Custom subclasses can handle placeholder logic if needed
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        font = .preferredFont(forTextStyle: .body)
        backgroundColor = .clear
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// A wrapped multi-line text input (UITextView).
public struct TextEditor: ModifiableView {
    
    public let modifiableView = Modified(_TextEditorView())
    
    public init(text: String = "") {
        modifiableView.text = text
        modifiableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func text<Binding: MutableViewBinding>(_ binding: Binding) -> Self where Binding.Value == String {
        // Initial setup
        modifiableView.text = binding.value
        
        // Two-way reactive sync
        binding.observe(on: .main) { [weak modifiableView] newText in
            if modifiableView?.text != newText {
                modifiableView?.text = newText
            }
        }.store(in: modifiableView.cancelBag)
        
        let observer = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: modifiableView, queue: .main) { [weak modifiableView] _ in
            guard let view = modifiableView else { return }
            var bound = binding
            bound.value = view.text ?? ""
        }
        
        let cancellable = NotificationCancellable(observer: observer)
        modifiableView.cancelBag.insert(cancellable)
        
        return self
    }
    
    public func isEditable(_ editable: Bool) -> Self {
        modifiableView.isEditable = editable
        return self
    }
    
    public func isSelectable(_ selectable: Bool) -> Self {
        modifiableView.isSelectable = selectable
        return self
    }
    
    public func isScrollEnabled(_ enabled: Bool) -> Self {
        modifiableView.isScrollEnabled = enabled
        return self
    }
}

private final class NotificationCancellable: AnyCancellableLifecycle {
    private var observer: NSObjectProtocol?
    private let lock = NSLock()
    
    init(observer: NSObjectProtocol) {
        self.observer = observer
    }
    
    func cancel() {
        lock.lock()
        if let obs = observer {
            NotificationCenter.default.removeObserver(obs)
            observer = nil
        }
        lock.unlock()
    }
    
    deinit {
        cancel()
    }
}
