# Routing and channels guide
## Responder-chain routing
- `UIResponder.route(E, sender:)` is the core dispatcher.
  - It checks current responder, UIView attached receivers, view controller route handler/coordinator, then bubbles to `next`.
- Best sender pattern from views:
  - Prefer `context.view.route(event, sender: context.view)` when a modifier/gesture callback provides access to underlying UIView.

## `.onRoute`
- On `ModifiableView`: `.onRoute(event)` attaches a tap recognizer and routes the event when tapped.
- On `AnySection`: `.onRoute { model in event }` maps selected item model to an event and internally routes from selection sender.
- Mental model: `.onRoute` is convenience syntax for producing and sending events via `route`.

## `.onReceiveRoute`
- Use to receive route events bubbling from descendants in the same responder chain.
- Typical usage: between two views/screen layers in same tree (child emits `.route`, parent/container/screen handles with `.onReceiveRoute`).
- Overloads support:
  - handler with event only,
  - handler with event + sender,
  - targeted handler with weak target capture semantics.

## `RouteChannel<T>` + `.onReceiveChannel`
- Use when two view controllers are in separate presentation contexts where responder chain cannot bridge (e.g., presented sheet -> presenter).
- `RouteChannel.send(event, sender:)` broadcasts to active listeners.
- `.onReceiveChannel(channel)` subscribes a built view; listener lifetime is tied to owner via weak reference cleanup.
- Shared channel available via `RouteChannel<T>.shared` keyed by event type.
- Common bridge pattern: on channel receive, optionally re-dispatch to app router via `sender?.route(AppRoute..., sender: sender)`.

## Rule of thumb
- Same VC/same view tree: use `.route`, `.onRoute`, `.onReceiveRoute`.
- Cross-VC boundary: use `RouteChannel.send` + `.onReceiveChannel`.