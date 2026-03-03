import Foundation
import UIKit

/// Wraps data to allow a clean fallback to a skeleton placeholder state.
/// This allows declarative views to switch between real data and placeholder skeletons
/// without needing massive mock objects.
public enum RenderItem<T> {
    case data(T)
    case placeholder
}

// MARK: - Array Extension for Sections

public extension Array {
    /// Converts an array of `T` to exactly `[RenderItem<T>]`
    func asRenderItems() -> [RenderItem<Element>] {
        self.map { .data($0) }
    }
}

// MARK: - View Modifiers

public extension ModifiableView {
    
    /// Applies data to a view if available, or configures it as a skeleton placeholder.
    ///
    /// - Parameters:
    ///   - item: The `RenderItem<T>` controlling this view.
    ///   - onData: A closure that configures the view with the real data `T`.
    ///   - onPlaceholder: A closure that configures the view's dummy shape/text for the skeleton.
    @discardableResult
    func render<T>(
        for item: RenderItem<T>,
        onData: (Base, T) -> Void,
        onPlaceholder: ((Base) -> Void)? = nil
    ) -> ViewModifier<Base> {
        
        switch item {
        case .data(let realData):
            onData(modifiableView, realData)
            return self.skeletonable(false)
            
        case .placeholder:
            onPlaceholder?(modifiableView)
            return self.skeletonable(true)
        }
    }
}

// MARK: - Specialized LabelView Modifier

public extension ModifiableView where Base: UILabel {
    
    /// Binds actual text if available, or a dummy string if in placeholder mode.
    ///
    /// - Parameters:
    ///   - item: The `RenderItem` driving this view.
    ///   - placeholder: The dummy text the layout engine should use to size the skeleton box.
    ///   - textMapper: Extracts the real string from the data model.
    @discardableResult
    func render<T>(
        for item: RenderItem<T>,
        placeholder: String = "Placeholder Text",
        textMapper: (T) -> String?
    ) -> ViewModifier<Base> {
        
        switch item {
        case .data(let realData):
            return ViewModifier(modifiableView, keyPath: \.text, value: textMapper(realData))
                .skeletonable(false)
            
        case .placeholder:
            return ViewModifier(modifiableView, keyPath: \.text, value: placeholder)
                .skeletonable(true)
        }
    }
}

// MARK: - Specialized ImageView Modifier

public extension ModifiableView where Base: UIImageView {
    
    /// Loads a remote image if data is available, or shows a skeleton placeholder.
    ///
    /// - Parameters:
    ///   - item: The `RenderItem` driving this view.
    ///   - placeholder: An optional placeholder image shown while loading.
    ///   - urlMapper: Extracts the remote `URL?` from the data model.
    @discardableResult
    func render<T>(
        for item: RenderItem<T>,
        placeholder: UIImage? = nil,
        urlMapper: (T) -> URL?
    ) -> ViewModifier<Base> {
        
        switch item {
        case .data(let realData):
            modifiableView.setImage(from: urlMapper(realData), placeholder: placeholder)
            return self.skeletonable(false)
            
        case .placeholder:
            modifiableView.image = placeholder
            return self.skeletonable(true)
        }
    }
}
