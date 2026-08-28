# Forms

Lucid forms render message parameters as HTML controls.

Components declare a form model with `form` or `echo`, then pass that form model
to templates as a template parameter. Templates render it with `form_for`. The
`form_for` block receives a `Lucid::HTML::Form::Builder`.

## Form Models

Use `form` for a fresh form model and `echo` when invalid submitted parameters
should be rendered back into the form.

```ruby
class BoardView < Lucid::Component::Base
  echo(:add_card_form, AddCard) do |form|
    form.merge_default(title: "")
  end

  element do |add_card_form|
    form_for add_card_form do |f|
      f.hidden(:column_id, value: selected_column_id)
      f.label(:title, "Title")
      f.text(:title, required: true)
      f.submit("Add card")
    end
  end
end
```

The `add_card_form` parameter is the evaluated `Lucid::HTTP::FormModel`.
Declare form models as template parameters instead of reading them by calling
component methods from inside the template body.

The generated `<form>` action and method come from the message class. Lucid also
adds hidden fields for the component path, form name, and CSRF token when one is
available.

## Fields In Templates And Components

Use `fields_for` when rendering fields from an existing form model or scoped
form context. It yields a fresh `Lucid::HTML::Form::Builder` bound to the
current template and does not render a `<form>` tag or hidden form metadata.

Named templates should receive `form.context`, then call `fields_for`.

```ruby
class BoardView < Lucid::Component::Base
  echo(:add_card_form, AddCard) do |form|
    form.merge_default(title: "")
  end

  element do |add_card_form|
    form_for add_card_form do |f|
      template(:add_card_fields, f.context)
      f.submit("Add card")
    end
  end

  template(:add_card_fields) do |form_context|
    fields_for form_context do |f|
      f.text(:title)
    end
  end
end
```

`Lucid::HTML::Form::Context` is a portable value object containing the form
model and current field path. Use `scoped(name)` to create a nested context that
can be passed through templates or component props.

```ruby
class AddressFields < Lucid::Component::Base
  prop :form_context, Types.instance(Lucid::HTML::Form::Context)

  element do |form_context|
    fields_for form_context.scoped(:address) do |f|
      f.text(:street)
    end
  end
end
```

Passing a `Lucid::HTML::Form::Builder` directly to a named template or component
prop is deprecated. Pass `form.context` and call `fields_for` instead.

## Field Names and IDs

In the examples below, variables such as `profile_form` and `settings_form` are
template parameters whose form models include the fields being rendered.

At the top level, a field named `:title` renders with `name="title"` and
`id="title"`. Scoped builders and scoped contexts generate nested parameter
names and underscore joined IDs.

```ruby
form_for profile_form do |f|
  f.scoped(:profile) do |profile|
    profile.text(:name, value: "")
  end
end

fields_for Lucid::HTML::Form::Context.new(profile_form).scoped(:profile) do |profile|
  profile.text(:name, value: "")
end
```

The nested text field renders as `name="profile[name]"` and `id="profile_name"`.

Every field helper accepts additional HTML attributes. Attributes passed by the
caller override the builder defaults, including generated IDs.

```ruby
form_for profile_form do |f|
  f.label(:email, "Email", for: "account-email")
  f.email(:email, value: "", id: "account-email", autocomplete: "email")
end
```

## Values

Field helpers read their value from the form model unless an explicit `value:`
is given. Helpers that read from the model require the field key to be present;
seed fresh forms with `or_default` or `merge_default` when they should render
before the user submits values.

```ruby
echo(:add_card_form, AddCard) do |form|
  form.merge_default(title: "")
end

form_for add_card_form do |f|
  f.text(:title)
  f.text(:title, value: "Default title")
end
```

Checkboxes use their model value to decide whether they are checked unless
`checked:` is given. Radio buttons are checked when their value matches the
model value; use `checked: true` only when a radio button should be forced on.

```ruby
echo(:settings_form, UpdateSettings) do |form|
  form.merge_default(enabled: false, visibility: "public")
end

form_for settings_form do |f|
  f.checkbox(:enabled, value: "yes")
  f.radio_button(:visibility, "public")
  f.radio_button(:visibility, "private", checked: true)
end
```

## Field Helpers

The builder provides these helpers:

- `hidden(key, value: nil, **attrs)`
- `label(key, text = key, **attrs)`
- `text(key, value: nil, **attrs)`
- `email(key, value: nil, **attrs)`
- `date(key, value: nil, **attrs)`
- `number(key, value: nil, **attrs)`
- `file(key, **attrs)`
- `checkbox(key, value: "1", checked: nil, **attrs)`
- `password(key, value: nil, **attrs)`
- `textarea(key, value: nil, **attrs)`
- `select(key, value: field_value(key), **attrs) { |options| ... }`
- `radio_button(key, value, checked: false, **attrs)`
- `submit(label, **attrs)`

`select` yields an option builder with `option(value, label = value, **attrs)`.
The option matching the select value is selected automatically unless attributes
override it.

```ruby
form_for add_card_form do |f|
  f.select(:priority, value: "normal") do |options|
    options.option("normal", "Normal")
    options.option("urgent", "Urgent")
  end
end
```

## Errors

Use `errors(key)` to read validation errors for a field. It follows the same
scope as field names and values.

```ruby
form_for add_card_form do |f|
  f.text(:title, value: "", "aria-invalid": f.errors(:title).any?)

  f.errors(:title).each do |error|
    p(class: "field-error") { text error }
  end
end
```

For nested schemas, call `errors` from a scoped builder.

```ruby
form_for profile_form do |f|
  f.scoped(:profile) do |profile|
    profile.text(:name, value: "")
    profile.errors(:name).each { |error| p { text error } }
  end
end
```

## File Uploads

Use `multipart: true` on `form_for` when a form includes file inputs.

```ruby
form_for upload_form, multipart: true do |f|
  f.file(:avatar, accept: "image/*")
  f.submit("Upload")
end
```

File fields render `type="file"`, `name`, and `id`, but never render a `value`
from the form model. Browsers do not repopulate file inputs after validation
errors.
