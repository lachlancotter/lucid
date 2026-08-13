# Features

Lucid applications are organized around product behavior rather than framework
layers.

That means a feature should keep its messages, handlers, components, policies,
and supporting code close to the workflow they describe. The goal is for the
shape of the codebase to follow the shape of the application, not the internal
categories of a request cycle.

## Why Features Come First

Messages become the vocabulary of a Lucid application. When those messages live
near the handlers and components that use them, a feature can be understood as a
single product capability instead of a set of coordinated edits across routes,
controllers, templates, and service objects.

Feature-oriented organization helps because:

- interaction vocabulary stays near the UI and behavior it supports
- command handlers live near the command messages they process
- components stay close to the view state they own
- policies and supporting services can be scoped to the workflow they protect
- refactors follow product boundaries instead of technical layers

## Core and Features

The internal loader is designed around two broad areas:

- `core/` for shared application code
- `features/` for feature-specific code and feature entrypoints

Use `core/` for code that is genuinely shared across the application, such as
base policies, shared components, cross-cutting services, and application-wide
helpers.

Use `features/<feature_name>/` for code that belongs to a product workflow or
capability.

## Feature Entrypoints

Feature entrypoint files can live directly under `features/` so modules and
message classes are defined before the feature directories are autoloaded.

Those entrypoints are an important part of the model. They give each feature a
clear place to define its message vocabulary before the implementation details
are loaded.

## Relationship to Architecture

Feature organization supports the runtime architecture, but it is not the same
topic.

Architecture explains how requests, messages, handlers, components, state, and
rendering fit together at runtime. Feature organization explains how those
pieces should be arranged so the code remains understandable as the product
grows.
