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

- Shared QML-facing singleton: `services/CompositorService.qml`.
- Backend singletons:
  - `services/HyprlandService.qml` adapts `Quickshell.Hyprland`.
  - `services/NiriService.qml` adapts local `niri msg` commands.
- Facade state signature:

```qml
readonly property bool available
readonly property string compositorName // "hyprland" | "niri" | "fallback"
readonly property string statusLine
readonly property string backendStatusLine
readonly property string workspaceStatusLine
property string actionStatusLine
readonly property int activeWorkspace
readonly property string activeWindowClass
readonly property string activeWindowTitle
readonly property bool activeWindowAvailable
readonly property var workspaces
readonly property var currentWorkspaceWindows
readonly property var diagnosticRows
function isOccupied(id: int): bool
function switchWorkspace(id: int): void
function focusWindow(windowKey: string): void
```

- Workspace row payload:

```qml
{
    id: number,
    label: string,
    active: boolean,
    occupied: boolean
}
```

- Window row payload:

```qml
{
    windowKey: string,
    appClass: string,
    title: string,
    active: boolean
}
```

- Diagnostics row payload:

```qml
[label: string, status: string]
```

- Backend command/API signatures:
  - Hyprland active workspace: `Hyprland.focusedWorkspace?.id`.
  - Hyprland occupied workspaces: `Hyprland.workspaces?.values`.
  - Hyprland windows: `Hyprland.toplevels?.values`.
  - Hyprland switch: `Hyprland.dispatch("workspace <id>")`.
  - Hyprland focus: `Hyprland.dispatch("focuswindow address:<address>")`.
  - Niri workspaces: `niri msg --json workspaces`.
  - Niri windows: `niri msg --json windows`.
  - Niri switch: `niri msg action focus-workspace <id>`.
  - Niri focus: `niri msg action focus-window --id <window-id>`.

### 3. Contracts

- `CompositorService` selects backends in priority order: Hyprland if available, then Niri if available, otherwise fallback.
- `compositorName` must be one of `hyprland`, `niri`, or `fallback`.
- `workspaces` must always be renderable. Fallback returns five inactive numeric rows.
- `currentWorkspaceWindows` must always be an array. Fallback returns `[]`.
- Niri workspace occupancy is derived from both workspace payload fields and the latest window payload. Preserve raw workspace rows and recompute shaped workspace rows after `niri msg --json windows` updates.
- `windowKey` is the action key, not display text:
  - Hyprland uses `lastIpcObject.address` when available.
  - Niri uses window id from `niri msg --json windows`.
  - Title fallback is allowed only for legacy/malformed rows.
- `diagnosticRows` must include current active backend, Hyprland status, Niri status, workspace summary, action status, and active window identity.
- `actionStatusLine` starts at `action: standby` and updates on workspace/focus dispatch or no-op fallback.
- `ServiceLogService.push("compositor", level, message)` records backend/status/workspace transitions and compositor action attempts.
- Transition logs must be deduped by last observed backend/status/workspace summary.
- HUD modules must consume the shared compositor contract, not compositor-specific commands or imports.
- Compositor-specific parsing belongs in `services/`, never in `modules/hud/` or `components/`.
- Missing compositor support must produce readable fallback values such as `compositor: fallback`, empty window lists, and inactive workspace rows.
- Workspace row labels may be compositor-provided names; visual consumers must elide/clamp labels instead of assuming numeric one-character labels.
- Diagnostics surfaces may display backend-specific status lines through `CompositorService.diagnosticRows`, but should not import backend services directly.
- Compositor transition/fallback events should be logged from `CompositorService` through `ServiceLogService`, deduped by last observed status.
- Workspace switch/focus actions must be no-op safe when the target compositor is unavailable.
- Window focus should pass `windowKey` from `currentWorkspaceWindows`, not display title text, with title fallback only for legacy rows.
- Compositor user actions should update `actionStatusLine` and push a structured service-log event on dispatch or no-op fallback.
- Niri support uses documented local commands in `docs/niri.md`: `niri msg --json workspaces`, `niri msg --json windows`, `niri msg action focus-workspace <id>`, and `niri msg action focus-window --id <window-id>`.

### 4. Validation & Error Matrix

- Hyprland available -> `compositorName = "hyprland"`, rows mirror Hyprland telemetry, Niri does not override it.
- Hyprland unavailable and Niri valid -> `compositorName = "niri"`, rows mirror Niri JSON telemetry.
- Neither backend available -> `available = false`, `compositorName = "fallback"`, `workspaces.length = 5`, `currentWorkspaceWindows.length = 0`.
- `niri` binary missing or command exits non-zero -> `NiriService.available = false`, readable `niri: command fallback`, no QML exception.
- Niri JSON parse fails -> service returns fallback status and shaped empty arrays, no raw exception in UI.
- Niri windows update after workspaces -> workspace `occupied` flags are recomputed from the latest window list in the same polling cycle.
- Compositor backend/status changes -> one structured service-log event per changed summary, not one event per poll tick.
- Workspace switch while unavailable -> `actionStatusLine` contains unavailable warning and service log gets a `warn` event.
- Focus with missing `windowKey` -> warning action status/log event, no uncaught error.
- Duplicate window titles -> focus uses compositor-native `windowKey` where available instead of ambiguous display text.
- Long workspace labels -> top workspace strip clamps button width and elides labels, not panel overflow.
- HUD module imports compositor-specific API directly -> fail review; violates service boundary.

### 5. Good/Base/Bad Cases

- Good: `TopStatusBar.qml` renders `CompositorService.workspaces` and does not know whether Hyprland, Niri, or fallback produced the rows.
- Good: `TopStatusBar.qml` sizes workspace buttons from label width within a clamp and elides long labels.
- Good: `CommandCenterDiagnosticsColumn.qml` renders `CompositorService.diagnosticRows` for backend visibility without importing Hyprland/Niri services directly.
- Good: `MissionDock.qml` and `CommandCenterOverviewColumn.qml` call `CompositorService.focusWindow(modelData.windowKey)` and render title only as display text.
- Base: during migration, `HyprlandService.qml` may remain the backing implementation if the facade contract is already documented and consumers are being moved intentionally.
- Bad: `MissionDock.qml` calls `CompositorService.focusWindow(modelData.title)` as the primary key; duplicate titles can focus the wrong window.
- Bad: adding `if niri` branches or shell command parsing inside `TopStatusBar.qml`, `MissionDock.qml`, or `CommandCenterOverviewColumn.qml`.

### 6. Tests Required

- QML lint: `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`.
- Runtime smoke: `timeout 8s quickshell -p .` must show `Configuration Loaded` without startup QML errors.
- Fallback assertion: without a supported compositor, assert `compositorName === "fallback"`, `available === false`, workspace rows are present, and window rows are empty.
- Backend selection assertion: when Hyprland is available, Niri must not become active; when Hyprland is unavailable and Niri JSON is valid, Niri becomes active.
- Niri command assertion: missing `niri` command produces `niri: command fallback` and no QML errors.
- Action assertion: workspace/focus actions while unavailable update `actionStatusLine` and service-log `warn`, not exceptions.
- Window-key assertion: dock/overview pass `modelData.windowKey` to `focusWindow()` with title fallback only for missing keys.
- Label-fit assertion: long workspace labels render inside clamped buttons with `Text.ElideRight`.
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

#### Wrong

```qml
// Display titles are not stable action keys.
onClicked: CompositorService.focusWindow(modelData.title)
```

#### Correct

```qml
onClicked: CompositorService.focusWindow(modelData.windowKey || modelData.title)
```

Use `windowKey` first so Hyprland addresses and Niri window ids handle duplicate titles safely.
