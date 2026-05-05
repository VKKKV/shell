# Directory Structure

> How frontend code is organized in this project.

---

## Overview

This is a Quickshell/QML desktop shell with a tactical HUD architecture. The current granularity is vertical-slice oriented:

- `shell.qml` starts the shell and instantiates top-level HUD windows/zones.
- `components/` contains reusable visual primitives and small tactical widgets.
- `modules/hud/` contains composed product surfaces, command-center columns, edge panels, and central expansion surfaces.
- `services/` contains QML singleton state, polling, command execution, parsing, fallback behavior, and cross-surface interaction state.
- `theme/` contains global colors, spacing, typography, and sizing constants.
- `src/` contains optional Zig helpers for durable backend concerns.
- `docs/` contains user-facing integration contracts and compositor/settings notes.

---

## Directory Layout

```
shell.qml
components/
├── TacticalFrame.qml
├── TacticalLabel.qml
├── MetricBlock.qml
├── Sparkline.qml
├── TrayStrip.qml
├── RotatingGlobe.qml
└── qmldir
modules/hud/
├── HudWindow.qml
├── HudExclusionZone.qml
├── HudLayout.qml
├── TopStatusBar.qml
├── BottomStatusBar.qml
├── CommandCenterPanel.qml
├── CommandCenterOverviewColumn.qml
├── CommandCenterSettingsColumn.qml
├── CommandCenterActionsColumn.qml
├── OrbitalExpansionPanel.qml
├── CpuExpansionPanel.qml
├── NetworkExpansionPanel.qml
├── FilesystemExpansionPanel.qml
├── LogExpansionPanel.qml
└── qmldir
services/
├── SystemStats.qml
├── HyprlandService.qml
├── SettingsService.qml
├── ExpansionService.qml
├── AudioService.qml
├── MediaService.qml
├── NetworkDetailService.qml
├── WallpaperService.qml
├── WeatherService.qml
└── qmldir
theme/
├── Theme.qml
└── qmldir
src/settings/
└── main.zig
docs/
├── hyprland.md
└── settings.md
```

---

## Module Organization

Add new features as vertical slices, not as registries or broad rewrites.

- If a feature has reusable visuals, add or reuse a small `components/*.qml` primitive.
- If a feature creates a visible HUD surface, put the composed UI in `modules/hud/*.qml`.
- If a feature reads external state, polls, parses command output, or exposes shared values, put that in `services/*.qml` and register it in `services/qmldir`.
- If a feature opens a central drill-down, add a focused `*ExpansionPanel.qml` surface and route it through `ExpansionService.qml` rather than giving edge panels independent popup state.
- If a feature belongs inside the command center, add it to one of the existing columns first; split a new column/surface only when the current column becomes unmaintainable.
- If a feature needs durable validation/persistence or command parsing becomes too complex for QML, add a focused Zig helper under `src/<feature>/`.
- Update `qmldir` when adding importable QML files.
- Update task docs and the journal after each completed slice.

---

## Naming Conventions

- QML files use PascalCase, matching the exported component/singleton name.
- Services end with `Service.qml` when they represent an external integration or domain state boundary.
- Shared metrics/state singletons may use a short domain name when already clear, such as `Time.qml` or `HudMetrics.qml`.
- HUD modules use product-surface names, such as `TopStatusBar.qml`, `MissionDock.qml`, or `CommandCenterPanel.qml`.
- Central expansion surfaces use `*ExpansionPanel.qml` and are controlled by `ExpansionService.qml`.
- Zig helpers use lowercase executable-oriented names, such as `void-shell-settings`.

---

## Examples

- `services/SettingsService.qml` plus `src/settings/main.zig`: QML owns presentation state while Zig owns durable normalization.
- `services/WeatherService.qml` plus `modules/hud/CommandCenterOverviewColumn.qml`: service-backed data appears in a composed command-center surface.
- `modules/hud/SettingsPanel.qml` plus `CommandCenterPanel.qml`: thin overlay wrapper around a larger product panel.
- `components/MetricBlock.qml`: reusable display primitive fed by already-shaped rows.
- `services/ExpansionService.qml` plus `modules/hud/OrbitalExpansionPanel.qml`: edge-panel click targets deploy central safe-area surfaces.
- `services/WallpaperService.qml` plus `CommandCenterSettingsColumn.qml`: local external command integration appears as a settings/control surface.
