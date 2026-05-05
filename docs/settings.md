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
    "intensity": 1.0,
    "profile": "amber"
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
- `visual.profile` is one of `amber`, `green`, `blue`, or `red`.
- `data.liveDataEnabled` is boolean.
- `data.updateIntervalMs` is clamped to `1000..30000`.
- panel visibility fields are booleans.
- Unknown fields are currently dropped by the Zig helper during normalization. Preserving unknown fields is a future compatibility improvement.

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

## Build From Source

```bash
zig build
```

The installed binary is written under `zig-out/bin/void-shell-settings`.

Quick checks:

```bash
zig build
./zig-out/bin/void-shell-settings defaults
./zig-out/bin/void-shell-settings read
```

The initial helper is intentionally small. `read` falls back to defaults when no settings file exists. `write` validates and normalizes known fields, clamps numeric values, writes the normalized JSON, and prints the normalized JSON to stdout.

## QML Boundary

`SettingsService.qml` remains the presentation-facing state owner. The Zig helper should only persist, validate, and normalize settings data.
