---
trigger: model_decision
description: When implementing navigation logic between screens
---

---
name: ios-canonical-navigation
description: Define canonical navigation for a hybrid SwiftUI + UIKit app on iOS 15/16 using a Coordinator + Router pattern with typed routes, deep links, tabs, modals/sheets, state restoration, and async flow results. Use this when the user asks about coordinators, routing, deep links, push/modal/tab flows, restoration, or making SwiftUI and UIKit navigation consistent.
---

# SKILL-03 — Canonical Navigation & Coordinator Design (iOS 15/16, SwiftUI + UIKit)

This skill is based on the Coordinator + Router pattern described in “Coordinator pattern for navigation”. :contentReference[oaicite:0]{index=0}

## Goal
Establish a single source-of-truth navigation system where:
- Navigation primitives are centralized in a **Router**
- Flows are owned by **Coordinators** (optionally returning async results)
- Screens are created via a **ScreenFactory**
- Routes are **typed** and optionally **Codable** for deep links and restoration
- SwiftUI and UIKit screens are navigated uniformly via a **Presentable** abstraction :contentReference[oaicite:1]{index=1}

## When to use
Use this skill when:
- Introducing or changing navigation flows (push/pop, modal/sheet/full screen, tabs)
- Adding deep links (URL schemes/universal links) or notification routing
- Mixing SwiftUI and UIKit in the same flow
- Adding state restoration of the navigation path
- Introducing child flows (e.g., Auth) and returning results async :contentReference[oaicite:2]{index=2}

## Inputs required
If any input is missing, request it and stop.
- App/feature entry points (push/modal/tab/deep link/notification)
- iOS target (15/16) and any version-gated requirements
- Route inventory (or SKILL-01 outputs that imply routes)
- Which flows require modal vs push vs tab
- Deep link requirements (explicitly “NONE” if not needed)
- Restoration requirements (explicitly “NONE” if not needed)

## Prerequisites
- **Import "ma-ios-common"**: This library must be imported as a prerequisite before implementing any navigation logic.

## Execution steps
Follow these steps in order and produce all outputs.

### 1) Define the presentation unification layer (Presentable)
Adopt a `Presentable` abstraction so coordinators and routers can push/present either:
- `UIViewController` directly, or
- SwiftUI `View` wrapped in a hosting presentable

This enables “push SwiftUI or UIKit without caring which one it is.” :contentReference[oaicite:3]{index=3}

**Deliverable:** Presentable policy (what qualifies as Presentable, how SwiftUI is wrapped, title strategy).

---

### 2) Define Router responsibilities (navigation primitives)
Define a `Router` contract that centralizes primitives:
- setRoot
- push / pop / popToRoot
- present (sheet/fullScreen/formSheet/custom)
- dismiss
- optional “completion on pop” semantics

Router owns the `UINavigationController` and mediates top-most presentation. :contentReference[oaicite:4]{index=4}

**Deliverable:** Router contract and modal presentation rules.

---

### 3) Define Coordinator responsibilities (flows)
Define `Coordinator` responsibilities:
- Own flow state and transitions (not business logic)
- Hold child coordinators; store/free lifecycle management
- Provide `start()` for fire-and-forget flows
- Provide `FlowCoordinator.start() async -> Result` for flows that return outcomes (e.g., Auth returns signed-in/cancelled)

This is the mechanism for structured multi-step flows and async results. :contentReference[oaicite:5]{index=5}

**Deliverable:** Coordinator contract + child flow lifecycle rules + when to use FlowCoordinator.

---

### 4) Define typed routes (Codable when needed)
Define a typed route enum:
- App-wide: `AppRoute` (recommended)
- Feature-specific: `FeatureRoute` (allowed if routes are local)

If supporting deep links or restoration, routes must be `Codable` and stable across versions. :contentReference[oaicite:6]{index=6}

**Deliverable:** Route enum(s), payload rules, versioning notes.

---

### 5) Define ScreenFactory (route → screen mapping + DI)
Create a `ScreenFactory` contract responsible for:
- Translating `Route` → `Presentable`
- Centralizing dependency injection (building ViewModels/services)
- Optionally gating routes (auth/feature flags)
- Keeping coordinators thin

Decide which screens belong in the global factory vs feature-local factories:
- If globally addressable (deeplink/restoration) → include in app factory
- If internal to a flow → keep in the flow coordinator (or a flow-local factory) :contentReference[oaicite:7]{index=7}

**Deliverable:** ScreenFactory policy, DI responsibilities, “global vs local” rule.

---

### 6) Define deep link mapping (if applicable)
If deep links are required:
- Provide a `DeepLinkMapper` (URL ↔ Route)
- Deep link parsing must occur in coordinator/navigation layer (not UI)
- Define validation + fallback behavior when route cannot be resolved :contentReference[oaicite:8]{index=8}

**Deliverable:** Deep link mapping rules and failure handling.

---

### 7) Define state restoration (if applicable)
If restoration is required:
- Persist the navigation path as `[Route]` encoded
- On launch, attempt restore; otherwise start normally
- Define clearing rules (e.g., logout clears path)
- Define migration/versioning strategy for route evolution :contentReference[oaicite:9]{index=9}

**Deliverable:** Restoration strategy, persistence location, versioning/migration rules.

---

### 8) Tabs strategy (if applicable)
If using tabs:
- Each tab owns an independent navigation stack (own `UINavigationController` + Router)
- A Tab Coordinator sets up child stack coordinators
- Define cross-tab routing rules (select tab then push) :contentReference[oaicite:10]{index=10}

**Deliverable:** Tab structure rules and cross-tab routing behavior.

---

### 9) SwiftUI-first app bootstrap (optional)
If the app entry is SwiftUI but navigation is still canonical via UIKit:
- Embed the router’s `UINavigationController` in SwiftUI via a representable container
- Keep coordinator as the navigation authority :contentReference[oaicite:11]{index=11}

**Deliverable:** SwiftUI bootstrap policy and lifecycle triggers for start/restore.

---

## Outputs
Produce all of the following:

1. **Navigation architecture summary**
   - Presentable + Router + Coordinator + ScreenFactory responsibilities
2. **Route model**
   - AppRoute/FeatureRoute definitions + payload rules + Codable requirement notes
3. **Router contract**
   - primitives + modal styles + completion semantics
4. **Coordinator contract**
   - child lifecycle + FlowCoordinator result strategy
5. **ScreenFactory rules**
   - DI responsibilities + global vs flow-local screen policy
6. **Deep link plan** (or “NONE”)
   - URL mapping + validation + fallback
7. **Restoration plan** (or “NONE”)
   - path encoding, persistence, clearing rules, migrations
8. **Tabs plan** (or “NONE”)
   - independent stacks + coordination rules
9. **Testing plan**
   - Route→screen mapping tests
   - Deep link mapping tests (if applicable)
   - Restoration encode/decode tests (if applicable)
   - Coordinator flow result tests (if applicable)

## Constraints
- Do not implement UI layout, ViewModels, or business logic here.
- Do not place navigation logic inside SwiftUI Views (only emit intents if needed).
- Do not allow UIKit ViewControllers to push/present directly (must go through Router/Coordinator).
- Do not introduce iOS 16-only navigation behavior without iOS 15 fallback and explicit notes.
- Do not let the global ScreenFactory grow unbounded: apply the “globally addressable vs flow-internal” rule. :contentReference[oaicite:12]{index=12}

## Examples

### Example prompt
> Add deep link support to open Product Details, present Settings as a form sheet, and restore the last navigation path after relaunch. The Product screen is SwiftUI, Settings is UIKit. iOS 15 and 16.

### Expected output (outline)
- Presentable policy: SwiftUI wrapped as hosting presentable
- AppRoute cases (Codable): `.product(id:)`, `.settings`, etc.
- DeepLinkMapper rules for `myapp://product/<uuid>` and `myapp://settings`
- Router modal styles and top-most presentation rules
- ScreenFactory mapping routes to SwiftUI views and UIKit view controllers
- Restoration path encoding/decoding policy and clearing on logout
- Tests: deep link parsing, restoration decode, route→screen mapping :contentReference[oaicite:13]{index=13}