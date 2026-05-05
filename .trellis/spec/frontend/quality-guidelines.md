# Quality Guidelines

> Code quality standards for frontend development.

---

## Overview

Quality is measured by runtime cleanliness, small vertical slices, clear service boundaries, and preserving the target tactical visual language. The shell should remain reloadable during development and should degrade safely when optional commands or hardware are unavailable.

---

## Forbidden Patterns

- Do not run shell commands or parse external output inside `components/`.
- Do not put polling/parsing logic directly in `modules/hud/` unless it is an explicitly temporary spike.
- Do not scatter core colors, line widths, spacing, or typography outside `theme/Theme.qml`.
- Do not add plugin registries, dynamic widget ordering, or large abstractions before multiple first-party features prove the need.
- Do not copy large blocks or visual language directly from reference shells.
- Do not let fallback failures render blank panels or raw command errors as normal UI.
- Do not grow `HudLayout.qml` with unrelated feature internals; extract a module or command-center column.

---

## Required Patterns

- Keep `shell.qml` thin and delegate visible UI to `modules/hud/`.
- Register importable QML files in the matching `qmldir`.
- Keep reusable visuals in `components/` presentation-only.
- Keep shared state, polling, command execution, parsing, and fallback strings in `services/`.
- Use `Theme.qml` for repeated tactical styling values.
- Add feature work as a small vertical slice with visible UI, service boundary, fallback behavior, validation, and journal/plan update.
- Prefer conservative polling intervals and respect `SettingsService.liveDataEnabled` for live external reads.

---

## Testing Requirements

- Run `qmllint` when available after QML changes.
- Run `zig build` after Zig helper changes.
- Run `quickshell -p .` for runtime checks when a display/session is available.
- Run `git diff --check` before a checkpoint.
- For service integrations, smoke-test missing-command or no-hardware fallback paths when feasible.

---

## Code Review Checklist

- Does the change preserve the `components`/`modules`/`services`/`theme` boundary?
- Are external commands isolated in services or Zig helpers?
- Are fallback states readable and non-spammy?
- Are new visual constants centralized or clearly local one-offs?
- Does the feature match the hard-edged tactical HUD style rather than generic Material-style widgets?
- Are `qmldir`, docs, and the task journal updated when a new importable file or feature slice is added?
