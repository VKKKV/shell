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

## Scenario: Persistent Background Mode Contract

### 1. Scope / Trigger

- Trigger: adding or changing a persistent shell background mode, such as `visual.backgroundMode: "nixie"`.
- Applies to: `services/SettingsService.qml`, `modules/hud/CommandCenterSettingsColumn.qml`, `modules/hud/HudLayout.qml`, reusable visual components under `components/`, `src/settings/main.zig`, and `docs/settings.md`.
- This is a cross-layer settings contract because the same enum value must round-trip through settings UI, QML session state, Zig normalization, persisted JSON, and HUD rendering.

### 2. Signatures

- QML setting owner: `services/SettingsService.qml`

```qml
property string backgroundMode: "void"
function normalizeBackgroundMode(value: string): string
function settingsPayload(): string
```

- Settings panel selector: `modules/hud/CommandCenterSettingsColumn.qml`

```qml
Repeater { model: ["void", "grid", "radar", "nixie"] }
onClicked: SettingsService.backgroundMode = parent.modelData
```

- HUD renderer: `modules/hud/HudLayout.qml`

```qml
Loader {
    active: SettingsService.backgroundMode === "nixie"
    sourceComponent: Component { NixieWallpaper { anchors.fill: parent } }
}
```

- Zig helper CLI: `src/settings/main.zig`

```bash
./zig-out/bin/void-shell-settings defaults
./zig-out/bin/void-shell-settings read
./zig-out/bin/void-shell-settings write '{"visual":{"backgroundMode":"nixie"}}'
```

- Persisted payload field:

```json
{
  "visual": {
    "backgroundMode": "void"
  }
}
```

Allowed values: `void`, `grid`, `radar`, `nixie`.

### 3. Contracts

- `void` is the default and means optional background effects are off.
- `grid`, `radar`, and `nixie` are opt-in background modes selected from the settings panel.
- QML and Zig must accept the same enum set. Adding a value in QML but not in Zig causes persisted writes to normalize back to `void`.
- `SettingsService.settingsPayload()` must write `visual.backgroundMode` through `normalizeBackgroundMode(backgroundMode)`.
- `SettingsService.applySettings()` must only apply string background modes through `normalizeBackgroundMode`.
- `src/settings/main.zig` must validate `visual.backgroundMode` through `backgroundModeField()` and emit the normalized field in `normalizeSettings()` output.
- Visual background components must remain presentation-only. They may read `SettingsService`, `Time`, and `Theme`, but must not run shell commands, fetch network data, or own durable state.
- First-pass wallpaper-like effects should render inside the existing `HudLayout` background layer. A separate `PanelWindow` with `WlrLayershell.layer = WlrLayer.Background` is a future option, not required for first-pass background modes.

### 4. Validation & Error Matrix

- Missing `visual.backgroundMode` -> QML and Zig default to `void`.
- Invalid `visual.backgroundMode` such as `"noise"` -> `SettingsService.normalizeBackgroundMode()` and `backgroundModeField()` fall back to `void`.
- QML selector includes a mode that Zig rejects -> `write` normalizes to `void`; fail review because UI and persistence disagree.
- Zig accepts a mode that `HudLayout` does not render -> persisted config appears accepted but no visual output; fail review because renderer is missing.
- Background component starts commands or network fetches -> fail review; reusable visual components must remain presentation-only.
- Runtime smoke logs QML startup errors after enabling a mode -> fail verification; fix component registration/imports or bindings.

### 5. Good/Base/Bad Cases

- Good: adding `nixie` updates the settings panel model, `SettingsService.normalizeBackgroundMode()`, `src/settings/main.zig backgroundModeField()`, docs, tests, and `HudLayout` rendering in one slice.
- Base: adding a non-persistent experimental background can stay local to `HudLayout`, but it must not be exposed in settings until the QML/Zig contract is complete.
- Bad: adding `"nixie"` only to `CommandCenterSettingsColumn.qml`; the user can click it, but the helper later writes `"void"` and the setting does not survive restart.

### 6. Tests Required

- QML lint: `qmllint shell.qml components/*.qml modules/hud/*.qml services/*.qml theme/Theme.qml`.
- Runtime smoke: `timeout 8s quickshell -p .` must show `Configuration Loaded` without startup QML errors.
- Zig build: `zig build`.
- Zig tests after helper enum changes: `zig build test`.
- Defaults assertion: `./zig-out/bin/void-shell-settings defaults` includes `"backgroundMode": "void"`.
- Valid enum assertion: `./zig-out/bin/void-shell-settings write '{"visual":{"backgroundMode":"nixie"}}'` emits `"backgroundMode": "nixie"`.
- Invalid enum assertion: `./zig-out/bin/void-shell-settings write '{"visual":{"backgroundMode":"noise"}}'` emits `"backgroundMode": "void"`.
- After manual helper writes during tests, restore local config to default-off with `./zig-out/bin/void-shell-settings write '{"visual":{"backgroundMode":"void"}}'` unless intentionally testing persisted enabled state.

### 7. Wrong vs Correct

#### Wrong

```qml
// UI accepts a value the durable helper does not know about.
Repeater { model: ["void", "grid", "radar", "nixie"] }
```

```zig
// Missing "nixie" here means writes normalize back to "void".
if (std.mem.eql(u8, mode, "void") or std.mem.eql(u8, mode, "grid") or std.mem.eql(u8, mode, "radar"))
    return mode;
```

#### Correct

```qml
function normalizeBackgroundMode(value: string): string {
    return ["void", "grid", "radar", "nixie"].indexOf(value) >= 0 ? value : "void";
}
```

```zig
if (std.mem.eql(u8, mode, "void") or std.mem.eql(u8, mode, "grid") or std.mem.eql(u8, mode, "radar") or std.mem.eql(u8, mode, "nixie"))
    return mode;
```

Keep the settings UI, QML state owner, Zig helper normalization, docs, and renderer in lockstep for every persistent background mode.
