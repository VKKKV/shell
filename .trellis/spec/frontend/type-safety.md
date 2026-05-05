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

---

## Forbidden Patterns

- Do not pass raw command output to modules for parsing.
- Do not rely on optional object fields in delegates without defaults or `required property` declarations.
- Do not store durable user settings in ad-hoc QML files outside `SettingsService.qml` and the Zig helper contract.
