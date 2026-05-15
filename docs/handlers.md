# Handlers

Handlers own effectful application behavior.

In Lucid, a handler is the place to:

- process commands
- load domain records
- check permissions
- write data
- publish events
- request redirects or other response effects

## Lifecycle

Handlers are instantiated with:

- the incoming message
- the request container
- the block registered for that message

When `call` runs, Lucid executes the handler block inside a permission-checking
and error-reporting wrapper.

If a handler raises unexpectedly, Lucid logs the exception and publishes a
`HandlerRaised` event.

## Messaging Responsibilities

Handlers can:

- `publish(event)` to broadcast new events
- `dispatch(command)` to trigger other command flows
- `redirect_to(url)` to register a response redirect

## Dependency Injection

Handlers support dependency injection through `use`. The default base handler
already exposes:

- `message_bus`
- `session`
- `response_effects`

Applications can add more dependencies through the request container.

## Policies

Handlers can adopt policy classes and are expected to call `with_permission`
when policy-gated behavior is executed.

In test and development environments, Lucid will raise if a policy-adopting
handler skips that permission check.
