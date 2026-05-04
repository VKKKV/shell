# Shell Development Plan

## Planning Status
- Status: ready for implementation using `target.md` as the authoritative visual brief.
- Trellis context: `implement.jsonl`, `check.jsonl`, and `debug.jsonl` are initialized.
- Task type: frontend.
- Primary deliverable: a Quickshell tactical desktop dashboard matching the PRTS/Hyprland cyberpunk interface described in `target.md`.

## Constraints And Assumptions
- The shell is built with Quickshell/QML for Wayland, with Hyprland as the first compositor target.
- This repository is currently mostly planning artifacts plus `target.png`; implementation should create the app structure from scratch instead of modifying an existing shell.
- `target.md` defines the required visual and functional granularity: top status bar, left tactical/thermal/power panels, central terminal frame, right monitoring matrix, and bottom status bar.
- Reference projects are for architecture patterns only. Do not copy large blocks from Caelestia, Noctalia, or DankMaterialShell.
- Prefer a small, runnable tactical frame over broad but incomplete live monitoring. Static mock data is acceptable for the first pass if the layout and visual language are correct.

## Reference Findings
- Caelestia keeps `shell.qml` thin and delegates real UI to modules/services. Its bar uses component loaders and service singletons for Hyprland, audio, brightness, and time.
- Noctalia uses a registry/service pattern for bar widgets, but that is more dynamic than this project needs initially. Its useful lesson is to keep screen-specific bar state explicit and avoid re-creating delegates unnecessarily.
- DankMaterialShell separates `PanelWindow` concerns from bar content and has strong patterns for floating bars, transparency, blur regions, and per-section widget models.
- For this project, use a dashboard architecture: one full-screen/floating layer-shell surface for the tactical HUD, with static panel composition first and service-backed data added incrementally.

## Target Architecture

```text
shell.qml
components/
  TacticalFrame.qml
  TacticalLabel.qml
  MetricRow.qml
  ProgressBar.qml
  Sparkline.qml
modules/
  hud/
    HudWindow.qml
    HudLayout.qml
    TopStatusBar.qml
    LeftTacticalPanel.qml
    CenterTerminalPanel.qml
    RightMonitorPanel.qml
    BottomStatusBar.qml
services/
  Time.qml
  Hyprland.qml
  SystemStats.qml
  Network.qml
theme/
  Theme.qml
```

## Architecture Decisions
- `shell.qml` owns only `ShellRoot` and module startup.
- `modules/hud/HudWindow.qml` owns `PanelWindow`, layer-shell anchors, transparent window color, fullscreen geometry, and screen binding.
- `modules/hud/HudLayout.qml` owns the global grid: top status bar, left sidebar, central terminal panel, right monitor panel, and bottom status bar.
- `theme/Theme.qml` is the single source of truth for tactical colors, line widths, spacing, font sizes, panel dimensions, and animation durations.
- `components/` contains reusable presentational primitives only. Keep business logic out of these files.
- `services/` contains external state and command integration. A widget should read state from services and dispatch user actions, not parse command output inline unless it is a temporary spike.
- Do not create plugin registries, settings migrations, or dynamic widget ordering in the first implementation. Add those only after the shell works visually.
- Create a git commit at each necessary checkpoint: after a slice is implemented, formatted, linted, and runtime-checked enough to be safely resumed later.

## Visual Direction
- Style: dark tactical/cyberpunk/techwear HUD, not minimal material design.
- Palette: pure black or near-black base, warning yellow accents, dim gray secondary text, high contrast borders.
- Geometry: thin rectangular frames, right angles, crosshair ticks, dense metric rows, progress bars, waveform/sparkline elements, and industrial labels.
- Typography: monospaced technical look; large digital clock; compact uppercase labels; numeric data should align cleanly.
- Density: information-dense, dashboard-like, with visible structure lines and system telemetry blocks.
- Must preserve the target composition: top bar, left tactical/thermal/power stack, central terminal-style frame, right system monitor matrix, bottom access/status strip.
- Blur/rounded-pill aesthetics are secondary and should not override the tactical rectangular language.

## Implementation Slices

### Slice 1: Minimal Runnable Tactical HUD
- Create `shell.qml`, `theme/Theme.qml`, `modules/hud/HudWindow.qml`, and `modules/hud/HudLayout.qml`.
- Render a transparent full-screen/floating `PanelWindow` containing placeholder tactical frames for top, left, center, right, and bottom regions.
- Add `README.md` with run command and dependency notes.
- Verify with `quickshell -p .` or the locally appropriate Quickshell command.

Acceptance:
- Quickshell starts without QML import/runtime errors.
- The five major target regions are visible and proportioned like a tactical dashboard.
- Background is transparent/black-compatible, with yellow/gray tactical line styling.
- Layout remains sane on a 16:9 desktop resolution.

### Slice 2: Theme And Tactical Primitives
- Create `components/TacticalFrame.qml`, `components/TacticalLabel.qml`, `components/MetricRow.qml`, `components/ProgressBar.qml`, and `components/Sparkline.qml` only as needed.
- Replace placeholder rectangles/text with reusable tactical frames and metric rows.
- Keep all repeated dimensions/colors in `Theme.qml`.

Acceptance:
- No repeated magic values for core spacing, border widths, yellow/gray colors, and typography.
- The UI reads as PRTS tactical/HUD rather than generic status widgets.

### Slice 3: Top And Bottom Status Bars
- Add `services/Time.qml` or a minimal local `Timer` if only `Clock.qml` needs it.
- Implement top-left large digital time and date.
- Implement top-center workspace selector 1-5 using `Quickshell.Hyprland` first.
- Implement top-right labels: `// SYS.PRTS.V2.0` and `HYPRLAND // QML RENDERER`.
- Implement bottom status strip with system ID, `[ROOT_ACCESS_GRANTED]`, and secure tactical channel status.

Acceptance:
- Clock updates without restarting the shell.
- Active workspace changes reflect after Hyprland workspace switching.
- Clicking a workspace dispatches the expected Hyprland workspace command.
- Bottom strip matches the target's access/status semantics.

### Slice 4: Left Tactical Panel
- Implement `LeftTacticalPanel.qml` with three stacked sections: `TACTICAL LAYER`, `THERMAL MAP`, and `POWER GRID`.
- Start with realistic mock values matching `target.md`: ONLINE, sync/signal/encryption, CPU/GPU/VRM/PCH/SSD temperatures, total/GPU/CPU watts.
- Add a simple radar/geometric diagram using QML shapes or line rectangles.

Acceptance:
- Left panel visually communicates tactical status, thermal map, and power grid at a glance.
- Mock values are isolated so they can be replaced by services later.

### Slice 5: Center Terminal Panel
- Implement `CenterTerminalPanel.qml` as a framed terminal window labeled `TERMINAL 01`.
- Render neofetch-like system rows and a package-manager operation block using monospaced text.
- Add terminal footer with `TTY1`, `ROOT`, kernel text, and yellow `>> LIVE` indicator.

Acceptance:
- Center panel dominates the layout and reads as a live terminal surface.
- Long terminal lines clip or elide cleanly inside the frame.
- Static content matches the target.md level of detail.

### Slice 6: Right Monitor Matrix
- Implement `RightMonitorPanel.qml` with `SYSTEM MONITOR MATRIX`, per-core CPU rows, CPU load waveform, RAM/SWAP bars, network graph, filesystem rows, node status, and log stream.
- Start with mock arrays for graphs/logs; wire live data after layout stabilizes.
- Prefer Quickshell service APIs where available; otherwise isolate `Process` command parsing in `services/SystemStats.qml`.
- Keep polling intervals conservative to avoid shell overhead.

Acceptance:
- Right panel is dense but legible, matching the matrix/dashboard feel.
- Graph components can consume arrays without layout rewrites.
- Command failures do not spam visible UI with raw errors once live data is added.

### Slice 7: Live Data Integration
- Replace mock clock/workspace/system metrics with services incrementally.
- Prioritize Hyprland workspace, time/date, CPU/RAM, network throughput, filesystem usage, and logs.
- Keep every command/process parser inside `services/`.

Acceptance:
- Widgets degrade gracefully when tools/services are unavailable.
- Long labels elide instead of resizing panels unexpectedly.
- User actions map to clear commands and do not block the UI thread.

### Slice 8: Polish And Interaction
- Add hover states, press states, small transitions, and popups only where useful.
- Tune typography, line density, graph motion, yellow emphasis, and panel proportions against `target.md`/`target.png`.
- Add optional Hyprland blur/layer-rule documentation only if it strengthens the target aesthetic.

Acceptance:
- Visual comparison against `target.md` identifies no missing major region or design language mismatch.
- QML logs are clean during normal interaction.
- Shell reload works without stale windows or duplicate services.

## Verification Plan
- Run Quickshell from the repository root and watch stderr/stdout for QML errors.
- Exercise workspace switching, clock updates, system metric updates, network changes, and log-stream updates when implemented.
- Run any available formatter/linter if the project adds one; otherwise use QML runtime checks as the baseline.
- Capture a screenshot after Slice 1, Slice 4, Slice 6, and Slice 8 for manual comparison with `target.md` and `target.png`.
- Commit after each verified slice or other stable milestone so future sessions can resume from a known-good checkpoint.

## Risks
- Quickshell API details vary by version; confirm imports against v0.3.0 docs during implementation.
- Hyprland-only workspace logic should be isolated so other compositors can be added later without rewriting the HUD.
- Polling system commands too often can create avoidable CPU overhead.
- Dense tactical UI can become unreadable quickly; prioritize spacing, hierarchy, and monospaced alignment over adding more numbers.

## Deferred Work
- Dynamic widget registry, settings UI, and user-configurable panel layout.
- Multi-compositor workspace support beyond Hyprland.
- Audio/media/tray widgets unless explicitly needed for target parity.
- Persistent user configuration and migrations.
