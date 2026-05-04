# PRTS Hyprland Tactical Shell

Quickshell/QML shell prototype for the tactical desktop HUD described in `target.md`.

## Run

```bash
quickshell -p .
```

If your Quickshell build expects an explicit config file, run:

```bash
quickshell -c shell.qml
```

## Current Scope

- Full-screen transparent `PanelWindow` HUD surface.
- Tactical top status bar with clock/date placeholders, workspaces, and renderer labels.
- Left tactical/thermal/power panel using target-style static data.
- Central terminal frame with neofetch/package-manager style static output.
- Right system monitor matrix with static CPU, RAM, network, filesystem, node, and log rows.
- Bottom access/status strip.

Live data integration is intentionally deferred until the layout and visual language match the target.

## Development Checkpoints

- Implement one vertical slice at a time.
- Format and lint QML before treating a slice as done.
- Run Quickshell when available and watch for QML/runtime errors.
- Commit each verified slice or stable milestone so the project always has a resumable checkpoint.
