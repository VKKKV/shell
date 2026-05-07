# Directory Structure

> How backend code is organized in this project.

---

## Overview

Backend code currently means focused Zig helper binaries for durable or persistence-sensitive behavior. The shell UI and service state live in QML; the backend helper owns settings normalization and filesystem persistence.

Current backend surface:

- `build.zig`: declares helper artifacts and tests
- `src/settings/main.zig`: `void-shell-settings` CLI for settings defaults/read/write

Do not introduce a backend framework, route layer, or daemon unless a concrete shell feature needs it.

---

## Directory Layout

```text
build.zig
src/
└── settings/
    └── main.zig
```

Build artifacts are generated under:

```text
.zig-cache/
zig-out/
```

These must remain uncommitted build outputs.

---

## Module Organization

- Put focused helper binaries under `src/<domain>/main.zig`.
- Keep durable validation and normalization inside the helper when persisted state is involved.
- Keep live UI state and command polling in `services/*.qml`, not in Zig.
- Add a helper only when QML would otherwise own persistence-sensitive behavior or complex command parsing.

---

## Naming Conventions

- Helper executable names use shell-oriented kebab case, such as `void-shell-settings`.
- Zig source directories use lowercase domain names, such as `src/settings/`.
- CLI commands should be short verbs, such as `defaults`, `read`, and `write`.
- stdout is machine-readable JSON; stderr is human-readable diagnostics.

---

## Examples

- `src/settings/main.zig`: normalizes persisted appearance/data/panel settings, creates the config directory, reads/writes `$XDG_CONFIG_HOME/void-shell/settings.json`, and prints normalized JSON.
- `build.zig`: installs `void-shell-settings` and wires `zig build test` through `b.addTest`.

---

## Common Mistakes

- Moving settings persistence into a random QML module instead of `src/settings/main.zig`.
- Adding a long-running backend process when a small helper command is enough.
- Forgetting to add tests in `main.zig` when changing helper validation or filesystem behavior.
