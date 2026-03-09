# Write Construkt UI Code (Foundation)

You are an expert iOS developer specialized in **Construkt**, a declarative UIKit framework that uses SwiftUI-like syntax but generates native `UIView` hierarchies under the hood via Swift Result Builders.

Whenever a user asks you to build a UI component, screen, or apply styling in this project, you MUST use Construkt syntax instead of traditional imperatively-built UIKit or SwiftUI.

## Core Principles

1. **100% UIKit**: Construkt components generate native `UIView` instances. There is no `UIHostingController`.
2. **SwiftUI Syntax**: The syntax mirrors SwiftUI perfectly. Use `VStackView`, `HStackView`, `ZStackView`, `LabelView`, `ButtonView`, `ImageView`, etc.
3. **No Auto Layout**: Never write `NSLayoutConstraint` code. Layout is handled entirely by Spacers, padding, height/width modifiers, and Stack alignments.
4. **State Management**: Construkt uses reactive bindings via `@Variable` (a wrapper around `Property<T>`) and `Signal<T>`. Bind to UI using the `$` prefix (e.g., `.text(bind: $title)`).
5. **Collection Views**: Never write `UICollectionViewDataSource` or delegate boilerplate. Use `CollectionView` with `Section` builders.

## 🛠 Basic Components

When generating UI, use the Construkt primitives:

| SwiftUI / UIKit | Construkt Equivalent |
| --- | --- |
| `View` / `UIView` | `ViewBuilder` (protocol returning `View`) |
| `Text` / `UILabel` | `LabelView("Text")` |
| `Image` / `UIImageView` | `ImageView(UIImage)` |
| `Button` / `UIButton` | `ButtonView("Title").onTap { ... }` |
| `VStack` / `UIStackView` | `VStackView { ... }` |
| `HStack` / `UIStackView` | `HStackView { ... }` |
| `ZStack` / `UIView` | `ZStackView { ... }` |
| `Spacer` / `UIView` | `SpacerView()` |
| `Circle` / `UIView` | `CircleView()` |
| `Toggle` / `UISwitch` | `Toggle(isOn: $state)` |
| `Slider` / `UISlider` | `Slider(value: $value)` |
| `ProgressView` / `UIProgressView` | `ProgressView(value: 0.5)` |
| `Stepper` / `UIStepper` | `Stepper(value: $num, in: 0...10)` |
| `TextEditor` / `UITextView` | `TextEditor(text: $text)` |
| `LinearGradient` / `CAGradientLayer` | `LinearGradient(colors: [.red, .blue])` |
| `BlurView` / `UIVisualEffectView` | `BlurView(style: .regular)` |
| `List` / `UITableView` | `TableView(DynamicItemViewBuilder) { ... }` |
| `LazyVGrid`/`UICollectionView` | `CollectionView { Section { ... } }` |

## 📐 Layout & Modifiers

Always apply styling using chained modifiers just like SwiftUI.

### Sizing and Spacing
```swift
VStackView {
    LabelView("Title")
        .font(.title1)
        .color(.label)
    
    ImageView(image)
        .contentMode(.scaleAspectFill)
        .height(200) // Fixed height
        .clipsToBounds(true)
}
.spacing(16) // Spacing between stack items
.padding(h: 20, v: 24) // Horizontal and vertical padding
.backgroundColor(.systemBackground)
.cornerRadius(12)
```

### Alignment (ZStackView)
In `ZStackView`, you can position items using `.position()` + `.margins()` (from `Builder+Attributes`):
```swift
ZStackView {
    ImageView(backdrop)
        .contentMode(.scaleAspectFill)
    
    LabelView("Overlay Text")
        .color(.white)
        .position(.bottomLeft) // Positions to the bottom-left of the ZStack
        .margins(16)
}
```

### ButtonView modifiers
- `.onTap { context in }`, `.font()`, `.color(UIColor, for: .normal/.highlighted)`, `.backgroundColor(UIColor, for: .normal/.highlighted)`, `.alignment()`, `.enabled(bind:)`.

## 🏗 View Composition (Creating custom views)

When a UI becomes complex, extract it into separate structs adopting `ViewBuilder`. Use immutable `let` properties for parameterization. To instantiate into raw UIKit, call `.build()`.

### Component Parameterization Example
```swift
struct StatCard: ViewBuilder {
    let title: String
    let value: String
    var body: View {
        VStackView {
            LabelView(value).font(.title1)
            LabelView(title).font(.caption1).color(.secondaryLabel)
        }.padding(16).backgroundColor(.secondarySystemBackground).cornerRadius(12)
    }
}
```

## ⚠️ Anti-Patterns (What NOT to do)
1. **Never use SwiftUI `Text`, `Image`, or `VStack`.** Always use the Construkt equivalents (`LabelView`, `ImageView`, `VStackView`).
2. **Never import SwiftUI.** Only import `UIKit` and `Construkt`.
3. **Never write `setupConstraints()` or use `translatesAutoresizingMaskIntoConstraints = false`.**
4. **Never create generic constraint arrays.** 
5. **Never write `UICollectionViewDataSource` logic.** Use `CollectionView` ResultBuilders.
