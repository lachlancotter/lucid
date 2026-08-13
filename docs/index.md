# Lucid Documentation

Lucid is a Ruby framework for building reactive, hypermedia applications with a
message-driven architecture.

## How Lucid is different

In a typical MVC framework like Rails, an interaction usually starts with a
route, moves through a controller action, and renders a view. That is a familiar
shape, but rich interfaces can make the layers feel tightly coupled: templates
need route helpers, controllers collect rendering decisions, and UI state often
gets split across params, sessions, and client-side code.

As the interface becomes more stateful, developers usually face an uncomfortable
choice. They can keep state coordination on the server, where controllers become
the central place that knows too much about view structure and user flow. Or
they can move state coordination into the browser, where the application gains a
thicker front end, a separate state model, and more client-side tooling.

Lucid starts from intent instead of endpoints. User interactions are represented
as typed messages, so views describe what should happen without knowing which
route or controller shape will serve it. Components own view state transitions,
handlers own business effects, and the request cycle decides what HTML needs to
be replaced.

That gives Lucid apps a SPA-like feel while staying loosely coupled, reactive,
and server-driven. You can update precise parts of the page without introducing
a front-end build pipeline, client-side application state, or the imperative
state management that often appears in HTMX-heavy views.

## Design goals

Lucid is designed to make rich server-rendered interfaces direct to build and
easy to change.

- Keep view code semantic. Components describe application behavior through
  messages, state, props, and data flow rather than route helpers, DOM IDs,
  JavaScript hooks, or client-side wiring.
- Make UX refactoring local. Changing a workflow should not require coordinated
  edits across routes, controllers, templates, and browser-side state.
- Let the server coordinate interaction. Lucid follows component data flow and
  state changes to decide which parts of the page update, so rich UIs can scale
  without manually maintaining swap targets.
- Preserve hypermedia foundations. Lucid enhances plain links and forms into
  SPA-like interactions without abandoning HTTP semantics or requiring a
  front-end toolchain, so applications degrade gracefully without JavaScript.

## Core model

Lucid has three core primitives. Messages name intent, handlers apply effects,
and components render state back to HTML.

Messages:

- Value objects that describe intent. Links represent navigation, commands
  represent mutations, and events represent things that happened in the system.

Handlers:

- Objects that apply business effects for commands: loading data, enforcing
  policies, writing records, publishing events, and registering redirects.

Components:

- Ruby objects that hold typed state, compose subcomponents, react to messages
  or events, and render HTML.

## Request flow

1. A user action submits a link or command message over HTTP.
2. Lucid decodes the HTTP request into a typed message object.
3. `Link` messages are sent with `GET` and dispatched through the component tree.
4. `Command` messages are sent with `POST` and dispatched to the message bus.
5. Handlers process command messages and publish events.
6. Components can react to link messages or published events and update their
   state.
7. The component tree renders a full page or targeted HTML update.

## Quickstart

From a checkout of this repository, run the included example app:

```sh
bundle install
bundle exec ruby examples/hello_world/app.rb
```

Then open `http://localhost:4567`.

This repository quickstart requires Ruby `3.2.8` and Bundler. The example app
does not require a database or external services.

For the full walkthrough, continue to [Hello World](hello.md).

## Next steps

Start here:

- [Why Lucid?](why.md): Understand the problems Lucid is designed to solve.
- [Hello World](hello.md): Build the smallest useful Lucid application.
- [Architecture](architecture.md): Trace the command, navigation, and rendering
  loops.
- [Features](features.md): Organize Lucid code around
  product behavior.
- [Messages](messages.md): Learn how links, commands, and events encode intent.
- [Components](components.md): Learn how components hold state, compose views,
  and render HTML.
- [Handlers](handlers.md): Put command-side behavior, policies, redirects, and
  event publication in handlers.
- [Client Behavior](client_behavior.md): Use JavaScript for local behavior
  without creating a second application model.

Reference:

- [State](reference/state.md): Work with URL-backed state, state maps, and nested
  component state.
- [Templates](reference/templates.md): Use the template context, helpers, and
  multipart form support.
- [Configuration](reference/configuration.md): Configure application settings,
  request containers, and extension points.
