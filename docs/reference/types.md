# Types

Lucid uses `dry-types`, `dry-struct`, and `dry-schema` to keep application
boundaries explicit.

Most application code uses the `Types` module that Lucid exposes. It is a thin
wrapper around dry-types with a few conveniences for request parameters and
Lucid-specific objects.

Inside Lucid declaration contexts, use `type(...)` as the concise form. Passing
an application class means "an instance of this class":

```ruby
class TaskHandler < Lucid::Handler
  use :event_bus, type(EventBus)
end
```

Calling `type` without arguments exposes the same helper module for composed
types:

```ruby
class ProjectBoard < Lucid::Component::Base
  param :status, type.enum("open", "closed").default("open".freeze)
  prop :tags, type.array(String)
end
```

## Why Types Matter

Lucid rebuilds components and messages from request data on every cycle. Type
declarations tell Lucid how to coerce incoming values, which values are allowed
to be missing, and which defaults should be used when the request does not carry
a value.

Types are part of the contract for:

- component state declared with `param`
- component inputs declared with `prop`
- transient component values declared with `temp`
- request-container dependencies declared with `use`
- session values declared with `key`
- internal framework objects such as handlers, components, form models, and
  state readers

Use the narrowest type that describes the boundary. That keeps invalid request
state, missing component input, and misconfigured dependencies close to the
place where they enter the system.

## Common Types

Lucid defines common parameter-oriented types:

```ruby
Types.string
Types.integer
Types.float
Types.bool
Types.date
Types.time
Types.datetime
Types.hash
Types.symbol
```

These types are intended for values that may arrive from HTTP params. For
example, `Types.integer` coerces integer-like strings into integers so URL and
form values can become typed Ruby data.

Lucid also exposes helpers for common Ruby and framework shapes:

```ruby
type(User)
type(:integer)
type.array(String)
type.enum("open", "closed")

Types.array(Types.string)
Types.instance(User)
Types.subclass(ApplicationHandler)
Types.any
```

`type(User)` and `Types.instance(User)` accept instances of a class.
`Types.subclass` is useful when a declaration should receive a class object
that inherits from a base class.

## Defaults and Optional Values

Use dry-types defaults when a declaration should have a value even when the
request or caller does not provide one.

```ruby
class ProjectBoard < Lucid::Component::Base
  param :filter, Types.string.default("open".freeze)
  param :page, Types.integer.default(1)
end
```

Use `.optional` when `nil` is a meaningful value.

```ruby
class ProjectBoard < Lucid::Component::Base
  param :selected_card_id, Types.integer.optional.default(nil)
end
```

Prefer defaults for ordinary initial UI state, and reserve optional values for
cases where absence has its own meaning.

## Component Declarations

`param` declares typed state owned by a component. Params can be represented in
the URL and reconstructed from request state.

```ruby
class SearchView < Lucid::Component::Base
  param :query, Types.string.default("".freeze)
  param :page, Types.integer.default(1)
end
```

`prop` declares typed data supplied from outside the component. Props describe
data flow into a rendering boundary; they are not URL state.

```ruby
class ProjectCard < Lucid::Component::Base
  prop :project, Types.instance(Project)
  prop :selected, Types.bool.default(false)
end
```

`temp` declares typed transient rendering state. Temps are useful for values
that can change during message or event handling but should not become durable
URL state.

```ruby
class SyncStatus < Lucid::Component::Base
  temp :notice, Types.string.optional.default(nil)
end
```

For guidance on choosing between `param`, `prop`, and `temp`, see
[Components](../components.md).

## Dependencies

Handlers and components use `use` to declare dependencies supplied by the
request container.

```ruby
class TaskHandler < Lucid::Handler
  use :task_notifier, Types.instance(TaskNotifier)
end
```

The type is checked when the dependency is resolved, so a missing or
misconfigured collaborator fails at the boundary where the handler or component
expects to use it.

## Message Validation

Messages use a separate `validate` API backed by `Dry::Schema.Params`.

```ruby
class AssignTask < Lucid::Command
  validate do
    required(:task_id).filled(:integer)
    required(:user_id).filled(:integer)
  end
end
```

This is still part of Lucid's typed boundary, but it is not the same API as
component `param` or `prop` declarations. Message schemas validate external
payloads before a message object is used by handlers or components.

If a submitted command payload is invalid, Lucid publishes a
`MessageInvalidated` event instead of treating the request as a successful
command.
