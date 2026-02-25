# Write Construkt UI Code (Reactive & Lists)

This rule covers reactive state, collections, and the comprehensive modifier reference for Construkt.

## ⚡️ Reactive State (Binding)

Instead of manually updating UI elements when data changes, use Construkt's binding modifiers. The ViewModel exposes `@Variable`, and the View binds to `$variable`.

**View Example:**
```swift
VStackView {
    LabelView($viewModel.name) // Automatically updates when `name` changes
        .font(.body)

    ButtonView("Save")
        .hidden(bind: $viewModel.isSaving) // Hides when saving is true
        .onTap { [weak viewModel] _ in
            viewModel?.onSaveTapped.send()
        }
    
    ActivityIndicator()
        .hidden(bind: $viewModel.isSaving.map { !$0 }) // Inverse mapping
}
```

> **Note:** Do NOT write `.map { !$0 }` unless you are mapping a Boolean. Always import `Construkt` to ensure modifiers are available. Memory management is handled via a hidden `CancelBag` in UIViews.

## 🗂 Lists and Collections

For lists, **always** use Construkt's declarative `CollectionView`. Never manually create Data Sources.

### 1. Dynamic Collections
When binding to an array, provide the `items:` parameter to a `Section` constructor, and yield `Cell(...)` instances.

### 2. Static Collections
Build statically-defined declarative collections (e.g., Settings menus) by listing explicit `Cell` components within a `Section`.

### 3. Skeleton Loading States
Use the `.skeleton(count:when:...)` modifier directly on the Section to swap content with animated shimmer placeholders.

## 📐 Comprehensive View Modifiers Reference

You **must exclusively use** these native Construkt modifiers.

### Layout & Sizing
- `.frame(height:width:)`, `.size(width:height:)`, `.height(CGFloat)`, `.width(CGFloat)`, `.zIndex(CGFloat)`.
- `.contentCompressionResistancePriority(priority, for: .horizontal/.vertical)`
- `.contentHuggingPriority(priority, for: .horizontal/.vertical)`

### Padding (Stacks, Labels, Buttons)
- `.padding(CGFloat)`, `.padding(h:v:)`, `.padding(top:left:bottom:right:)`.

### Container Embedding
- `.margins(CGFloat)` (⚠️ **CRITICAL**: Use `.margins` with an 's'), `.position(.center/.top/.fill etc)`, `.safeArea(Bool)`.

### Appearance & Styling
- `.backgroundColor(UIColor)`, `.alpha(CGFloat)`, `.cornerRadius(CGFloat)`, `.border(color:lineWidth:)`, `.shadow()`, `.tintColor()`, `.clipsToBounds()`, `.contentMode()`, `.hidden(bind:)`.

### Reactive Bindings & Bridging
- `.bind(keyPath, to: binding)`, `.onReceive(binding)`, `.hidden(when:)`.
- **Combine/RxSwift:** Construkt is agnostic. Import `Combine` or `RxSwift` to treat `Publishers` or `Observables` as native `ViewBindings`.

### Typography & ImageView
- **LabelView:** `.font()`, `.color()`, `.text(bind:)`, `.alignment()`, `.numberOfLines()`, `.lineBreakMode()`.
- **ImageView:** `.tintColor()`, `.image(bind:)`.

### SwitchView & Gestures
- `.isOn(bind:)`, `.onTintColor()`, `.onChange()`.
- `.onTapGesture()`, `.onSwipeRight/Left()`, `.hideKeyboardOnBackgroundTap()`.

### Lifecycle & Utilities
- `.onAppear()`, `.onAppearOnce()`, `.onDisappear()`.
- **Utilities:** `SpacerView()`, `FixedSpacerView(8)`, `DividerView()`, `ForEach(array) { ... }`, `ForEach(count) { ... }`.

## 8. Advanced Capabilities

### Navigation and Routing
Use the `context` proxy to the current `UIView` to access navigation.
```swift
.onTap { context in
    context.push(DetailView(item: item)) 
    context.present(CustomViewController())
}
```

### Scroll Views and Forms
- `VerticalScrollView(safeArea: true) { ... }.automaticallyAdjustForKeyboard()`
- `TextField(bidirectionalBind: $viewModel.username)`
