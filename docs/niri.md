# Niri Integration

This shell supports Niri through the shared `services/CompositorService.qml` facade.

## Command Contract

`services/NiriService.qml` reads compositor state with local Niri commands only:

```bash
niri msg --json workspaces
niri msg --json windows
```

Workspace switching and window focus dispatch through:

```bash
niri msg action focus-workspace <id>
niri msg action focus-window --id <window-id>
```

The service probes `command -v niri` before polling. If the binary or compositor IPC is unavailable, `CompositorService` falls back to readable inactive state instead of throwing QML errors.

## Shared Facade

HUD modules must import only `CompositorService` for compositor state:

- `available`
- `compositorName`
- `statusLine`
- `backendStatusLine`
- `workspaceStatusLine`
- `actionStatusLine`
- `diagnosticRows`
- `activeWorkspace`
- `workspaces`
- `activeWindowClass`
- `activeWindowTitle`
- `activeWindowAvailable`
- `currentWorkspaceWindows`
- `isOccupied(id)`
- `switchWorkspace(id)`
- `focusWindow(windowKey)`

Hyprland remains the preferred backend when its Quickshell service is available. Niri is used when Hyprland is unavailable and Niri command output is valid.

Window rows expose `windowKey` separately from display title. Niri uses the window id as `windowKey` so click-to-focus can target duplicate-title windows safely.

Workspace rows may expose Niri workspace names as labels. The top workspace strip clamps and elides labels, so long names remain readable without expanding the whole bar unexpectedly.

## Layer Behavior

The HUD itself remains a Wayland layer-shell surface. Niri-specific layer and exclusion behavior should be configured in the compositor if needed; shell code should not depend on compositor-side blur or decoration features.

## Troubleshooting

Run from the project root:

```bash
quickshell -p .
```

Expected fallback behavior outside Niri:

- `CompositorService.compositorName` reports `hyprland` if Hyprland is available, otherwise `fallback`.
- Niri command failures are contained inside `NiriService`.
- Workspace buttons and window focus actions become no-op safe when no supported compositor is active.
- Command-center overview and diagnostics show the active backend, workspace/window counts, and recent compositor transition log entries.
- Workspace/focus actions update `CompositorService.actionStatusLine` and write service-log events for failed or fallback actions.
