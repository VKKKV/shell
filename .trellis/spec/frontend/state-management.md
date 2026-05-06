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
- `services/HyprlandService.qml` owns Hyprland workspace availability/occupancy state.
- `services/NiriService.qml` owns Niri command probing, workspace/window JSON parsing, and action dispatch.
- `services/CompositorService.qml` owns the shared QML-facing compositor contract and selects Hyprland first, then Niri, then fallback.
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

## Scenario: Multi-Compositor Workspace Contract

### 1. Scope / Trigger

- Trigger: adding a compositor beyond Hyprland, starting with planned Niri support.
- Applies to: workspace switching, active window telemetry, current workspace window lists, compositor status lines, and command/focus actions consumed by HUD modules.
- This is a cross-service boundary because compositor-specific command/API behavior must be hidden behind stable QML-facing shaped state.

### 2. Signatures

- Shared QML-facing service state:
  - `available: bool`
  - `compositorName: string`
  - `statusLine: string`
  - `activeWorkspace: int|string`
  - `workspaces: var` where each row has `{ id, label, active, occupied }`.
  - `activeWindowClass: string`
  - `activeWindowTitle: string`
  - `currentWorkspaceWindows: var` where each item has `{ appClass, title, active }`.
- Shared QML-facing actions:
  - `switchWorkspace(workspaceId): void`
  - `focusWindow(windowKey): void`
- Existing Hyprland-specific service: `services/HyprlandService.qml`.
- Niri implementation adapts through `services/NiriService.qml`, consumed only by the shared compositor facade.

### 3. Contracts

- HUD modules must consume the shared compositor contract, not compositor-specific commands or imports.
- Compositor-specific parsing belongs in `services/`, never in `modules/hud/` or `components/`.
- Missing compositor support must produce readable fallback values such as `compositor: fallback`, empty window lists, and inactive workspace rows.
- Workspace switch/focus actions must be no-op safe when the target compositor is unavailable.
- Niri support uses documented local commands in `docs/niri.md`: `niri msg --json workspaces`, `niri msg --json windows`, `niri msg action focus-workspace <id>`, and `niri msg action focus-window --id <window-id>`.

### 4. Validation & Error Matrix

- Hyprland available -> shared state mirrors Hyprland workspace/window telemetry.
- Niri available and Hyprland unavailable -> shared state mirrors Niri workspace/window telemetry through the same fields.
- No supported compositor -> `available = false`, fallback status line, no thrown QML binding errors.
- Command missing -> service logs warning/fallback and keeps shaped default values.
- Workspace/focus action called while unavailable -> no-op with status/log update, no uncaught process error.
- HUD module imports compositor-specific API directly -> fail review; violates service boundary.

### 5. Good/Base/Bad Cases

- Good: `TopStatusBar.qml` renders `CompositorService.workspaces` and does not know whether Hyprland, Niri, or fallback produced the rows.
- Base: during migration, `HyprlandService.qml` may remain the backing implementation if the facade contract is already documented and consumers are being moved intentionally.
- Bad: adding `if niri` branches or shell command parsing inside `TopStatusBar.qml`, `MissionDock.qml`, or `CommandCenterOverviewColumn.qml`.

### 6. Tests Required

- QML lint: `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`.
- Runtime smoke: `timeout 8s quickshell -p .` must show `Configuration Loaded` without startup QML errors.
- Fallback assertion: run or reason through startup without a supported compositor command and confirm status lines/window lists stay readable.
- Action assertion: workspace/focus actions should not throw when unavailable.
- Manual compositor assertion when available: active workspace and active window text update after switching/focusing.

### 7. Wrong vs Correct

#### Wrong

```qml
// Inside a HUD module
Process { command: ["niri", "msg", "workspaces"] }
```

#### Correct

```qml
// Inside a HUD module
Repeater {
    model: CompositorService.workspaces
}
```

The compositor-specific command parsing stays in `services/`, behind the shared shaped state contract.
