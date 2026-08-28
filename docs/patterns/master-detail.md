# Master Detail

Master/detail views show a collection beside the selected record. They are a
good fit when the user needs to scan a list, move between records quickly, and
keep surrounding context visible while inspecting one item.

In Lucid, model the selected record as component state. The list sends a `Link`
message, the component maps that message into a selected ID, and the template
renders the detail area from the current state.

## Shape

A master/detail component usually has:

- a `param` for the selected record ID
- a `Link` message that describes selection intent
- a `to` handler that copies the link ID into component state
- list and detail components declared with `nest`
- a dynamic detail nest selected with a `case` statement
- repeated list rows rendered with `subcomponents`
- detail content rendered with `subcomponent`
- explicit empty and missing-record states

Use a `param` for the selected ID when the selection should survive refresh,
back/forward navigation, or shared URLs.

```ruby
class SelectProject < Lucid::Link
  validate do
    required(:selected_project_id).filled(:integer)
  end
end
```

## Component State

Keep declaration-time APIs in the component class body. Params, nested
components, and link handlers describe the component's state model before any
template runs.

```ruby
class ProjectsManager < Lucid::Component::Base
  param :selected_project_id, Types.integer.optional.default(nil)

  to SelectProject, :selected_project_id

  let(:selected_project) { |selected_project_id| Project.find_by(id: selected_project_id) if selected_project_id }

  nest(:project_list) { ProjectList[:selected_project_id] }
  nest(:project_detail) do |selected_project_id, selected_project|
    case
    when selected_project
      ProjectDetail[project: :selected_project]
    when selected_project_id
      MissingProject[selected_project_id: :selected_project_id]
    else
      NoProjectSelected
    end
  end
end
```

The selected ID is view state, not a mutation. Selecting an item should normally
be a `Link`, not a `Command`. Save commands, deletes, comments, and other
business effects still belong in handlers.

## Template Composition

Use template-time APIs inside `element` and named templates. This keeps markup
composition separate from the class-level declarations that define state and
message handling.

```ruby
class ProjectsManager < Lucid::Component::Base
  element do
    section(class: "master-detail") do
      subcomponent(:project_list)
      subcomponent(:project_detail)
    end
  end
end

class ProjectList < Lucid::Component::Base
  prop :selected_project_id, Types.integer.optional.default(nil)

  let(:projects) { Project.all }

  nest(:project_rows) do
    ProjectListItem[:selected_project_id].enum(:projects, as: :project)
  end

  element do
    nav(class: "master-detail-list") do
      if projects.any?
        subcomponents(:project_rows)
      else
        p { text "No projects yet." }
      end
    end
  end
end

class ProjectListItem < Lucid::Component::Base
  prop :project, Types::Any
  prop :selected_project_id, Types.integer.optional.default(nil)

  key { project.id }

  element do
    link_to(
      SelectProject.new(selected_project_id: project.id),
      class: project.id == selected_project_id ? "selected" : nil
    ) do
      h2 { text project.name }
      p { text project.status }
    end
  end
end

class NoProjectSelected < Lucid::Component::Base
  element do
    article(class: "master-detail-panel") do
      p { text "Select a project to view its details." }
    end
  end
end

class MissingProject < Lucid::Component::Base
  prop :selected_project_id, Types.integer

  element do
    article(class: "master-detail-panel") do
      p { text "Project #{selected_project_id} could not be found." }
    end
  end
end

class ProjectDetail < Lucid::Component::Base
  prop :project, Types::Any

  element do
    article(class: "master-detail-panel") do
      h2 { text project.name }
      p { text project.description }
    end
  end
end
```

The list does not need to know the URL for a project. It names the interaction
with `SelectProject`, and Lucid turns that message plus the resulting component
state into the correct URL and replacement behavior. The manager owns selection
state, passes the selected ID into the list, and chooses the right detail-area
component for the current selection. The list owns the collection query and
markup, each row owns item markup, and each detail-area component only needs the
state it renders.

## Empty And Missing States

Master/detail screens need intentional fallback states:

- no records: render an empty list state and leave the detail panel neutral
- no selection: invite the user to select a record
- stale selection: show that the selected record no longer exists
- first load: optionally select the first record by default when the workflow
  benefits from immediate detail content

Only auto-select the first record when that behavior is stable and unsurprising.
If the selection has meaning in browser history or in a shared link, prefer an
explicit user selection.

## Data And Mutations

Read data in `let` blocks that support rendering. Keep writes and business
effects in command handlers.

That boundary keeps the master/detail component focused on presentation:

- list components query the master collection
- the selected ID chooses the detail record
- `Link` messages update view state
- `Command` messages change domain state through handlers
- published events can refresh or replace affected components after mutations
