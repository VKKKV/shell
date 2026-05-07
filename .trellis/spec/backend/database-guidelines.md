# Database Guidelines

> Database patterns and conventions for this project.

---

## Overview

This project currently has no database, ORM, migrations, server API, or query layer. Durable local state is limited to JSON settings persisted by the Zig helper.

Current durable state:

- Settings file: `$XDG_CONFIG_HOME/void-shell/settings.json`
- Fallback settings path: `~/.config/void-shell/settings.json`
- Contract documentation: `docs/settings.md`
- Implementation: `src/settings/main.zig`

---

## Storage Pattern

Use a small normalized JSON file for local shell settings. The helper command contract is:

```bash
void-shell-settings defaults
void-shell-settings read
void-shell-settings write '<json-payload>'
```

Rules:

- `defaults` prints the default JSON contract.
- `read` prints normalized settings or defaults if the file is missing/invalid/unsupported.
- `write` validates and normalizes a payload, writes normalized JSON, then prints the normalized JSON.
- Unknown fields are currently dropped during normalization.

---

## Migrations

There is no migration framework. Settings use a `version` field.

Current behavior:

- missing or old `version` -> normalize to current version
- future `version` -> treat as unsupported and fall back to defaults on read
- changing the persisted shape requires updating `docs/settings.md`, `services/SettingsService.qml`, `src/settings/main.zig`, and helper tests

---

## Naming Conventions

- JSON fields use the existing camelCase contract, such as `visual.fontScale` and `data.updateIntervalMs`.
- Zig struct fields use snake_case equivalents, such as `font_scale` and `update_interval_ms`.
- Settings groups are currently `visual`, `data`, and `panels`.

---

## Common Mistakes

- Treating settings JSON as arbitrary storage without normalization.
- Adding a database just to store a handful of local shell preferences.
- Testing helper `write` against the user's real config path instead of a temporary `XDG_CONFIG_HOME`.
- Updating QML settings fields without updating the Zig helper and `docs/settings.md`.
