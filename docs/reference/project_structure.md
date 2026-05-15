# Project Structure

Lucid encourages a feature-oriented project layout.

The internal loader is designed around two broad areas:

- `core/` for shared application code
- `features/` for feature-specific code and feature entrypoints

## Core

`core/` is where shared application code lives, such as:

- base policies
- shared components
- cross-cutting services
- application-wide helpers

## Features

Each feature lives under `features/<feature_name>/`.

Feature entrypoint files can also live directly under `features/` so the module
or message classes are defined before the feature directories are autoloaded.

## Why This Layout Exists

The structure reinforces Lucid's design:

- messages and handlers live near the behavior they support
- components stay close to their feature context
- code organization follows product capabilities instead of controller classes
