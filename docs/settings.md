# Settings Contract

This document defines the first persistent settings contract for the tactical shell.

The current QML implementation keeps settings in `services/SettingsService.qml`. Persistence is intentionally not implemented yet; this contract defines what a future helper should read/write.

## Location

Recommended config path:

```text
$XDG_CONFIG_HOME/void-shell/settings.json
```

Fallback if `XDG_CONFIG_HOME` is unset:

```text
~/.config/void-shell/settings.json
```

## JSON Shape

```json
{
  "version": 1,
  "visual": {
    "scanlinesEnabled": true,
    "intensity": 1.0
  },
  "data": {
    "liveDataEnabled": true,
    "updateIntervalMs": 5000
  },
  "panels": {
    "leftVisible": true,
    "centerVisible": true,
    "rightVisible": true
  }
}
```

## Validation Rules

- `version` must be `1` for this initial contract.
- `visual.scanlinesEnabled` is boolean.
- `visual.intensity` is clamped to `0.5..1.5`.
- `data.liveDataEnabled` is boolean.
- `data.updateIntervalMs` is clamped to `1000..30000`.
- panel visibility fields are booleans.
- Unknown fields should be preserved by a backend helper when possible.

## Zig Helper Plan

Prefer Zig for the persistence helper once QML live state is stable.

Candidate binary:

```text
void-shell-settings
```

Initial commands:

```bash
void-shell-settings read
void-shell-settings write '<json-payload>'
void-shell-settings defaults
```

Output should be JSON on stdout and human-readable diagnostics on stderr. QML should treat helper failure as non-fatal and keep safe defaults.

## QML Boundary

`SettingsService.qml` remains the presentation-facing state owner. The Zig helper should only persist, validate, and normalize settings data.
