# Handler Patterns

Handlers should make command-side behavior easy to read from top to bottom:
resolve dependencies, check business preconditions, apply effects, and publish
events.

For the conceptual overview, see [Handlers](../handlers.md).

## Organization

Organize a handler around a cohesive domain concept or workflow, not
automatically around one message type.

```ruby
class TaskHandler < Lucid::Handler
  perform AssignTask do |cmd|
    # ...
  end

  perform CompleteTask do |cmd|
    # ...
  end
end
```

Split a handler when the commands no longer belong to the same workflow.

Most handlers should use this shape:

1. `perform` blocks for the commands the handler owns
2. `use` declarations for injected external collaborators
3. `with_*` methods for records or other internally resolved data
4. `when_*` methods for boolean business preconditions
5. helper methods only when a write or lookup is genuinely non-trivial

## Recruiting Handlers

Use `recruit` when a feature or module needs one public handler while concrete
handlers keep ownership of smaller workflows.

```ruby
module Tasks
  class AssignmentHandler < Lucid::Handler
    perform AssignTask do |cmd|
      # ...
    end
  end

  class CompletionHandler < Lucid::Handler
    perform CompleteTask do |cmd|
      # ...
    end
  end

  class Handler < Lucid::Handler
    recruit AssignmentHandler
    recruit CompletionHandler
  end
end
```

Point application or parent-feature configuration at the module-level handler.
The recruited handlers still own their `perform` blocks, dependencies,
preconditions, writes, and events.

Recruiting also delegates event subscriptions, so a handler that uses
`subscribe` can be composed the same way.

Add a wiring spec for each command that must be reachable through the recruited
handler chain. Behavior specs for `AssignmentHandler` prove the workflow works;
they do not prove `Tasks::Handler` can dispatch `AssignTask`.

## Dependency Injection

Use `use` for collaborators supplied by the request container, such as services,
gateways, clients, adapters, or other external dependencies.

```ruby
class TaskHandler < Lucid::Handler
  use :task_notifier, Types.instance(TaskNotifier)
end
```

Do not use `use` for records loaded from application persistence. Resolve those
inside the handler with `with_*` methods.

For the type helpers accepted by `use`, see [Types](types.md).

## Dependency Resolution

Use `with_*` methods for records and other internally managed data that comes
from command input.

```ruby
perform AssignTask do |cmd|
  with_task(cmd) do |task|
    with_user(cmd[:user_id]) do |user|
      task.update!(assignee: user)
      publish TaskAssigned.new(
        task_id: task.id,
        user_id: user.id
      )
    end
  end
end

def with_task(cmd)
  if (task = Task.find_by(id: cmd[:task_id]))
    yield task
  else
    publish PreconditionFailed.new(message: "Task not found.")
  end
end
```

Keep each resolver focused on one dependency. Yield the resolved object, not the
original command or method arguments.

Prefer nil checks over exception-based control flow when a missing record is an
expected failure. Expected failures should publish specific error events instead
of leaking raw exceptions as the handler contract.

## Preconditions

Use `when_*` methods for business rules that hinge on a predicate.

```ruby
def when_open(task)
  if task.open?
    yield
  else
    publish PreconditionFailed.new(message: "Task is not open.")
  end
end
```

Predicate wrappers usually yield without arguments. Put them inside the
dependency wrappers that provide the data they need.

```ruby
perform AssignTask do |cmd|
  with_task(cmd) do |task|
    with_user(cmd[:user_id]) do |user|
      when_open(task) do
        task.update!(assignee: user)
        publish TaskAssigned.new(
          task_id: task.id,
          user_id: user.id
        )
      end
    end
  end
end
```

## Compound Preconditions

When a handler has several boolean checks in a row, prefer a compound
`when_*` method if the checks describe one business concept and can share one
failure event.

```ruby
perform AssignTask do |cmd|
  with_task(cmd) do |task|
    with_user(cmd[:user_id]) do |user|
      when_assignable(task, user) do
        task.update!(assignee: user)
        publish TaskAssigned.new(
          task_id: task.id,
          user_id: user.id
        )
      end
    end
  end
end

def when_assignable(task, user)
  if task.open? && user.active? && !task.assignment_locked?
    yield
  else
    publish PreconditionFailed.new(message: "Task cannot be assigned.")
  end
end
```

Name the compound predicate around the business rule, not the individual
conditions. `when_assignable` is easier to read than nesting
`when_open`, `when_user_active`, and `when_assignment_unlocked` when those
checks all answer the same question.

You can also condense repeated dependency and precondition nesting into a
compound `with_*` method. Keep the lower-level wrappers, but compose them in a
business-named method so the `perform` block stays focused on the write.

```ruby
perform AssignTask do |cmd|
  with_assignable_task(cmd) do |task, user|
    task.update!(assignee: user)
    publish TaskAssigned.new(
      task_id: task.id,
      user_id: user.id
    )
  end
end

def with_assignable_task(cmd)
  with_task(cmd) do |task|
    with_user(cmd[:user_id]) do |user|
      when_assignable(task, user) do
        yield task, user
      end
    end
  end
end
```

Use this shape when the nested checks are reused or when the main workflow is
hard to scan. The compound wrapper should still yield only resolved domain
objects and should not perform the mutation itself.

Do not combine predicates that need distinct failure events, different recovery
paths, or separate approval coverage. In those cases, keep separate `when_*`
wrappers, or make the compound method choose and publish a specific failure
event for the first failed rule.

## Writes and Events

Keep the mutation and success event in the innermost block, after dependencies
and preconditions have passed.

Use transactions for multi-record writes:

```ruby
perform CreateProject do |cmd|
  with_workspace(cmd) do |workspace|
    with_owner(cmd[:owner_id]) do |owner|
      when_project_creation_allowed(workspace) do
        ActiveRecord::Base.transaction do
          project = create_project(cmd, workspace, owner)
          first_task = create_first_task(cmd, project)
          publish ProjectCreated.new(
            project_id: project.id,
            workspace_id: workspace.id,
            owner_id: owner.id,
            first_task_id: first_task.id
          )
        end
      end
    end
  end
end
```

Prefer bang methods such as `create!` and `update!` when persistence failure
should abort the write path.

Keep event construction inline unless the payload is large enough that it
obscures the workflow. Extract helper methods only when they improve readability
in a concrete way.

## Process Managers

Use process managers when one completed workflow should decide whether to start
another command workflow.

A command handler should own the command it performs. Its `perform` block should
resolve dependencies, check preconditions, apply the write, and publish events
that describe what happened. It should not directly dispatch another command.

```ruby
class ProjectHandler < Lucid::Handler
  perform CreateProject do |cmd|
    with_workspace(cmd) do |workspace|
      project = workspace.projects.create!(name: cmd[:name])

      publish ProjectCreated.new(
        project_id: project.id,
        workspace_id: workspace.id,
        creator_id: cmd[:creator_id]
      )
    end
  end
end
```

A process manager listens to those events with `subscribe` and decides which
command messages, if any, should be dispatched next.

```ruby
class ProjectSetupProcess < Lucid::Handler
  subscribe ProjectCreated do |event|
    dispatch CreateFirstTask.new(
      project_id: event[:project_id],
      creator_id: event[:creator_id]
    )

    dispatch NotifyProjectCreated.new(
      project_id: event[:project_id],
      workspace_id: event[:workspace_id]
    )
  end
end
```

This keeps command handlers focused on facts they can prove and keeps workflow
coordination in one place. The event becomes the contract between the completed
write and any follow-up behavior.

Use a process manager when:

- follow-up work depends on an event rather than direct user input
- one event may fan out to multiple commands
- the follow-up decision has its own business rules
- the workflow should be easy to extend without editing the original command
  handler

Keep process managers thin. They should inspect the event, apply coordination
rules, and dispatch command messages. They should not duplicate the persistence
write owned by the command handler, and they should not reach into another
handler's private helpers.

Avoid dispatching commands directly from `perform` blocks:

```ruby
perform CreateProject do |cmd|
  project = Project.create!(name: cmd[:name])
  dispatch CreateFirstTask.new(project_id: project.id)
end
```

Publish an event instead, then coordinate follow-up work from a subscriber:

```ruby
perform CreateProject do |cmd|
  project = Project.create!(name: cmd[:name])
  publish ProjectCreated.new(project_id: project.id)
end
```

## Testing

Use handler specs to verify behavior, not implementation details.

The testing helpers in this section are provided by the companion `lucid-rspec`
gem, not by `lucid` itself. Add `lucid-rspec` to your test bundle and require
`lucid/rspec` before using `verify_handler`, `provide`, or the `perform`
matcher.

Test each scenario with `verify_handler`:

```ruby
it "assigns the task and publishes an assigned event" do
  message = AssignTask.new(
    task_id: task.id,
    user_id: user.id
  )

  verify_handler TaskHandler, message, classes: [Task]
end
```

Pass every model class the handler may create, update, or delete in `classes:`
so approval output captures the full effect surface.

When a handler declares an injected collaborator with `use`, provide it in the
spec with `provide`:

```ruby
provide(:task_notifier) { instance_double(TaskNotifier, task_assigned: true) }
```

Do not define the same collaborator with both `provide` and `let`.

For handlers that own multiple command types, group scenarios by message class:

```ruby
describe TaskHandler, type: :handler do
  describe AssignTask do
    # scenarios
  end

  describe CompleteTask do
    # scenarios
  end
end
```

When a new command must be reachable through a module-level handler, add a
wiring spec with the `perform` matcher:

```ruby
describe Handler do
  subject { described_class }

  it { is_expected.to perform AssignTask }
end
```

That wiring spec proves the command is recruited. Behavior specs for a concrete
handler do not prove the command is reachable through the full handler chain.

## Scenario Coverage

Cover the paths that define the handler contract:

- the happy path
- meaningful input or state variations
- idempotent or transition behavior
- invalid references for each `with_*` dependency
- business-rule failures for each meaningful `when_*` precondition
- collaborator-driven behavior when the handler uses `use`

Each scenario should have one example and one `verify_handler` call.

## Anti-Patterns

Avoid:

- resolving records with `use`
- mixing dependency resolution into the mutation block
- using exceptions for expected missing-record paths
- testing private handler methods directly
- dispatching commands directly from `perform` blocks instead of publishing
  events and coordinating follow-up work from `subscribe` blocks
- wrapping `verify_handler` in extra assertions for normal behavior coverage
- omitting module wiring coverage for newly recruited commands
