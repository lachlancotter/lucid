# Lucid

Lucid is a framework for building event-driven, hypermedia applications.

- Messages are simple value objects that describe system intent and behavior.
- Handlers respond to Messages and apply effects.
- Components render application state to HTML.

The codebase centers on these three concepts. When changing the rendering layer, preserve the distinction between declaration-time APIs and template-time composition APIs.
