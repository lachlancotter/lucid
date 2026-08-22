# Configuration

Lucid keeps application-level configuration intentionally small.

`Lucid::App` exposes a handful of settings that define the root objects and
runtime environment for request handling.

## App Settings

The main settings are:

- `component_class`: the root component class
- `handler_class`: the root handler class
- `container_class`: the dependency container class
- `session_class`: the wrapper class for the Rack session
- `app_root`: the URL base path for the application

The `component_class` is often an application layout rather than a page-specific
component. Put shared document structure there, include HTMX in the head, and
render the active page inside a boosted body:

```ruby
class ApplicationLayout < Lucid::Component::Base
  nest(:page) { HomePage }

  element do
    html do
      head do
        script(**HTMX::LIB)
      end

      body(HTMX.boost) do
        subcomponent(:page)
      end
    end
  end
end
```

## Container

The container is created per request and provides request-scoped collaborators
such as:

- the request adaptor
- the response adaptor
- the message bus
- response effects
- the session wrapper

For most applications, the container is where Lucid is extended with
domain-specific dependencies.
