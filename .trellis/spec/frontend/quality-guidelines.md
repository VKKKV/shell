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
- Do not leave repeated control rows copy-pasted across a settings surface when they share the same layout and behavior; extract a small presentation component instead.
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

## Scenario: Phase Checkpoint Verification And Git Handoff

### 1. Scope / Trigger

- Trigger: completing any coherent development phase or optimization slice in this project.
- Applies to: feature slices, refactors, bug fixes, spec updates that conclude a phase, and visual optimization passes.

### 2. Signatures

- QML lint command: `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`.
- Zig build command: `zig build`.
- Whitespace check command: `git diff --check`.
- Runtime smoke command: `timeout 5s quickshell -p .`.
- Git checkpoint commands: `git status --short`, `git diff`, `git add <relevant files>`, `git commit -m "type(scope): message"`, `git push`.

### 3. Contracts

- A phase is not complete until verification has run, task docs or journal are updated, a commit is created, and push is attempted.
- Commit only relevant files for the completed phase; do not stage unrelated user/agent changes.
- Use repository commit style from recent history: `feat(scope): ...`, `fix(scope): ...`, `docs: ...`, or `chore(scope): ...`.
- Push after the commit unless verification failed or remote push is blocked.
- If push fails, keep the local commit and report the exact blocker.

### 4. Validation & Error Matrix

- `qmllint` fails -> fix QML issues before commit, or report blocker if not fixable in scope.
- `zig build` fails after Zig/helper changes -> fix before commit.
- `git diff --check` fails -> fix whitespace before commit.
- `quickshell -p .` cannot run because no display/session is available -> record as skipped with reason; do not fabricate success.
- `git push` rejected or no remote configured -> report blocker and leave the local commit intact.

### 5. Good/Base/Bad Cases

- Good: QML refactor runs `qmllint`, `git diff --check`, smoke check, updates journal, commits, then pushes.
- Base: Markdown-only spec update runs `git diff --check`, updates journal, commits, then pushes; QML/Zig/runtime checks can be skipped only if clearly irrelevant.
- Bad: changes are implemented across multiple files, but no journal update, no verification record, and no commit/push checkpoint.

### 6. Tests Required

- For QML changes: assert `qmllint` exits 0 and Quickshell logs include `Configuration Loaded` during smoke check.
- For Zig changes: assert `zig build` exits 0.
- For all committed phases: assert `git diff --check` exits 0 before commit.
- For git handoff: assert `git status --short` after commit/push is clean or only contains intentionally uncommitted unrelated files.

### 7. Wrong vs Correct

#### Wrong

```bash
git add .
git commit -m "update"
```

This stages unrelated files, skips verification, uses a vague message, and does not push.

#### Correct

```bash
qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml
zig build
git diff --check
timeout 5s quickshell -p .
git status --short
git add .trellis/spec/frontend/component-guidelines.md modules/hud/CpuExpansionPanel.qml
git commit -m "refactor(hud): standardize central panel chrome"
git push
```

Adjust the verification commands to the files touched, and record skipped checks with the reason.

---

## Code Review Checklist

- Does the change preserve the `components`/`modules`/`services`/`theme` boundary?
- Are external commands isolated in services or Zig helpers?
- Are fallback states readable and non-spammy?
- Are new visual constants centralized or clearly local one-offs?
- Does the feature match the hard-edged tactical HUD style rather than generic Material-style widgets?
- Are `qmldir`, docs, and the task journal updated when a new importable file or feature slice is added?
