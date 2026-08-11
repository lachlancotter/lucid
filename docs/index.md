# Lucid Documentation

Lucid is a Ruby framework for building reactive, hypermedia applications with a
message-driven architecture.

## What Lucid is

Lucid organizes interactive server-rendered applications around three
primitives: messages, handlers, and components. Instead of centering UI behavior
on routes and controllers, Lucid models what the user is trying to do and lets
the relevant parts of the system respond.

It fits best when you want rich HTML interactions, server-side rendering, typed
UI state, and HTMX-friendly partial responses without moving application state
management into the browser.

## Quickstart

Run the included example app from this repository:

```sh
bundle install
bundle exec ruby examples/hello_world/app.rb
```

Then open `http://localhost:4567`.

For the full walkthrough, continue to [Hello World](hello.md).

## Core model

Messages:

- Value objects that describe intent. Links represent navigation, commands
  represent mutations, and events represent things that happened in the system.

Handlers:

- Objects that apply business effects for commands: loading data, enforcing
  policies, writing records, publishing events, and registering redirects.

Components:

- Ruby objects that hold typed state, compose subcomponents, react to messages
  or events, and render HTML.

## Request flow

1. A user action submits a link or command message.
2. Lucid decodes the HTTP request into a typed message object.
3. Components handle link messages; handlers process command messages and
   publish events.
4. The component tree renders a full page or targeted HTML update.

## Why use Lucid

- Views do not need hard-coded route structure.
- Business logic stays out of rendering code.
- Navigation state can be represented in URLs.
- Server-rendered UI can still support targeted partial updates.

## Next steps

- [Why Lucid?](why.md): Understand the problems Lucid is designed to solve.
- [Hello World](hello.md): Build the smallest useful Lucid application.
- [Architecture](architecture.md): Trace the command, navigation, and rendering
  loops.
- [Messages](messages.md): Learn how links, commands, and events encode intent.
