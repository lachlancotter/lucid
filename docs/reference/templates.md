# Templates

Lucid templates are built on top of Papercraft.

`Lucid::HTML::Template` adds framework-specific behavior so templates can work
directly with messages, forms, and nested components.

## Template Model

A Lucid template is a Ruby block that renders HTML in a Papercraft context.

Templates can be:

- the main component template
- named templates rendered via `template :name`
- wrappers used during component replacement and HTMX updates

## Binding and Context

Templates are bound to a renderable object, usually a component instance. That
binding gives the template access to:

- the component's helpers
- nested component rendering
- Lucid message helpers
- explicit `context` access when needed

## Core Helpers

The most important rendering helpers are:

- `link_to`
- `button_to`
- `form_for`
- `template`
- `subcomponent`
- `subcomponents`
