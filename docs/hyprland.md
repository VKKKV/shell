# Hyprland Integration

This shell renders through Quickshell as a Wayland layer-shell window.

## Layer Identity

The HUD window is configured in `modules/hud/HudWindow.qml`:

```qml
WlrLayershell.layer: WlrLayer.Top
WlrLayershell.namespace: "void-hud"
exclusiveZone: 0
color: "transparent"
```

Use the `void-hud` namespace when writing Hyprland rules.

## Recommended Blur Setup

Add rules like this to `hyprland.conf` if you want compositor blur behind the tactical panels:

```ini
layerrule = blur, void-hud
layerrule = ignorezero, void-hud
```

If the blur feels too soft for the target style, keep blur disabled. The HUD is designed to remain readable with plain black/translucent panel surfaces.

## General Decoration Hints

These global decoration settings usually work well with the current dark tactical style:

```ini
decoration {
    rounding = 0
    blur {
        enabled = true
        size = 4
        passes = 2
        new_optimizations = true
    }
}
```

Use `rounding = 0` to preserve the hard-edged machine-interface look.

## Workspace Integration

Hyprland is adapted through `services/HyprlandService.qml`, then exposed to HUD modules through `services/CompositorService.qml`. HUD modules should consume the shared facade instead of importing Hyprland-specific APIs directly.

The Hyprland backend reads:

- active workspace: `Hyprland.focusedWorkspace?.id`
- occupied workspaces: `Hyprland.workspaces?.values`
- switching: `Hyprland.dispatch("workspace <id>")`

If workspace highlighting does not update, confirm the shell is running inside a Hyprland session and that the Quickshell Hyprland service is available in your installed Quickshell build. The command-center overview and diagnostics panels show the active compositor backend, workspace row count, active window, and fallback status.

## Troubleshooting

Run from the project root:

```bash
quickshell -p .
```

Expected startup behavior:

- `Configuration Loaded`
- no `ERROR: Failed to load configuration`
- no QML binding-loop warnings
- no layout/anchor undefined-behavior warnings

If a warning appears, fix it before expanding features. Runtime cleanliness is part of the project roadmap.
