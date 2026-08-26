# Models

Lucid does not provide an ORM or model layer. Most applications will use
ActiveRecord or another persistence library, but Lucid keeps the responsibility
boundary the same: models own domain invariants, handlers own writes, and
components own the query shape needed to render a view.

## What Models Are For

Model classes should define facts that are true wherever the model is used.

They are a good place for:

- associations
- unconditional validations
- persistence-level invariants
- small convenience methods that apply updates to the model itself

They are not the best place for every query a screen might need. View-specific
queries often encode sorting, filtering, preloading, pagination, projection, and
empty-state concerns that only make sense for one component.

## Queries Belong Near Views

In traditional MVC applications, it is common to collect query scopes and finder
methods on model classes because controllers and templates both reach through
the model layer for data. In Lucid, components are the rendering boundary, so
the recommended default is to define query methods in the components that render
their results.

That keeps the query close to the shape of the HTML it supports. A component can
query exactly the records, columns, ordering, and preloads its template needs
without turning the model class into a catalog of screen-specific scopes.

```ruby
class ProjectActivity < Lucid::Component::Base
  param :project_id, Types.integer

  def activities
    Activity
      .where(project_id: project_id)
      .includes(:actor)
      .order(created_at: :desc)
      .limit(20)
  end
end
```

Use model-level scopes when they describe reusable domain concepts, not one
view's presentation needs. For example, `Task.open` can be a good model scope
if "open" is part of the domain language. `Task.visible_in_dashboard_order` is
usually a component concern unless that ordering is meaningful across the whole
application.
