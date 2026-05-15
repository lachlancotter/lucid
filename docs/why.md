# Why Lucid?

Lucid exists to make interactive server-rendered applications easier to design,
change, and reason about.

Traditional Ruby web applications usually spread one user interaction across
several tightly coupled layers:

- routes define URL structure
- controllers interpret requests
- views generate links and forms against route helpers
- client code fills the gaps when the UI becomes more dynamic

That model works, but it creates friction as the interface grows more
stateful. Navigation state leaks into routes, rendering decisions creep into
controllers, and refactors often require coordinated changes across URLs,
controllers, templates, and JavaScript.

Lucid takes a different approach.

## The Problem Lucid Solves

Lucid is designed for applications where HTML is still the right output format,
but the UI behaves more like a living interface than a stack of static pages.

In those applications, the hard problems are usually:

- expressing user intent cleanly
- keeping business logic out of rendering code
- representing UI state in a way the browser can navigate
- updating only the parts of the page that changed
- avoiding route and controller coupling as features evolve

Lucid addresses those problems by centering the UI around messages and
components instead of controller actions.

## The Core Shift

Lucid organizes the application around three concepts:

- `Messages` describe intent
- `Handlers` apply effects
- `Components` render state to HTML

This changes the main question from:

> Which controller action should handle this URL?

to:

> What is the user trying to do, and which parts of the system care?

That shift matters because intent is usually more stable than route structure.
When your code speaks in terms of `ShowEditForm`, `DeletePost`, or
`PostDeleted`, the system becomes easier to extend and refactor.

## Why Messages Matter

Messages decouple interactions from URLs.

Instead of binding a link directly to a route helper or controller action, you
create a value object that expresses the interaction. Lucid then encodes that
message into HTTP and decodes it back on the server.

This buys you several things:

- views do not need hard-coded knowledge of route structure
- multiple handlers can react to the same command or event
- links and commands become reusable application vocabulary
- tests can focus on intent and effects instead of route plumbing

## Why Components Matter

Lucid components are the rendering layer. They hold typed state, compose into
trees, and render HTML using Ruby templates.

Because components rebuild from request state on each cycle, the URL can become
a truthful representation of the current UI. That makes browser navigation work
more naturally and reduces the need for hidden session-driven UI state.

Components also react directly to link messages and published events, which
gives the system a reactive feel without forcing you into a client-side SPA
architecture.

## Why Handlers Matter

Handlers own command-side behavior:

- loading resources
- enforcing permissions
- writing to the database
- publishing events
- issuing redirects or other response effects

This keeps business logic out of templates and component rendering paths, while
still allowing the UI to update automatically in response to domain events.

## Where Lucid Fits

Lucid is not trying to replace every part of your stack.

It fits best when you want:

- Ruby-driven HTML rendering
- richer interactions than classic full-page request cycles
- a hypermedia approach instead of a full client-side SPA
- explicit separation between intent, effects, and rendering

It is less compelling if your application is primarily:

- a JSON API
- a static content site
- a fully client-owned SPA where the server only exposes data endpoints

## The Payoff

Lucid trades familiar MVC conventions for a model that is better aligned with
interactive hypermedia applications.

The main benefits are:

- less coupling between views, routes, and business logic
- URLs derived from state instead of handwritten navigation plumbing
- cleaner composition of UI behavior
- easier refactoring as features grow
- server-rendered interactivity without abandoning HTML as the primary medium

If those problems are the ones making your application difficult to evolve,
Lucid is the right abstraction to explore next.
