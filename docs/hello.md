# Hello World

This walkthrough builds the smallest useful Lucid application. For setup
options across Rack, Sinatra, and the planned Rails integration, start with
[Getting Started](getting_started.md).

A tiny Lucid app has three parts:

- a root component
- one or more messages
- an app configured to render that component

## A Tiny Component

```ruby
class HomePage < Lucid::Component::Base
  param :name, Types.string.default("world".freeze)

  element do |name|
    h1 { text "Hello, #{name}" }
  end
end
```

This component declares URL-mapped state with `param` and renders HTML from
that state.

## A Link Message

```ruby
class GreetPerson < Lucid::Link
  validate do
    required(:name).filled(:string)
  end
end
```

## Handling the Link

```ruby
class HomePage < Lucid::Component::Base
  param :name, Types.string.default("world".freeze)

  to GreetPerson do |msg|
    update(name: msg.name)
  end
end
```

Now navigation is expressed as intent instead of route manipulation.

## Wiring the App

```ruby
class ExampleApp < Lucid::App
  set :component_class, HomePage
end
```

Run the app directly with Sinatra:

```ruby
ExampleApp.run! if $PROGRAM_NAME == __FILE__
```

With that in place:

- `GET /` renders the default component state
- `GET /@/greet-person?name=Lucid` applies the link message

From there, the next concepts to learn are:

- [Getting Started](getting_started.md)
- [Architecture](architecture.md)
- [Features](features.md)
- [Messages](messages.md)
- [Components](components.md)
- [Handlers](handlers.md)
