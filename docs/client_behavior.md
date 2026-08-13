# Client Behavior

Lucid is server-driven, but it is not anti-JavaScript.

The framework draws a boundary between durable application behavior and local
browser behavior. Lucid should own messages, state transitions, server rendering,
and partial updates. JavaScript should handle immediate interface behavior that
does not need to become a second application model.

## What Lucid Owns

Lucid is the right place for behavior that changes application state or affects
what the server should render.

That includes:

- navigation and view-state changes represented by `Link` messages
- mutations represented by `Command` messages
- domain changes represented by `Event` messages
- URL-backed UI state
- server-rendered component updates
- redirects and response effects

When behavior belongs to the application model, express it as a message and let
Lucid coordinate the request cycle.

## What JavaScript Owns

JavaScript is useful for local interaction details that should feel immediate in
the browser.

Good uses include:

- focus management
- keyboard shortcuts
- button press and loading states
- disclosure animations
- drag and drop polish
- measuring or positioning browser-only UI
- small progressive enhancements around native controls

This kind of JavaScript should stay local. It can improve the feel of an
interaction without becoming the source of truth for application state.

## HTMX

Lucid uses HTMX as the browser-side transport and swap layer.

Templates should not have to coordinate application behavior through a growing
set of HTMX attributes. Components describe messages and render HTML; Lucid
decides which parts of the component tree need to be replaced and returns the
appropriate response.

## Avoiding a Second App Model

The main risk with client-side behavior is accidentally creating a second state
model in the browser.

Avoid hiding durable UI state only in JavaScript when it should be represented
by component state, URL state, or server-derived data. If browser back and
forward behavior, shareable links, server rendering, validation, permissions, or
domain effects matter, the behavior probably belongs in Lucid.
