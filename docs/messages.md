# Messages

Messages are the language of intent in Lucid.

Instead of expressing interactions as route/controller pairs, Lucid represents
them as typed value objects that can be encoded into HTTP and dispatched inside
the application.

## Message Families

### Links

`Link` messages represent navigation and view-state changes. They use `GET`
semantics and are usually handled directly by components.

Examples:

- show the edit form
- move to page 3
- filter by status
- switch tabs

### Commands

`Command` messages represent mutations. They use `POST` semantics and are
dispatched to handlers.

Examples:

- create a comment
- delete a post
- mark an item complete
- register a learner

### Events

`Event` messages represent things that happened in the system. Handlers publish
them, and components or other handlers can react to them.

## Why This Matters

Messages decouple user intent from route structure.

That gives you:

- views that do not hard-code URLs
- reusable interaction vocabulary
- easier refactoring
- multiple listeners for the same command or event

## Encoding and URLs

Lucid can generate a URL from a message. For `GET` messages, the URL includes:

- the message name
- its parameters
- the current application state when required

This is how Lucid avoids hand-authored route strings in templates.

## Validation

Messages are validated before being turned into runtime objects.

If a command payload is invalid, Lucid publishes a `MessageInvalidated` event
instead of silently treating it as a successful request.

## In Practice

Links are usually handled by components. Commands are usually handled by
handlers. Events connect the two by allowing the UI to react after business
effects are applied.

For the next layer down, see:

- [Components](components.md)
- [Handlers](handlers.md)
- [State](reference/state.md)
