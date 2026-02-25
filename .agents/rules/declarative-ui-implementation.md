---
trigger: model_decision
description: When generating UIKit code UI
---

---
name: "Write Construkt UI Code"
description: "Guidelines for generating declarative UIKit code using the Construkt framework (SwiftUI syntax for UIKit)."
---

# Write Construkt UI Code

You are an expert iOS developer specialized in **Construkt**, a declarative UIKit framework that uses SwiftUI-like syntax but generates native `UIView` hierarchies under the hood via Swift Result Builders.

Whenever a user asks you to build a UI component, screen, or apply styling in this project, you MUST use Construkt syntax instead of traditional imperatively-built UIKit or SwiftUI.

## Core Principles

1. **100% UIKit**: Construkt components generate native `UIView` instances. There is no `UIHostingController`.
2. **SwiftUI Syntax**: The syntax mirrors SwiftUI perfectly. Use `VStackView`, `HStackView`, `ZStackView`, `LabelView`, `ButtonView`, `ImageView`, etc.
3. **No Auto Layout**: Never write `NSLayoutConstraint` code. Layout is handled entirely by Spacers, padding, height/width modifiers, and Stack alignments.
4. **State Management**: Construkt uses reactive bindings via `@Variable` (a wrapper around `Property<T>`) and `Signal<T>`. Bind to UI using the `$` prefix (e.g., `.text(bind: $title)`).
5. **Collection Views**: Never write `UICollectionViewDataSource` or delegate boilerplate. Use `CollectionView` with `Section` builders.

---

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

---

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

---

## ⚡️ Reactive State (Binding)

Instead of manually updating UI elements when data changes, use Construkt's binding modifiers. The ViewModel exposes `@Variable`, and the View binds to `$variable`.

**ViewModel:**
```swift
class ProfileViewModel {
    @Variable var name: String = "John Doe"
    @Variable var isSaving: Bool = false
    let onSaveTapped = Signal<Void>()
}
```

**View:**
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

> **Note:** Do NOT write `.map { !$0 }` unless you are mapping a Boolean. Always import `Construkt` to ensure modifiers are available.

---

## 🗂 Lists and Collections

For lists, **always** use Construkt's declarative `CollectionView`. Never manually create Data Sources.

### 1. Dynamic Collections
When binding to an array or an Rx `@Variable` array, provide the `items:` parameter to a `Section` constructor, and yield `Cell(...)` instances.

```swift
CollectionView {
    Section(
        id: "movies_section", 
        items: viewModel.movies, // or $viewModel.movies
        header: Header { LabelView("Trending Now").font(.title1).padding(h: 16) }
    ) { movie in
        Cell(movie, id: movie.id) { movieData in
            MoviePosterCell(movie: movieData)
        }
    }
    .onSelect { movie in
        // Direct strongly-typed model access
        print("Selected \(movie)") 
    }
    .layout { environment in
        // Return NSCollectionLayoutSection
    }
}
```

### 2. Static Collections
You can build statically-defined declarative collections (e.g., Settings menus) by listing explicit `Cell` components within a `Section`:

```swift
CollectionView {
    Section(id: "settings_section", header: Header { LabelView("General") }) {
        Cell("Notifications", id: "notifications") { title in
            SettingsRowView(title: title)
        }
        Cell("Privacy", id: "privacy") { title in
            SettingsRowView(title: title)
        }
    }
    .onSelect { title in
        print("Tapped on \(title)")
    }
}
```

### 3. Skeleton Loading States
Construkt supports natively swapping an entire `Section` with skeleton placeholders during load times. Use the `.skeleton(count:when:...)` modifier directly on the Section:

```swift
Section(id: "popular", items: viewModel.popularMovies) { movie in
    Cell(movie, id: movie.id) { movie in 
        MoviePosterCell(movie: movie)
    }
}
.skeleton(count: 5, when: $viewModel.isLoading) {
    MoviePosterCell(movie: .placeholder) // Create geometry for skeleton
}
```

---

## 🏗 View Composition (Creating custom views)

When a UI becomes complex, you **MUST** extract it into separate, context-specific structs adopting `ViewBuilder`. **Never** generate a massive, single `body` with dozens of nested stacks. 

For instance, if building a user profile screen, separate it into `ProfileHeaderView`, `StatsRowView`, and `RecentActivityView`. Then assemble them inside the root view.

```swift
import UIKit
import Construkt

struct UserProfileCard: ViewBuilder {
    let user: User
    
    var body: View { // Must return Construkt's `View` type
        HStackView {
            ImageView(user.avatar)
                .size(width: 50, height: 50)
                .cornerRadius(25)
            
            VStackView {
                LabelView(user.name).font(.headline)
                LabelView(user.role).font(.subheadline).color(.secondaryLabel)
            }
            .spacing(4)
            
            SpacerView()
        }
        .padding(16)
        .backgroundColor(.secondarySystemBackground)
        .cornerRadius(12)
    }
}
```

To instantiate this into a raw UIKit `UIView`, call `.build()`:
```swift
let customView: UIView = UserProfileCard(user: currentUser).build()
```

### Component Parameterization & Reusability

If you are building a layout containing multiple identical UI blocks (e.g., a row of feature highlights, three pricing cards, or identical buttons), **you MUST** extract the structural boilerplate into a dynamically parameterized `ViewBuilder` component. Pass unique text, images, or configurations as immutable properties (`let`).

**Example: Extracting identical statistics cards**
```swift
// 1. Define the reusable parameterized struct
struct StatCard: ViewBuilder {
    let title: String
    let value: String

    var body: View {
        VStackView {
            LabelView(value).font(.title1)
            LabelView(title).font(.caption1).color(.secondaryLabel)
        }
        .padding(16)
        .backgroundColor(.secondarySystemBackground)
        .cornerRadius(12)
    }
}

// 2. Instantiate multiple times in the parent scope rather than duplicating raw views
struct DashboardStatsView: ViewBuilder {
    var body: View {
        HStackView {
            StatCard(title: "Followers", value: "1.2k")
            StatCard(title: "Following", value: "400")
            StatCard(title: "Posts", value: "32")
        }
        .spacing(12)
        .distribution(.fillEqually)
    }
}
```

---

## 7. Comprehensive View Modifiers Reference

You **must exclusively use** these native Construkt modifiers. Do not invent SwiftUI names (e.g., use `.backgroundColor` not `.background`, `.alpha` not `.opacity`, `.frame(height:width:)` not `.frame(maxWidth:)`).

### Layout & Sizing (from `Builder+Constraints`)
- `.frame(height:width:)` — set explicit dimensions (both optional)
- `.size(width:height:)` — shorthand for `.width().height()`
- `.height(CGFloat)` / `.height(CGFloat, priority:)` — constrain height
- `.height(min:)` / `.height(max:)` — min/max height constraints
- `.width(CGFloat)` / `.width(CGFloat, priority:)` — constrain width
- `.width(min:)` / `.width(max:)` — min/max width constraints
- `.contentCompressionResistancePriority(UILayoutPriority, for: .horizontal/.vertical)`
- `.contentHuggingPriority(UILayoutPriority, for: .horizontal/.vertical)`
- `.zIndex(CGFloat)` — set layer z-position

### Padding (from `Builder+Padding`, only on Paddable views: Stacks, Labels, Buttons)
- `.padding(CGFloat)` — uniform all edges
- `.padding(h:v:)` — horizontal + vertical
- `.padding(top:left:bottom:right:)` — per-edge
- `.padding(insets: UIEdgeInsets)` — raw insets

### Container Embedding (from `Builder+Attributes`)
- `.margins(CGFloat)` / `.margins(h:v:)` / `.margins(top: 12, bottom: 12)` — embed margins (parameters can be partial: `top:left:bottom:right:`)
  > ⚠️ **CRITICAL**: The modifier is `.margins` (with an 's'). NEVER use `.margin` without the 's' — it does not exist.
- `.position(.center)` / `.position(.top)` / `.position(.fill)` — embed alignment
- `.safeArea(Bool)` — respect safe area when embedded
- `.customConstraints { view in }` — raw AutoLayout access

### Appearance & Styling (from `Builder+View`)
- `.backgroundColor(UIColor)`
- `.alpha(CGFloat)`
- `.cornerRadius(CGFloat)` / `.roundedCorners(radius:corners:)`
- `.border(color:lineWidth:)`
- `.shadow(color:radius:opacity:offset:)`
- `.tintColor(UIColor)`
- `.clipsToBounds(Bool)`
- `.contentMode(UIView.ContentMode)`
- `.hidden(Bool)` / `.hidden(bind: $variable)`
- `.isOpaque(Bool)`
- `.isUserInteractionEnabled(Bool)` / `.userInteractionEnabled(bind: $variable)`

### Reactive Bindings (from `Builder+Bindings`)
- `.bind(keyPath, to: binding)` — bind any writable keypath to a reactive stream
- `.onReceive(binding) { context in }` — react to any value change
- `.hidden(when: $isHidden)` — reactively show/hide
- `.userInteractionEnabled(when: $binding)` — reactively enable/disable interaction

### Typography (LabelView modifiers)
- `.font(UIFont)` / `.font(.headline)` — set font
- `.color(UIColor)` / `.color(bind: $variable)` — set text color
- `.text(bind: $variable)` — reactively update text
- `.alignment(NSTextAlignment)` — text alignment
- `.numberOfLines(Int)` — line count
- `.lineBreakMode(NSLineBreakMode)` — truncation mode

### StackView (HStackView / VStackView)
- `.spacing(CGFloat)` / `.customSpacing(CGFloat, after: View)` — inter-item spacing
- `.alignment(UIStackView.Alignment)` — cross-axis alignment
- `.distribution(UIStackView.Distribution)` — main-axis distribution
- `.layoutMarginsRelativeArrangement(Bool)` — use layout margins

### ButtonView modifiers
- `.onTap { context in }` — handle tap
- `.font(UIFont)` / `.f