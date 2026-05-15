# Hello World

The smallest useful Lucid application has three parts:

- a root component
- one or more messages
- an app configured to render that component

## A Tiny Component

```ruby
class HomePage < Lucid::Component::Base
  param :name, Types.string.default("world".freeze)

  template do |name|
    html {
      body {
        h1 { text "Hello, #{name}" }
      }
    }
  end
end
```

This component declares URL-backed state with `param` and renders HTML from
that state.

## A Link Message

```ruby
class GreetPerson < Lucid::Link
  param :name, String
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

With that in place:

- `GET /` renders the default component state
- `GET /@/greet_person?name=Lucid` applies the link message

From there, the next concepts to learn are:

- [Architecture](architecture.md)
- [Messages](messages.md)
- [Components](components.md)
- [Handlers](handlers.md)
