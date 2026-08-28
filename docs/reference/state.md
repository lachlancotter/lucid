# State

Lucid treats UI state as a first-class concern.

The framework is built around the idea that the current UI can be reconstructed
from request state, which can often be represented in the URL.

## State Mapping

Each component class can define a state map that tells Lucid how to project
component state into a URL and read it back into state.

This is different from a traditional Rails-style route, where the route is
usually treated as a fixed address for a resource or controller action. In
Lucid, the URL is a projection of the current component state. Changing the
mapping changes how that state is represented in the browser, without changing
the messages, handlers, or component behavior that make up the application.

Two APIs work together:

- `param` declares typed state that can be represented in the URL
- `route` selects which params are represented as path segments

Params that are not selected by `route` are represented as query parameters.

`Lucid::State::Map` is responsible for these rules.

For the broader distinction between URL-mapped params, external props, and
transient temps, see [Components](../components.md).
For type helpers, defaults, and optional values in declarations, see
[Types](types.md).

### URL-Mapped State With `param`

`param` declares typed component state that participates in URL mapping. It is
agnostic about whether a value appears in the path or in the query string.

```ruby
class SearchView < Lucid::Component::Base
  param :query, Types.string
  param :page, Types.integer.default(1)
end
```

When no `route` uses these params, Lucid projects them as query parameters.
With `query: "ruby"` and `page: 2`, this state can be encoded as
`/?query=ruby&page=2`. Default values are omitted from generated URLs.

### Path Projection With `route`

Use `route` in a component class to select which params should be projected into
the URL path.

```ruby
class PostView < Lucid::Component::Base
  route "posts/:post_id"

  param :post_id, Types.integer
  param :tab, Types.string.default("overview".freeze)
end
```

With `post_id: 42`, this component's URL path is `/posts/42`. Because `tab` is
not part of the route pattern, Lucid keeps it as a query parameter when it does
not have its default value.

Route patterns can contain:

- dynamic segments, written as `:param_name`
- literal segments, written as plain path text

For example:

```ruby
route ":account_id/projects/:project_id"
```

Dynamic route segments must correspond to component state declared with
`param`. If Lucid needs to build a URL and the required value is missing, URL
generation fails instead of silently producing an incomplete path.

Leading and trailing slashes are optional. These are equivalent:

```ruby
route "posts/:post_id"
route "/posts/:post_id/"
```

## Why URL-Mapped State Matters

When UI state is encoded into the URL:

- browser navigation works naturally
- links are shareable
- components can rebuild deterministically on each request
- server rendering does not need hidden controller state to recover context

## Nested State

Components compose, so state composes too.

`Lucid::State::Writer` walks the component tree, applying each component's state
map and nesting scope to produce a URL that reflects the visible UI state.

A parent route can include one nested component in the path with the `nest:`
option:

```ruby
class ProjectView < Lucid::Component::Base
  route "projects/:project_id", nest: :task

  param :project_id, Types.integer

  nest :task do
    Class.new(Lucid::Component::Base) do
      route "tasks/:task_id"

      param :task_id, Types.integer
    end
  end
end
```

That lets a single component tree produce a path such as
`/projects/12/tasks/7`. Nested components that are not part of the active route
still keep their URL-mapped state, but Lucid projects it outside the path.
