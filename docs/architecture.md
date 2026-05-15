# Architecture

Lucid is a request-driven framework with a message-centered architecture.

Instead of centering the UI around controller actions, Lucid organizes
interactive behavior around three primitives:

- `Messages` describe intent
- `Handlers` apply effects
- `Components` render state to HTML

## The Core Flow

A typical mutation request looks like this:

1. A user action submits a `Command`.
2. A handler receives that command.
3. The handler applies business logic and publishes events.
4. Components react to those events and re-render.
5. The response returns either a full page or a targeted HTML update.

Navigation is simpler:

1. A user follows a `Link`.
2. A component handles that link directly.
3. The component updates its state.
4. Lucid renders the new UI state and URL.

## The Three Interaction Loops

Lucid makes three different kinds of interaction explicit:

### Command Loop

This is the mutation path:

- user expresses intent
- handler applies effects
- events are published
- UI updates in response

This loop is appropriate when something in the system changes.

### Navigation Loop

This is the state-transition path:

- user asks to see a different state
- a component handles a link message
- component state changes
- the URL and rendered output change

This loop is appropriate when the user is navigating or reconfiguring the view.

### Micro-feedback Loop

This is the immediate client-side acknowledgment path:

- button press states
- loading indicators
- tiny interaction feedback

Lucid does not try to model these as server round-trips. This is the place for
small client-side behavior such as Stimulus controllers.

## URL and State

Lucid treats UI state as something that can be encoded into the URL.

That matters because it means:

- components can rebuild from request state on every cycle
- browser back/forward behavior stays meaningful
- links are shareable
- navigation state does not need to hide in controllers or sessions

## Request Handling

`Lucid::App` installs a very thin routing layer:

- `GET /?*` renders state
- `GET /@/?*` applies a `Link`
- `POST /@/?*` dispatches a `Command`

`Lucid::App::Cycle` coordinates request parsing, message dispatch, component
construction, and response generation.

## HTMX and Partial Updates

Lucid works well with HTMX because the server remains the source of truth for
rendering while only the changed components are sent back.

For HTMX requests, Lucid returns component deltas and response headers such as:

- `HX-Push-Url`
- `HX-Retarget`
- `HX-Reswap`
- `HX-Redirect`

That gives you reactive server-rendered UI without moving application state
management into the browser.

## Why This Design Helps

The architecture is opinionated, but the tradeoff is deliberate:

- views do not need to know route structure
- business logic stays out of rendering code
- UI state has a concrete representation
- message types become the vocabulary of the application
- partial updates remain server-driven

For the next layer of detail, continue with [Messages](messages.md),
[Components](components.md), and [Handlers](handlers.md).
