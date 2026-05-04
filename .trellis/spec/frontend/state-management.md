# State Management

> How state is managed in this project.

---

## Overview

This project uses QML singletons in `services/` as the primary state boundary.

- UI modules in `modules/hud/` should read state from services.
- Reusable visuals in `components/` should stay presentation-only.
- Durable or normalized backend state should move to Zig helpers under `src/` when QML-only logic becomes too shell-command-heavy or persistence-sensitive.

Current examples:

- `services/Time.qml` owns live clock state.
- `services/SystemStats.qml` owns CPU, memory, network, and filesystem polling state.
- `services/HyprlandService.qml` owns workspace availability/occupancy state.
- `services/SettingsService.qml` owns in-session settings state.
- `src/settings/main.zig` owns normalized settings persistence behavior.

---

## State Categories

### Local UI State

Keep state local when it only affects one visual surface.

Examples:

- hover state inside `TopStatusBar.qml`
- transient visibility/opacity inside a single component

### Shared Session State

Promote state to `services/*.qml` when multiple modules need the same value.

Examples:

- current time
- workspace state
- global settings toggles
- live system metrics

### Durable State

Durable state should not be written directly from random QML modules.

Current rule:

- QML owns the active settings values.
- Zig helper `void-shell-settings` owns settings read/write normalization.

---

## When to Use Global State

Use a QML singleton in `services/` when at least one is true:

- the same value is read by 2+ HUD modules
- the value is backed by an external source (`/proc`, Hyprland, helper binary)
- updates need polling, command execution, or fallback handling
- a settings change should affect multiple panels at once

Do not create a service just to avoid passing one or two visual props.

---

## Server State

This project currently has no HTTP/server-state layer.

Equivalent external state sources are:

- Hyprland via `Quickshell.Hyprland`
- system files such as `/proc/stat`, `/proc/net/dev`
- shell commands such as `free -b`, `df -B1`
- Zig helper binaries such as `void-shell-settings`

Rules:

- external reads happen in `services/`
- parsing happens in `services/` or Zig helpers, not in `modules/`
- UI modules consume already-shaped values like `cpuRows`, `networkRows`, `statusLine`

---

## Common Mistakes

- putting polling/parsing logic directly in HUD modules
- duplicating fallback logic in multiple QML files
- treating settings as durable before the backend helper writes them
- adding a backend helper before the QML state contract is clear
