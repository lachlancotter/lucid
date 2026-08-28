# Why Lucid?

Web application architecture is lost.

That sounds dramatic, but it explains the state of modern application
development better than the usual debates about frameworks. Teams are still
trying to answer a basic question:

> Where should application behavior live?

The last decade has produced two dominant answers. One answer says the browser
should own the application. The other says the server should keep control and
send HTML. Both answers are useful. Both lead to compromise.

Lucid exists because there is a better way to build rich web applications. But
seeing it requires setting aside some familiar assumptions about routes,
controllers, APIs, client-side state, and what hypermedia can be.

You need to forget what you thought you knew about web development.

## The Core Tension

Rich applications need state, interaction, and coordination. A user opens
panels, edits forms, changes filters, submits commands, sees validation errors,
triggers side effects, and expects the page to update in the right places.

Classic server-driven applications are good at business behavior. The server
can load records, enforce permissions, run transactions, publish events, and
render HTML from trusted state. But traditional MVC frameworks tend to model
interaction through routes and controller actions. As the UI becomes more
stateful, that model starts to stretch.

Client-heavy applications solve the interaction problem by moving the center of
gravity into the browser. They give the UI a component model, local state, and
precise control over what changes on screen. But they do this by splitting the
application into two systems: a front end and a back end.

That split is where much of the complexity begins.

## The Server-Driven Compromise

Rails-style MVC gives Ruby applications a clear default shape: routes receive
requests, controllers coordinate work, models hold persistence logic, and views
render HTML.

That shape works well when interactions are page-shaped. It becomes more
awkward when a single user action is really a change in interface state.

In a richer UI, one interaction can require coordinated changes across:

- route definitions
- controller actions
- params and session state
- templates and partials
- route helpers in forms and links
- JavaScript that patches over missing interactivity

Over time, the controller becomes the place that knows too much. It knows which
workflow branch the user is in, which partials need to render, which params
represent view state, which redirect returns the user to the right place, and
which browser behavior is expected to finish the interaction.

The problem is not server rendering. The problem is that MVC expresses user
intent indirectly through endpoints. Behavior that should belong to the product
model gets smeared across routes, controllers, templates, and client-side
helpers.

## The SPA Compromise

SPA frameworks respond to that pressure by giving the browser a real
application model. Components own view state. Client-side routers coordinate
navigation. Local state managers decide what should update. The UI can feel
fast and coherent because the browser is now the application runtime.

But that power introduces complexity from two main sources: the toolchain and
the API.

The toolchain is the visible part. A SPA brings a build system, package graph,
compiler, bundler, dev server, asset pipeline, hydration model, and deployment
surface. Some of that can be hidden behind framework defaults, but it is still
part of the architecture.

The API is the deeper problem. Once the application is split into front end and
back end, those two systems need an interface. That interface is the API, and
APIs are hard to get right.

The architect is forced into a choice:

- Design an API that serves the exact needs of the front end, at the cost of
  coupling and churn.
- Design a more primitive, stable API, at the expense of more state and logic on
  the front end.

The first option keeps the client simpler, but every product change can ripple
through the API. The second option keeps the API cleaner, but the browser must
assemble more behavior from lower-level primitives. Either way, the product now
lives across a boundary that must be designed, versioned, tested, secured, and
maintained.

For many business applications, that is a high price to pay. The server is
still the best place to coordinate business effects, and HTML is still the best
representation to send to the browser. A full SPA solves interactivity by
creating more architecture than the product should need.

## The Hypermedia Correction

HTMX and similar tools offer a compelling correction. They return attention to
hypermedia: links, forms, HTTP, and server-rendered HTML.

That matters. It reminds us that the browser already understands how to submit
requests, receive markup, update navigation state, and display documents. You
do not always need a client-side application shell just to make a page feel
alive.

HTMX makes incremental updates natural. A link or form can request a fragment,
swap a target, and avoid a full page reload. It brings much of the feel of a
modern interface back to server-rendered applications.

But HTMX is not a complete application architecture.

As an HTMX-heavy interface grows, behavior can become encoded in:

- endpoint names
- template boundaries
- DOM IDs and swap targets
- request headers
- response fragments
- local JavaScript events and hooks

The coupling has moved rather than disappeared. Instead of views knowing route
helpers and controllers knowing pages, templates know DOM targets, endpoints
know fragment shapes, and refactors require careful alignment between server
responses and client-side swap behavior.

HTMX brings us back to hypermedia, but it does not by itself answer the deeper
architectural question. It does not give the application a typed model for user
intent, a component state model, or a domain event flow for reactive updates.
Those choices remain up to each application.

## What a Better Solution Needs

An ideal architecture would keep the strengths of server-driven HTML without
falling back into route and controller coupling.

It would preserve hypermedia, but give it a stronger application model.

It would let the server coordinate business behavior, but stop making
controllers the center of every interaction.

It would support rich, targeted updates, but avoid making DOM swap mechanics the
core abstraction.

It would make user intent explicit. A view should be able to say what the user
is trying to do without knowing which endpoint, controller, fragment, or client
store will handle it.

It would keep UI state navigable. The URL should be able to describe the
interface the user is looking at, rather than hiding that state in sessions,
temporary controller branches, or client-only stores.

It would separate three things that are often tangled together:

- intent
- effects
- rendering

That is the shape Lucid is designed around.

## The Lucid Shift

Lucid organizes applications around three concepts:

- `Messages` describe intent
- `Handlers` apply effects
- `Components` render state to HTML

This changes the main question from:

> Which controller action should handle this URL?

or:

> Which client-side state transition should this event trigger?

or:

> Which fragment should this endpoint return, and where should it be swapped?

to:

> What is the user trying to do, and which parts of the system care?

That shift matters because intent is usually more stable than routes, API
shapes, or DOM targets. When your code speaks in terms of `ShowEditForm`,
`DeletePost`, or `PostDeleted`, the system becomes easier to extend and
refactor.

## Why Messages Matter

Messages decouple interactions from endpoints.

Instead of binding a link directly to a route helper, controller action, API
call, or swap target, you create a value object that expresses the interaction.
Lucid then encodes that message into HTTP and decodes it back on the server.

This gives the application a vocabulary for behavior:

- links represent navigation intent
- commands represent requested mutations
- events represent things that happened

Views can describe intent without knowing transport details. Handlers can react
to commands. Components can react to link messages and published events. Tests
can focus on behavior and effects instead of route plumbing or browser-side
wiring.

## Why Components Matter

Lucid components are the rendering layer. They hold typed state, compose into
trees, and render HTML using Ruby templates.

Because components rebuild from request state on each cycle, the URL can become
a truthful representation of the current UI. Browser navigation works more
naturally, and the application needs less hidden session state or client-only
view state.

Components also react directly to messages and events. That gives the interface
a reactive feel without turning the browser into the application runtime and
without making fragment swaps the main design primitive.

## Why Handlers Matter

Handlers own command-side behavior:

- loading resources
- enforcing permissions
- writing to the database
- publishing events
- issuing redirects or other response effects

This keeps business logic out of templates and component rendering paths, while
still allowing the UI to update automatically in response to domain events.

## There Is A Better Way

Lucid is not trying to make Rails more dynamic, rebuild a SPA in Ruby, or wrap
HTMX with nicer syntax.

It is a different model for interactive hypermedia applications.

The payoff is:

- less coupling between views, routes, and business logic
- a typed vocabulary for user and system intent
- URLs derived from component state
- business effects isolated in handlers
- reactive server-rendered updates without a client-owned application shell
- hypermedia without making DOM swap mechanics the center of the design

If the current choices feel unsatisfying, that is because the usual categories
are too small. The web does not need to choose between static MVC pages,
client-owned SPAs, and ad hoc fragment swapping.

There is a better way. Lucid is an attempt to make that way concrete.
