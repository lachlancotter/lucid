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

## File Upload Forms

Use `multipart: true` when a form includes file inputs:

```ruby
form_for(upload_form, multipart: true) do |f|
  f.file(:avatar, accept: "image/*")
end
```

Uploaded files are supported on `POST` forms. Rack parses each uploaded file as
a hash containing upload metadata and a `Tempfile`; handlers are responsible for
validating the file size and type, then moving or processing the tempfile during
the request. Browsers do not repopulate file inputs after validation errors, so
file fields do not echo a `value` from the form model.
