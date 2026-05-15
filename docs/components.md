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

- `param` defines URL-backed state
- `prop` defines incoming data needed for rendering
- `temp` can hold transient rendering concerns that should not be encoded into
  the URL

Typed declarations matter because Lucid rebuilds components from request state
on every cycle.

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
