# Construkt: A Declarative UIKit Framework

## Table of Contents
- [Overview](#overview)
  - [Why Construkt?](#why-construkt)
- [Installation](#installation)
  - [Agentic Coding with Construkt](#agentic-coding-with-construkt)
- [Views and Composition](#views-and-composition)
  - [Custom Components](#custom-components)
- [State Management & Reactive Data Flow](#state-management--reactive-data-flow)
  - [The Reactive Primitives](#the-reactive-primitives)
  - [Binding to Views](#binding-to-views)
  - [Native Operators](#native-operators)
  - [Combine & RxSwift Integration](#combine--rxswift-integration)
  - [Included UI Components](#included-ui-components)
- [Modern Collection and Table Views](#modern-collection-and-table-views)
  - [Table Views](#table-views)
  - [Dynamic Collection Views](#dynamic-collection-views)
  - [Static Collection Views](#static-collection-views)
  - [Skeleton Loading States](#skeleton-loading-states)
- [Advanced View Structure](#advanced-view-structure)
- [Author](#author)
- [License](#license)

## Overview

Construkt lets you build UIKit-based user interfaces using a modern, declarative syntax identical to **SwiftUI**. 

It brings the joy of declarative composition and reactive data flow to legacy UIKit projects, making it possible to build dynamic, state-driven interfaces without Storyboards, NIBs, or Auto Layout boilerplate.

```swift
LabelView($title)
    .color(.red)
    .font(.title1)
```

By leveraging Swift's `ResultBuilder` pattern, Construkt composes native `UIView` hierarchies under the hood. You get the concise, readable syntax of SwiftUI while retaining the full power, predictability, and infinite customizability of UIKit.

### Why Construkt?

While SwiftUI is the future, many modern apps still maintain extensive UIKit codebases. Integrating SwiftUI via `UIHostingController` can be heavy and sometimes rigid. 

**Construkt solves this by being 100% UIKit.**

- **Native Reactive Core:** Construkt brings its own lightweight reactive primitives (`Property` and `Signal`) built natively with async/await and GCD. No external RxSwift or Combine dependencies required, though integration bridges are provided.
- **Zero Auto Layout Boilerplate:** Stacks (`VStackView`, `HStackView`, `ZStackView`) handle all the constraint logic for you natively.
- **Modern CollectionViews:** Build fully asynchronous `UICollectionView` and `UITableView` layouts using native Swift Diffable Data Sources with a few lines of code.

---

## Installation

Construkt is distributed as a Swift Package and requires **Xcode 16+** and **Swift 6** (with backwards compatibility for Swift 5.9 language modes).

**Minimum SDK Requirements:**
- iOS 14.0+

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/MainActor-dev/Construkt.git", from: "1.0.0")
]
```

### Agentic Coding with Construkt

If you are using AI coding assistants (like Antigravity, Cursor, Windsurf, or GitHub Copilot), you can use the provided `SKILL.md` file to help your agent write high-quality Construkt code.

Simply inform your agent to read the `SKILL.md` file at the root of the repository. This file contains comprehensive guidelines, component references, and best practices for writing declarative UIKit with Construkt.


---

## Views and Composition

In Construkt, screens are composed of views inside views using familiar structuring. 

```swift
struct DetailCardView: ViewBuilder {    

    let user: User

    var body: View {
        StandardCardView {
            VStackView {
                LabeledPhotoView(photo: user.$photo, name: user.name)
                    .height(250)
                
                VStackView {
                    NameValueView(name: "Email", value: user.email)
                    NameValueView(name: "Phone", value: user.phone)
                    SpacerView()
                    ButtonView("Contact")
                        .onTap { _ in print("Tapped") }
                }
                .spacing(8)
                .padding(20)
            }
        }
    }
}
```

### Custom Components

Creating reusable components is as simple as defining a struct that conforms to `ViewBuilder`.

```swift
struct UserProfileView: ViewBuilder {
    let name: String
    
    var body: View {
        HStackView {
            ImageView(UIImage(systemName: "person.circle"))
                .size(width: 40, height: 40)
            
            VStackView {
                LabelView(name).font(.headline)
                LabelView("Online").font(.subheadline).color(.systemGreen)
            }
        }
        .spacing(12)
        .padding(16)
    }
}
```


Any Construkt `ViewBuilder` protocol conformance generates an underlying set of standard `UIView` elements by simply calling `.build()`.

```swift
let view: UIView = DetailCardView(user: user).build()
```

This structural approach encourages creating small, testable, highly-reusable interface components exactly like SwiftUI.

---

## State Management & Reactive Data Flow

Construkt does not diff and reconstruct the entire view tree on every state change like SwiftUI. Instead, it relies on explicit, highly-efficient **Reactive Bindings**.

### The Reactive Primitives

Construkt introduces two core primitives:
1. `Property<T>` — A state container that holds a value and emits updates on change (like `@Published` or `BehaviorRelay`).
2. `Signal<T>` — A transient event emitter that broadcasts values to subscribers without holding state (like `PublishRelay`).

```swift
class ProfileViewModel {
    @Variable var name: String = "John Doe" // Uses Property<String> under the hood
    let onProfileUpdated = Signal<Void>()

    func refresh() {
        name = "Jane Doe"
        onProfileUpdated.send()
    }
}
```

### Binding to Views

Construkt provides an extensive set of View Modifiers specifically designed for data binding. Use the `$` prefix to access the reactive projection of a Variable.

```swift
LabelView($viewModel.name) // Automatically updates the label when the name changes
    .font(.body)

ButtonView("Save")
    .hidden(bind: $viewModel.isSaving)

ActivityIndicator()
    .hidden(bind: $viewModel.isLoading.map { !$0 }) // Supports operators like map, filter, etc.
```

If you need a completely custom binding, use `onReceive`:

```swift
ImageView()
    .onReceive($viewModel.profileImage) { context in
        context.view.image = context.value
    }
```

> **Memory Management:** Cancellables strings are handled for you. Construkt injects a hidden `CancelBag` directly into instantiated UIViews. When a UIView deallocates, any reactive observation modifying that view is automatically torn down.

### Native Operators

Construkt's native binding system includes a rich suite of built-in operators so you don't need external reactive frameworks for everyday logic:
- `.map`, `.compactMap`
- `.filter`, `.skip`
- `.debounce(for:on:)`, `.throttle(for:latest:on:)`
- `.merge(with:)`, `.combineLatest(_:_:)`
- `.distinctUntilChanged()`, `.removeDuplicates(by:)`
- `.scan(_:_:)`

### Combine & RxSwift Integration

If your app already uses `Combine` or `RxSwift`, Construkt is fully agnostic. Simply import the corresponding bridging files:

```swift
import Construkt
import Combine // Import bridging extensions

let publisher = CurrentValueSubject<String, Never>("Combine Data")

LabelView(publisher) // Construkt treats Combine Publishers as native ViewBindings
```

### Included UI Components

Construkt provides declarative wrappers for most standard UIKit components:
- **Text & Controls:** `LabelView`, `ButtonView`, `TextField`, `TextEditor`, `Toggle`, `Slider`, `Stepper`
- **Layout & Spacing:** `VStackView`, `HStackView`, `ZStackView`, `SpacerView`, `DividerView`
- **Visual & Indicators:** `ImageView`, `BlurView`, `LinearGradient`, `ProgressView`, `ActivityIndicator`, `CircleView`

---

## Modern Collection and Table Views

Building lists in UIKit traditionally requires massive boilerplates, DTO mappings, and manual `reloadData()` calls. Construkt abstracts this all away.

### Table Views

`TableView` accepts a `DynamicItemViewBuilder` to declaratively map data to cells — no delegates, no data sources.

```swift
struct MainUsersTableView: ViewBuilder {
    
    let users: [User]
    
    var body: View {
        TableView(DynamicItemViewBuilder(users) { user in
            TableViewCell {
                MainCardView(user: user)
            }
            .accessoryType(.disclosureIndicator)
            .onSelect { context in
                context.push(DetailViewController(user: user))
                return false
            }
        })
    }
}
```

### Dynamic Collection Views

`CollectionView` leverages **DiffableDataSources** and supports multi-section layouts with headers, footers, and orthogonal scrolling — all via a `Section`-based `ResultBuilder` syntax.

```swift
CollectionView {
    Section(id: "trending", items: movies, header: Header { LabelView("Trending Now").font(.title1) }) { movie in
        Cell(movie, id: movie.id) { movieData in
            MoviePosterCell(movie: movieData)
        }
    }
    .layout(.horizontalOrthogonal(
        width: .fractionalWidth(0.8), 
        height: .fractionalHeight(1.0)
    ))
}
```

### Static Collection Views

You can also build statically-defined declarative collections (e.g., Settings menus) by listing explicit `Cell` components within a `Section`:

```swift
CollectionView {
    Section(id: "settings", header: Header { LabelView("General") }) {
        Cell("Notifications", id: "notifications") { title in
            SettingsRowView(title: title)
        }
        Cell("Privacy", id: "privacy") { title in
            SettingsRowView(title: title)
        }
    }
}
```

### Skeleton Loading States
Building sophisticated loading UIs is built-in natively:

```swift
Section(id: "popular", items: movies) { movie in
    Cell(movie, id: movie.id) { movieData in 
        MoviePosterCell(movie: movieData) 
    }
}
.skeleton(count: 5, when: $viewModel.isLoading) {
    MoviePosterCell(movie: .placeholder)
}
```

When `isLoading` is true, Construkt automatically generates 5 skeleton placeholder geometries based on your ViewBuilder structure and animates a shimmer gradient across them. When the data loads, it cross-dissolves them back to your actual fetched data natively.

---

## Advanced View Structure

While stacks are primary, Construkt exposes powerful layout control through direct anchors, offsets, and geometry modifiers.

```swift
ZStackView {
    ImageView(backdropImage)
        .contentMode(.scaleAspectFill)
    
    // Auto-calculating overlay gradients
    LinearGradient(colors: [.black.withAlphaComponent(0), .black])
    
    LabelView("Featured Content")
        .color(.white)
        .position(.bottomLeft)
        .margins(h: 20, v: 20)
}
.height(300)
.clipsToBounds(true)
```

Unlike SwiftUI, you don’t have to fight the layout system. A `ViewBuilder` is just generating traditional `UIView` nodes. You can access the UIKit primitives at any point using `with`:

```swift
LabelView("Direct UIKit Access")
    .with { label in
        // 'label' is guaranteed to be a UILabel
        label.shadowColor = .lightGray
        label.shadowOffset = CGSize(width: 1, height: 1)
    }
```

---

## Author

Construkt was originally created by **Michael Long**, a Lead iOS Software Engineer and a Top 1,000 Technology Writer on Medium.
- LinkedIn: [@hmlong](https://www.linkedin.com/in/hmlong/)
- Medium: [@michaellong](https://medium.com/@michaellong)

Continued and maintained by **Bayu Kurniawan**.
- GitHub: [@MainActor-dev](https://github.com/MainActor-dev)

---

## License

Construkt is available under the MIT license. See the LICENSE file for more info.
