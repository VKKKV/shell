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
- `activeWorkspace`
- `activeWindowClass`
- `activeWindowTitle`
- `activeWindowAvailable`
- `currentWorkspaceWindows`
- `isOccupied(id)`
- `switchWorkspace(id)`
- `focusWindow(windowKey)`

Hyprland remains the preferred backend when its Quickshell service is available. Niri is used when Hyprland is unavailable and Niri command output is valid.

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
