# Type Safety

> Type safety patterns in this project.

---

## Overview

The frontend uses QML typed properties plus JavaScript for local shaping/parsing. Durable validation is handled by focused Zig helpers when needed. There is no TypeScript layer.

---

## Type Organization

- Prefer explicit QML properties: `property bool`, `property int`, `property real`, `property string`, `property var`.
- Use `required property` for delegate data that must exist.
- Keep visual component props simple and already formatted when possible.
- Keep shaped service outputs stable, such as `rows`, `statusLine`, `displayText`, and progress values in `0..1` or `-1` for unavailable.
- Document durable JSON contracts in `docs/` and implement normalization in Zig helpers.

---

## Validation

- QML services validate parsed command output before updating display state.
- QML settings clamp immediate UI values before scheduling persistence.
- Zig helpers validate durable JSON, clamp numeric ranges, drop unsupported values, and print normalized JSON.
- External service failures should update explicit fallback values instead of throwing through bindings.

---

## Common Patterns

- Use small normalization functions near the service state they protect, such as `normalizeThemeProfile`, `clampIntensity`, or parser update functions.
- Use `property var` for arrays/objects consumed by repeaters, but keep their shape consistent.
- Use string display fields like `displayText` and `statusLine` when multiple modules need the same formatted fallback text.

## Scenario: Persistent Appearance Controls

### 1. Scope / Trigger

- Trigger: adding or changing persistent appearance settings that affect global typography, panel surfaces, or scanline overlays.
- Applies to: `visual.fontScale`, `visual.panelOpacity`, and `visual.scanlineStrength` in `SettingsService.qml`, `Theme.qml`, `src/settings/main.zig`, `docs/settings.md`, and command-center settings controls.
- This is a cross-layer contract because QML owns live UI state while Zig owns durable JSON normalization.

### 2. Signatures

- QML setting: `SettingsService.fontScale: real`.
- QML clamp: `SettingsService.clampFontScale(value: real): real`.
- Theme consumers: `Theme.fontTiny`, `Theme.fontSmall`, `Theme.fontNormal`, `Theme.fontLarge`, `Theme.fontClock` derive from `Theme.scaledFont(base: int): int`.
- Durable JSON field: `visual.fontScale: number`.
- Durable JSON field: `visual.panelOpacity: number`.
- Durable JSON field: `visual.scanlineStrength: number`.
- Durable JSON field: `visual.borderOpacity: number`.
- Durable JSON field: `visual.dimTextOpacity: number`.
- Durable JSON field: `visual.lineContrast: number`.
- Zig setting field: `Settings.font_scale: f64`.
- Zig setting field: `Settings.panel_opacity: f64`.
- Zig setting field: `Settings.scanline_strength: f64`.
- Zig setting field: `Settings.border_opacity: f64`.
- Zig setting field: `Settings.dim_text_opacity: f64`.
- Zig setting field: `Settings.line_contrast: f64`.
- Zig helper commands: `void-shell-settings defaults`, `void-shell-settings read`, `void-shell-settings write '<json>'`.

### 3. Contracts

- Default value is `1.0`, preserving existing typography size.
- Valid persisted range is `0.85..1.25`.
- `visual.panelOpacity` default is `0.8`, preserving the existing `#cc030303` panel opacity.
- `visual.panelOpacity` range is `0.55..0.95`.
- `visual.scanlineStrength` default is `1.0`, preserving existing scanline intensity.
- `visual.scanlineStrength` range is `0.25..1.75`.
- `visual.borderOpacity` default is `1.0`, preserving the existing `#333333` border appearance.
- `visual.borderOpacity` range is `0.35..1.0`.
- `visual.dimTextOpacity` default is `1.0`, preserving the existing secondary text appearance.
- `visual.dimTextOpacity` range is `0.45..1.0`.
- `visual.lineContrast` default is `1.0`, preserving the selected accent color.
- `visual.lineContrast` range is `0.65..1.35`.
- QML must clamp immediate UI writes before scheduling persistence.
- Zig must clamp persisted input and emit normalized JSON.
- `Theme.qml` is the only place that multiplies base font sizes by `fontScale`; individual panels should keep using theme font properties.
- `Theme.qml` is the only place that derives global tactical panel colors from `panelOpacity`; individual panels should keep using `Theme.panel`/`Theme.panelSoft`.
- `Theme.qml` is the only place that derives `Theme.border`, `Theme.textDim`, `Theme.line`, and `Theme.lineDim` from fine appearance controls.
- Existing `ScanlineOverlay` call sites should multiply their base opacity by `SettingsService.scanlineStrength`; `scanlinesEnabled` remains the on/off switch.
- Settings UI should adjust `fontScale` in small steps and show the current percent value.

### 4. Validation & Error Matrix

- Missing `visual.fontScale` -> QML and Zig use default `1.0`.
- `visual.fontScale < 0.85` -> clamp to `0.85`.
- `visual.fontScale > 1.25` -> clamp to `1.25`.
- Non-number `visual.fontScale` -> ignore and keep/default current normalized value.
- `visual.panelOpacity < 0.55` -> clamp to `0.55`.
- `visual.panelOpacity > 0.95` -> clamp to `0.95`.
- `visual.scanlineStrength < 0.25` -> clamp to `0.25`.
- `visual.scanlineStrength > 1.75` -> clamp to `1.75`.
- `visual.borderOpacity < 0.35` -> clamp to `0.35`.
- `visual.borderOpacity > 1.0` -> clamp to `1.0`.
- `visual.dimTextOpacity < 0.45` -> clamp to `0.45`.
- `visual.dimTextOpacity > 1.0` -> clamp to `1.0`.
- `visual.lineContrast < 0.65` -> clamp to `0.65`.
- `visual.lineContrast > 1.35` -> clamp to `1.35`.
- Panel hard-codes new font sizes after this contract -> fail review; use `Theme.font*` instead.
- Panel hard-codes global panel background alpha after this contract -> fail review; use `Theme.panel` or `Theme.panelSoft` instead.
- Scanline call site ignores `SettingsService.scanlineStrength` -> fail review unless the overlay is explicitly decorative and not user-facing.
- Settings-helper test writes without temp `XDG_CONFIG_HOME` -> risky; may alter the user's live settings.

### 5. Good/Base/Bad Cases

- Good: settings column changes `SettingsService.fontScale`, `Theme.fontNormal` updates globally, Zig writes normalized `visual.fontScale`.
- Good: settings column changes `SettingsService.panelOpacity`, `Theme.panel` updates globally, panels keep using `Theme.panel`.
- Good: settings column changes `SettingsService.scanlineStrength`, existing scanline overlays get stronger/weaker while the toggle still disables them.
- Good: settings column changes fine contrast settings, and existing panels update through `Theme.border`, `Theme.textDim`, `Theme.line`, and `Theme.lineDim`.
- Base: a visual-only component uses `Theme.fontTiny`/`Theme.fontNormal` and automatically inherits scaling.
- Bad: a panel implements its own `property int localFontSize` and bypasses `Theme.qml`, causing inconsistent scaling.

### 6. Tests Required

- QML: run `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`.
- Zig: run `zig build`.
- Settings contract: run helper `defaults` and `write` clamp checks with a temporary `XDG_CONFIG_HOME`, asserting all `visual.*` appearance fields appear and clamp to their documented ranges.
- Runtime: run a short `quickshell -p .` smoke check and verify startup has no QML errors.
- Whitespace: run `git diff --check`.

### 7. Wrong vs Correct

#### Wrong

```qml
Text {
    font.pixelSize: 17
}
```

This bypasses global font scaling.

#### Correct

```qml
TacticalLabel {
    size: Theme.fontNormal
}
```

The label now tracks `SettingsService.fontScale` through `Theme.qml`.

---

## Forbidden Patterns

- Do not pass raw command output to modules for parsing.
- Do not rely on optional object fields in delegates without defaults or `required property` declarations.
- Do not store durable user settings in ad-hoc QML files outside `SettingsService.qml` and the Zig helper contract.
