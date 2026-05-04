# Quality Guidelines

> Code quality standards for backend development.

---

## Overview

Backend in this project currently means helper binaries and persistence/normalization logic, with Zig as the preferred implementation language.

Current backend surface:

- `src/settings/main.zig`
- `build.zig`

---

## Forbidden Patterns

- Writing arbitrary JSON payloads directly to disk without normalization.
- Moving persistence-sensitive logic into random QML modules.
- Introducing a helper binary before the QML-side contract is defined.
- Making helper failure fatal for shell startup when safe defaults exist.

---

## Required Patterns

- Backend helpers must accept a simple CLI contract and print machine-readable JSON on stdout.
- Validation/clamping belongs in the backend helper for durable settings.
- QML should treat helper errors as recoverable and keep safe defaults active.
- Build artifacts must be gitignored (`.zig-cache/`, `zig-out/`).

---

## Testing Requirements

Current required checks for backend changes:

- `zig build`
- direct CLI smoke tests for helper commands (`defaults`, `read`, `write`)
- `qmllint` and `quickshell -p .` after QML-side wiring changes

Example contract checks already used:

- `./zig-out/bin/void-shell-settings defaults`
- `./zig-out/bin/void-shell-settings read`
- `./zig-out/bin/void-shell-settings write '<json>'`

---

## Code Review Checklist

- Does the helper normalize and clamp inputs instead of trusting them?
- Does stdout stay JSON and stderr stay human-readable diagnostics?
- Is the config path explicit and documented?
- Can QML survive helper failure without startup breakage?
