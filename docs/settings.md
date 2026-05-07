# Settings Contract

This document defines the first persistent settings contract for the tactical shell.

The current QML implementation keeps presentation-facing settings in `services/SettingsService.qml`. Persistence is implemented by the Zig helper `void-shell-settings`, which reads, writes, validates, and normalizes this contract.

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
      "fontScale": 1.0,
      "panelOpacity": 0.8,
      "scanlineStrength": 1.0,
      "borderOpacity": 1.0,
      "dimTextOpacity": 1.0,
      "lineContrast": 1.0,
      "density": "normal",
      "profile": "amber",
    "accentColor": "#F2C94C",
    "backgroundMode": "void"
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

- `version` is normalized to `1` for missing or older settings payloads.
- Future versions greater than `1` are treated as unsupported; `read` falls back to defaults instead of passing an unknown schema to QML.
- `visual.scanlinesEnabled` is boolean.
- `visual.intensity` is clamped to `0.5..1.5`.
- `visual.fontScale` is clamped to `0.85..1.25` and drives global QML theme font sizes.
- `visual.panelOpacity` is clamped to `0.55..0.95` and drives tactical panel background opacity.
- `visual.scanlineStrength` is clamped to `0.25..1.75` and multiplies enabled scanline overlays.
- `visual.borderOpacity` is clamped to `0.35..1.0` and drives global border opacity.
- `visual.dimTextOpacity` is clamped to `0.45..1.0` and drives secondary text opacity.
- `visual.lineContrast` is clamped to `0.65..1.35` and adjusts the accent line color contrast.
- `visual.density` is one of `compact`, `normal`, or `dense` and drives coarse QML layout density.
- `visual.profile` is one of `amber`, `green`, `blue`, or `red`.
- `visual.accentColor` is a hex RGB color (`#RRGGBB`) and defaults to `#F2C94C`.
- `visual.backgroundMode` is one of `void`, `grid`, or `radar`.
- `data.liveDataEnabled` is boolean.
- `data.updateIntervalMs` is clamped to `1000..30000`.
- panel visibility fields are booleans.
- Unknown fields are currently dropped by the Zig helper during normalization. Preserving unknown fields is a future compatibility improvement.

## Zig Helper

Zig owns persistence because settings are durable state and should not be written directly from random QML modules.

Binary:

```text
void-shell-settings
```

Commands:

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

The helper is intentionally small. `read` falls back to defaults when no settings file exists or when an existing file has an invalid/unsupported schema. `write` validates and normalizes known fields, clamps numeric values, migrates missing/old versions to the current version, writes the normalized JSON, and prints the normalized JSON to stdout.

Tests:

```bash
zig build test
```

## QML Boundary

`SettingsService.qml` remains the presentation-facing state owner. The Zig helper should only persist, validate, and normalize settings data.
