# Getting Started

Caju is a UI framework for Ruby applications that want server-rendered,
hypermedia interactions without making routes, controllers, and templates carry
all of the interaction design.

The easiest way to start is to run a Caju app as a Rack application. Today,
`Caju::App` is implemented as a small `Sinatra::Base` app, so it can run
directly with Sinatra or be mounted anywhere a Rack app can be mounted.

## What Caju Provides

Caju gives your application a message-driven rendering layer:

- typed messages for user and system intent
- handlers for command-side effects
- components for stateful server-rendered HTML
- URL-mapped view state
- server-decided HTML updates for HTMX requests
- helpers for links, forms, nested components, and response effects

The core idea is that views describe intent through messages. Caju turns those
messages into HTTP URLs and form actions, decodes requests back into typed
objects, dispatches them, and renders the resulting component state.

## What Caju Does Not Provide

Caju is not a full-stack application framework.

It does not provide:

- an ORM or database migrations
- authentication or authorization systems
- background jobs
- asset compilation
- mailers
- deployment tooling
- a complete Rails-style application skeleton

Those choices stay in your application. Caju is meant to sit beside your
domain model and infrastructure, not replace them.

## What You Need

A Caju app needs:

- Ruby and Bundler
- the `lucid` gem
- a Rack-compatible HTTP runtime
- application code for persistence, authentication, jobs, and services
- HTMX in the browser when you want partial page updates
- optional JavaScript such as Stimulus for local-only behavior

For a new experiment, the repository examples need no database or external
services.

## Install the Gem

Add Lucid to your bundle:

```ruby
gem "lucid"
```

The gem keeps the `lucid` name during the transition from Lucid to Caju.
New application code should use `Caju::`; existing `Lucid::` code remains
supported.

Then install dependencies:

```sh
bundle install
```

## Build the Smallest App

A minimal Caju app defines a message, a component, and an app class.

```ruby
require "lucid"

class GreetPerson < Caju::Link
  validate do
    required(:name).filled(:string)
  end
end

class HomePage < Caju::Component::Base
  param :name, Types.string.default("world".freeze)

  to GreetPerson do |msg|
    update(name: msg.name)
  end

  element do |name|
    h1 { text "Hello, #{name}" }
    p { link_to GreetPerson.new(name: "Caju"), "Say hello to Caju" }
  end
end

class ExampleApp < Caju::App
  set :component_class, HomePage
end
```

`GET /` renders the component from URL-mapped state. A Caju link renders as a
normal URL under `/@/`, and following it sends a typed `Link` message back to
the component tree.

## Add a Layout

For partial updates, load HTMX once in the document head and boost the document
body. A common pattern is to make the configured root component an application
layout and nest the page component inside it.

```ruby
class ApplicationLayout < Caju::Component::Base
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

class ExampleApp < Caju::App
  set :component_class, ApplicationLayout
end
```

`script(**HTMX::LIB)` emits the bundled HTMX script attributes. `body(HTMX.boost)`
adds the HTMX attributes Lucid expects for boosted links and forms.

## Rack

Because `Caju::App` is a Rack app, a plain Rack entrypoint can mount a Caju
application directly.

```ruby
require_relative "../../lib/lucid"

class RackBasicApp < Caju::App
  set :component_class, HomePage
end

run RackBasicApp
```

The repository includes a runnable version at `examples/rack_basic/config.ru`.
From the repository root:

```sh
bundle exec rackup examples/rack_basic/config.ru
```

The repository bundle includes the `rackup` executable for this example. In
your own app, use `rackup`, Puma, Falcon, Passenger, or any other Rack runtime.
If your Rack server supports custom ports, pass its normal port option and open
the printed local URL.

## Sinatra

Caju can also run directly as a Sinatra-style application because
`Caju::App` subclasses `Sinatra::Base`.

```ruby
require_relative "../../lib/lucid"

class SinatraBasicApp < Caju::App
  set :component_class, HomePage
end

SinatraBasicApp.run! if $PROGRAM_NAME == __FILE__
```

The repository includes a runnable version at `examples/sinatra_basic/app.rb`.
From the repository root:

```sh
bundle exec ruby examples/sinatra_basic/app.rb
```

Then open `http://localhost:4567`.

## Rails

Rails integration is planned around a Rails Engine and Rails Controller. That is
the intended developer experience, not an implemented API in this pass.

The goal is for a Rails app to keep Rails ownership of application boot,
middleware, routing, assets, persistence, authentication, and deployment, while
Lucid owns the interactive UI surface mounted inside that Rails application.

An intended shape looks like this:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount MyLucidUI::Engine => "/app"
end
```

```ruby
module MyLucidUI
  class ApplicationController < ActionController::Base
    include Lucid::Rails::Controller

    lucid_component HomePage
    lucid_handler ApplicationHandler
  end
end
```

Until that adapter exists, use the Rack/Sinatra paths for runnable Lucid apps
and treat Rails as an integration target.

## Where To Go Next

Continue to [Hello World](hello.md) for a focused walkthrough of the component,
message, and app pieces. Then read [Architecture](architecture.md) to see how
links, commands, handlers, events, and rendering fit together.
