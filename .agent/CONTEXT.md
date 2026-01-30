# Project Context: Construkt (Builder)

## 🎯 Overview
Construkt is a declarative UIKit library that allows building iOS interfaces using a syntax similar to SwiftUI but powered by UIKit and RxSwift.

## 🏗 Architecture & Tech Stack
- **Core Engine**: Located in `Sources/Construkt/Core/Builder/`.
- **Declarative DSL**: Uses `ViewBuilder` protocols and `@resultBuilder` (`ViewResultBuilder`).
- **Reactive State**: Powered by **RxSwift**. Custom `@Variable` property wrapper mimics SwiftUI's `@State`.
- **Dependency Injection**: Uses the **Factory** library.
- **Composition**: Heavy use of `VStackView`, `HStackView`, and small reusable `ViewBuilder` structs.

## � Examples
- **BuilderDemo**: Comprehensive examples of complex UIs, navigation, and state management using the declarative syntax can be found in `Demo/BuilderDemo/`. Use these as a reference for best practices and available components.
- **Construkt App**: The main application in `Demo/Construkt/` serves as a growing repository of clean examples (e.g., `RootViewController.swift`). Use this to see how the library is being integrated into a fresh project with modern UIKit patterns.

## �🛠 Recent Decisions & State
- **Folder Structure**: The `BuilderDemo` source has been **unattached** from the main Xcode project to keep the core library clean. It now lives in `Demo/BuilderDemo/` (outside the synchronized `Construkt` group).
- **Build Configuration**: Fixed a duplicate output error in `Construkt.xcodeproj` by adding `Info.plist` to the `membershipExceptions` in the `.pbxproj` file.
- **Workflows**: Project-specific automation is documented in `.agent/workflows/`.

## � Development Environment
- **Simulator**: Always use the **iPhone 16** simulator for building and testing to ensure consistency in layout and performance verification.

## �📝 Coding Standards
- **UI Initialization**: Use the `Modified()` helper function for setting up `UIView` instances.
- **Reactive UI**: Bind UI properties to observables using specialized modifiers (e.g., `.text(bind: $variable)`).
- **Lifecycle**: Rely on the library's internal `DisposeBag` management for UI-bound subscriptions.

---
*Last Updated: 2026-01-30*
