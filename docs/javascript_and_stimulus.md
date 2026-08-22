# JavaScript and Stimulus

Caju is JavaScript-framework agnostic. It does not require a client-side
application framework, and it does not ask JavaScript to duplicate the
server-side component model.

When a Caju app needs browser behavior, Stimulus is the recommended default.
Its controller-per-element architecture fits Caju's rendering cycle: the server
can replace component HTML, and Stimulus can connect new controllers to the new
DOM without preserving a separate client-side application tree.

Existing Lucid applications can use the same guidance. The public `Caju::`
namespace is preferred for new application code while the gem continues to
support `Lucid::`.

## The Boundary

Caju should own behavior that changes application state or affects what the
server renders:

- navigation through `Link` messages
- mutations through `Command` messages
- domain notifications through `Event` messages
- URL-mapped view state
- validation, authorization, persistence, and redirects
- server-rendered component updates

JavaScript should own local browser behavior:

- focus and selection management
- keyboard shortcuts
- disclosure and transition details
- button busy states
- drag previews and drop highlighting
- measuring, positioning, and viewport-only behavior
- integration with browser APIs

If a behavior must survive a refresh, be shareable in a URL, affect permissions,
drive server rendering, or change durable data, model it in Caju. If it only
improves the immediate feel of an already-modeled interaction, keep it in
JavaScript.

## Why Stimulus Fits

Stimulus is a small layer around HTML. Controllers attach to elements through
`data-controller`, read targets and values from the DOM, and handle browser
events declared in markup.

That maps cleanly to Caju because:

- Caju components render the HTML that declares the behavior
- Stimulus controllers connect when that HTML enters the page
- HTMX swaps replace DOM islands without preserving client-side component state
- controller state can stay local to a rendered element
- the server remains the source of truth for application state

This keeps JavaScript close to the markup it enhances while leaving messages,
handlers, and server-rendered state in Ruby.

## Rendering Stimulus Attributes

Caju templates are Ruby blocks, so Stimulus attributes can be rendered as normal
HTML attributes.

```ruby
class AccountMenu < Caju::Component::Base
  element do
    div(
      "data-controller": "menu",
      "data-menu-open-class": "is-open"
    ) do
      button(
        type: "button",
        "data-action": "menu#toggle",
        "data-menu-target": "button"
      ) { text "Account" }

      nav("data-menu-target": "panel", hidden: true) do
        a(href: "/settings") { text "Settings" }
        a(href: "/sign-out") { text "Sign out" }
      end
    end
  end
end
```

The controller can manage the local open/closed presentation without becoming
the owner of the account menu's durable state.

```js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]
  static classes = ["open"]

  toggle() {
    const open = this.panelTarget.hidden

    this.panelTarget.hidden = !open
    this.element.classList.toggle(this.openClass, open)
    this.buttonTarget.setAttribute("aria-expanded", String(open))
  }
}
```

## Progressive Enhancement

Start with HTML that works without custom JavaScript. Then use Stimulus to make
the interaction faster, clearer, or more tactile.

For example, a sortable list should still expose Caju commands for the actual
move. Stimulus can handle drag gestures, drop indicators, and submitting the
existing command when the user drops an item.

```ruby
form_for move_card_form,
  "data-controller": "sortable-card",
  "data-action": "drop->sortable-card#submit" do |f|
  f.hidden(:card_id, value: card.id)
  f.hidden(:column_id, value: column.id)
  button(type: "submit") { text "Move here" }
end
```

The command remains the durable behavior. The controller only changes how the
user gets to that command.

## Keep Controllers Disposable

Caju and HTMX may replace a component's DOM after a message is handled. Stimulus
controllers should assume that `connect` and `disconnect` can happen often.

Prefer controllers that:

- initialize from DOM attributes, targets, and values
- clean up timers, observers, and global listeners in `disconnect`
- treat local fields as temporary browser state
- submit Caju links or commands rather than mutating application data directly
- tolerate the server replacing their element after a request

Avoid controllers that:

- cache server data that should be rendered by Caju
- keep navigation state outside the URL or component params
- build a parallel component hierarchy in JavaScript
- depend on DOM nodes surviving a Caju update
- manually coordinate HTMX swap targets that Caju can infer from components

## Working With HTMX

Caju uses HTMX as the browser transport and swap layer. Stimulus should not need
to take over that transport for normal links and forms.

Use Stimulus when you need local browser behavior before or after a request,
such as disabling a button, updating an ARIA attribute, or preparing a hidden
field from a drag interaction. Let Caju helpers render the link or form that
submits the message.

When a controller needs to react to HTMX lifecycle events, keep that reaction
local to the element it enhances and avoid coupling it to distant component
markup.

## Asset Tooling

Caju does not prescribe an asset pipeline. Use the JavaScript tooling that fits
the host application:

- import maps for small Rack or Rails applications
- a bundler when the app already has one
- the host framework's asset pipeline when Caju is mounted inside a larger app

The important constraint is architectural, not tooling-specific: JavaScript
should enhance the HTML Caju renders, not replace Caju's message-driven state
model.
