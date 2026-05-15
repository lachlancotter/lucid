# State

Lucid treats UI state as a first-class concern.

The framework is built around the idea that the current UI can be reconstructed
from request state, which can often be represented in the URL.

## State Mapping

Each component class can define a state map that tells Lucid how to encode and
decode its state.

Lucid supports two broad mapping modes:

- path segments with `path`
- query parameters with `param` or `query`

`Lucid::State::Map` is responsible for these rules.

## Why URL-Backed State Matters

When UI state is encoded into the URL:

- browser navigation works naturally
- links are shareable
- components can rebuild deterministically on each request
- server rendering does not need hidden controller state to recover context

## Nested State

Components compose, so state composes too.

`Lucid::State::Writer` walks the component tree, applying each component's state
map and nesting scope to produce a URL that reflects the visible UI state.
