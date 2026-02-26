//
//  👨‍💻 Created by @thatswiftdev on 23/02/26.
//  © 2026, https://github.com/thatswiftdev. All rights reserved.
//

import UIKit

// MARK: - Compiler Decoys (Anti-Hallucination)
// This file contains intentionally unavailable methods and initializers.
// Its purpose is to catch common AI or developer "hallucinations" where SwiftUI
// syntax is mistakenly used instead of ConstruktKit syntax. By explicitly
// marking these as unavailable, the Swift compiler emits a clean, exact-line
// error message instead of failing cryptically at the parent Result Builder.

// MARK: - Spacer Hallucinations

extension SpacerView {
    @available(*, unavailable, message: "SpacerView does not accept parameters. Use FixedSpacerView(width:) or FixedSpacerView(height:) instead.")
    public init(width: CGFloat) { fatalError("Unavailable") }
    
    @available(*, unavailable, message: "SpacerView does not accept parameters. Use FixedSpacerView(height:) instead.")
    public init(height: CGFloat) { fatalError("Unavailable") }
    
    @available(*, unavailable, message: "SpacerView does not accept minLength. Use SpacerView() or FixedSpacerView().")
    public init(minLength: CGFloat) { fatalError("Unavailable") }
}

extension FixedSpacerView {
    @available(*, unavailable, message: "FixedSpacerView(w:) is ambiguous. Use FixedSpacerView(width:) instead.")
    public init(w: CGFloat) { fatalError("Unavailable") }
    
    @available(*, unavailable, message: "FixedSpacerView(h:) is ambiguous. Use FixedSpacerView(_ height: CGFloat) instead.")
    public init(h: CGFloat) { fatalError("Unavailable") }
}

// MARK: - Padding Hallucinations

extension ModifiableView {
    
    // Catch .padding(10) instead of .padding(10) (if ambiguous) or generic single padding
    // Note: If Construkt has a valid single .padding(CGFloat), we don't decoy it.
    // But we CAN decoy SwiftUI's directional padding like .padding(.vertical, 10).
    // SwiftUI uses Edge.Set. We'll simulate catching an unknown/ambiguous signature
    // by explicitly banning common SwiftUI terms if possible.
    
    @available(*, unavailable, message: "Use .padding(top:left:bottom:right:) or .padding(h:v:) instead.")
    public func padding(_ edges: Any, _ length: CGFloat) -> Self { fatalError("Unavailable") }
}

// MARK: - Styling & Shape Hallucinations

extension ModifiableView {
    
    @available(*, unavailable, message: "ConstruktKit doesn't use .clipShape(). Use .cornerRadius(_ :CGFloat).clipsToBounds(true) instead.")
    public func clipShape(_ shape: Any) -> Self { fatalError("Unavailable") }
    
    @available(*, unavailable, message: "Use .alpha(_: CGFloat) instead of .opacity().")
    public func opacity(_ opacity: Double) -> Self { fatalError("Unavailable") }
    
    @available(*, unavailable, message: "Use .backgroundColor(_: UIColor) instead of .background().")
    public func background(_ color: Any) -> Self { fatalError("Unavailable") }
    
    @available(*, unavailable, message: "Use .border(color: UIColor, lineWidth: CGFloat) instead of .stroke().")
    public func stroke(_ color: Any, lineWidth: CGFloat = 1) -> Self { fatalError("Unavailable") }
    
    @available(*, unavailable, message: "Use .border(color: UIColor, lineWidth: CGFloat) instead of .border(color:width:).")
    public func border(color: UIColor, width: CGFloat) -> Self { fatalError("Unavailable") }
}

// MARK: - Frame & Layout Hallucinations

extension ModifiableView {
    @available(*, unavailable, message: "Modifiers like .frame(maxWidth:) do not exist in Construkt. Use .width(max:) or .position(.fill).")
    public func frame(maxWidth: CGFloat = .infinity, maxHeight: CGFloat = .infinity) -> Self { fatalError("Unavailable") }
    
    @available(*, unavailable, message: "Use .alignment(...) and .distribution(...) on Stacks, not .frame(alignment:).")
    public func frame(alignment: Any) -> Self { fatalError("Unavailable") }
}

// MARK: - Text / Label Hallucinations
// Since `Text` is SwiftUI, AI might try `.foregroundColor()`. We use `.color()`.

extension ModifiableView {
    @available(*, unavailable, message: "Use .color(_: UIColor) on LabelView instead of .foregroundColor().")
    public func foregroundColor(_ color: Any) -> Self { fatalError("Unavailable") }
    
    @available(*, unavailable, message: "Use .color(_: UIColor) or .tintColor(_: UIColor) instead of .foregroundStyle().")
    public func foregroundStyle(_ style: Any) -> Self { fatalError("Unavailable") }
}

// MARK: - Image Hallucinations
// SwiftUI uses Image(systemName:). Construkt uses ImageView(UIImage(systemName:)!)

public struct Image {
    @available(*, unavailable, message: "Do not use SwiftUI `Image`. Use `ImageView(UIImage(systemName:)!)` instead.")
    public init(systemName: String) { fatalError("Unavailable") }
    
    @available(*, unavailable, message: "Do not use SwiftUI `Image`. Use `ImageView` instead.")
    public init(_ name: String) { fatalError("Unavailable") }
}

public struct Text {
    @available(*, unavailable, message: "Do not use SwiftUI `Text`. Use `LabelView(\"String\")` instead.")
    public init(_ text: String) { fatalError("Unavailable") }
}

public struct Spacer {
    @available(*, unavailable, message: "Do not use SwiftUI `Spacer`. Use `SpacerView()` instead.")
    public init(minLength: CGFloat? = nil) { fatalError("Unavailable") }
}
