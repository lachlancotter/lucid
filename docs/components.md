# Components

Components are Lucid's rendering unit.

A component is a Ruby object that:

- holds typed state with `param`
- accepts typed external inputs with `prop`
- composes subcomponents with `nest`
- renders HTML using templates and Papercraft helpers
- reacts to messages and events

## What Components Are For

Components should own presentation logic and UI state transitions.

They are a good place for:

- mapping message intent into view state
- composing the page from smaller UI parts
- exposing helper methods used by templates
- responding to published domain events with re-renders

They are not the right place for database writes or transaction-heavy business
logic. That belongs in handlers.

## State and Props

Lucid distinguishes between internal component state and external inputs.

- `param` defines URL-mapped state
- `prop` defines incoming data needed for rendering
- `temp` can hold transient rendering concerns that should not be encoded into
  the URL
- `use` declares request-container dependencies, matching handler dependency
  injection
- `inherit` references reactive fields from an ancestor component or the HTTP
  session

Typed declarations matter because Lucid rebuilds components from request state
on every cycle.

### Choosing Param, Prop, or Temp

Use `param` for state that belongs to the component and should survive request
boundaries. Params are part of the component's deep state, can be represented in
the URL, and are the right choice for navigation and view configuration:

```ruby
class ProjectBoard < Lucid::Component::Base
  param :project_id, Types.integer
  param :filter, Types.string.default("open".freeze)
  param :page, Types.integer.default(1)
end
```

Good candidates for `param` include selected IDs, tabs, filters, sort order,
pagination, and other state that should be preserved by refresh, back/forward
navigation, or a shared link.

Use `prop` for data that is supplied by a parent component or by the request
container and is needed to render this component. Props describe data flow into
a component; they do not define the component's URL state.

```ruby
class ProjectCard < Lucid::Component::Base
  prop :project, Types::Any
  prop :selected, Types::Bool.default(false)
end
```

Good candidates for `prop` include records, value objects, form contexts,
precomputed counts, permission flags, and callbacks or component classes passed
into nested components.

Use `temp` for transient server-side rendering concerns that should not be
encoded into the URL or passed down as parent-owned input. Temps are useful for
values produced while handling a message or event, such as temporary status,
flash-like rendering state, or lazy-loading placeholders.

```ruby
class SyncStatus < Lucid::Component::Base
  temp :notice

  on(SyncCompleted) do
    touch notice: "Sync complete"
  end
end
```

A useful test is to ask who owns the value and whether a URL should carry it:

- use `param` when the component owns the value and the browser history or URL
  should reflect it
- use `prop` when another component or collaborator owns the value and this
  component only needs it for rendering
- use `temp` when the value is local to the current render cycle and should
  disappear instead of becoming durable state

For URL path mapping with `route`, see [State](reference/state.md).
For guidance on where query methods belong, see [Models](models.md).

Container dependencies are plain collaborators:

```ruby
class AccountMenu < Lucid::Component::Base
  use :current_user, Types::Any
end
```

Inherited fields remain reactive UI data:

```ruby
class ChildPanel < Lucid::Component::Base
  inherit :selected_tab
  inherit :flash, from: :http_session
end
```

## Composition

Components compose by nesting other components. This gives you:

- isolated, focused view objects
- explicit parent-child relationships
- predictable data flow
- reusable rendering boundaries for partial updates

## Responding to Messages

Components primarily respond to `Link` messages with `to` blocks. These blocks
typically call `update` to change component state.

Components can also respond to `Event` messages with `on` blocks so the UI
tracks domain changes without manual refresh code.

## Rendering

Lucid components render HTML through `Lucid::HTML::Template`, which provides
helpers such as:

- `link_to`
- `button_to`
- `form_for`
- `subcomponent`
- `subcomponents`
- `template`
