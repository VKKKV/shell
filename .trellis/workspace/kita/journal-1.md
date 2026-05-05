# Journal - kita (Part 1)

> AI development session journal
> Started: 2026-05-04

---

## 2026-05-04 - Shell Roadmap And Settings Persistence

- Updated `.trellis/tasks/05-04-plan-shell-dev/PLAN.md` to reflect the implemented HUD baseline and prioritize incremental feature slices.
- Implemented QML settings persistence through `void-shell-settings read/write` in `services/SettingsService.qml`.
- Added settings state for panel visibility and system stats polling interval.
- Connected `HudLayout.qml` panel visibility to settings state.
- Connected `SystemStats.qml` polling to `liveDataEnabled` and `updateIntervalMs`.
- Expanded `SettingsPanel.qml` with tactical controls for left/center/right panels and poll rate.
- Verified with `zig build`, helper CLI smoke tests, `qmllint`, `quickshell -p .`, and `git diff --check`.

## 2026-05-04 - Audio Vertical Slice

- Added `services/AudioService.qml` with `wpctl` polling for default sink volume and mute state.
- Added tactical top-bar audio readout with volume down, mute toggle, and volume up controls.
- Registered `AudioService` in `services/qmldir` and updated the roadmap to mark the audio slice covered.

## 2026-05-04 - Session Controls Slice

- Added `services/SessionService.qml` for lock, logout, reboot, and shutdown commands.
- Added a 5-second armed confirmation flow before executing session actions.
- Added tactical session/power controls to `SettingsPanel.qml` and registered the service in `services/qmldir`.

## 2026-05-04 - Battery Power Source Slice

- Added `services/BatteryService.qml` reading `/sys/class/power_supply/BAT*` through a safe sysfs command.
- Added AC/no-battery fallback for desktop systems with no power-supply entries.
- Added `POWER SOURCE` metrics and battery status logging to the right monitor panel.

## 2026-05-04 - Media MPRIS Slice

- Added `services/MediaService.qml` using `playerctl` for MPRIS metadata and controls.
- Added compact top-bar media display with previous, play-pause, and next controls.
- Added media service status to the right-panel log stream and updated the roadmap.

## 2026-05-04 - System Tray Slice

- Confirmed local Quickshell exposes `Quickshell.Services.SystemTray` through reference shell usage.
- Added `components/TrayStrip.qml` with item count, icon cells, left-click activate, and right-click secondary activate.
- Registered `TrayStrip` in `components/qmldir` and mounted it in the top status bar.

## 2026-05-04 - HUD Edge Overlay Refactor

- Responded to screenshot feedback: top bar content was clipped, fullscreen HUD obscured real Hyprland windows, and center terminal should be a real compositor-managed window.
- Removed the opaque fullscreen HUD background and removed the central terminal panel from the active layout.
- Refactored `HudLayout.qml` into edge-anchored top/left/right/bottom panels with center area left transparent for real windows.
- Added `PanelWindow.mask` regions so only edge panels and settings overlay receive pointer input; center area passes through.
- Increased top bar height and compacted top-right media/audio/tray layout to avoid clipping.
- Replaced the left tactical mock panel with an orbital globe-style telemetry panel using `components/RotatingGlobe.qml`.

## 2026-05-04 - Dynamic Edge Expansion

- Replaced fixed top/bottom bar heights with implicit content-driven heights clamped by theme min/max values.
- Updated left/right side panels to expose implicit sizes and expand inward based on content width/height.
- Added size animations so top expands downward, bottom expands upward, and side panels expand toward the center without abrupt jumps.

## 2026-05-04 - Edge Exclusion Zones

- Added development plan entry for edge space reservation so compositor-managed Hyprland windows are pushed into the center safe area.
- Added `services/HudMetrics.qml` to share visible HUD dimensions with reservation windows.
- Added `modules/hud/HudExclusionZone.qml`, a transparent `PanelWindow` using `ExclusionMode.Auto` and empty input mask.
- Instantiated top, bottom, left, and right exclusion zones from `shell.qml` so dynamic HUD dimensions reserve matching screen space.

## 2026-05-04 - Command Center Foundation

- Reviewed current shell structure and found no blocking optimization needs; verification passed before continuing.
- Updated `PLAN.md` to move completed edge/settings/media/tray work out of the next-step list.
- Refactored `SettingsPanel.qml` into a broader command center with system overview, live metrics, service status, settings controls, and session power actions in three columns.

## 2026-05-04 - Launcher Search Slice

- Added `services/LauncherService.qml` with built-in actions and `.desktop` app indexing through `gtk-launch`.
- Added command center search input and launcher results list for apps/actions.
- Updated `PLAN.md` to mark launcher/search foundation covered and move notifications/toasts up next.

## 2026-05-04 - Notifications And Toasts Slice

- Added `services/NotificationService.qml` using Quickshell notification APIs when no external notification daemon owns DBus.
- Added DND state, notification history, latest notification state, and tactical toast visibility state.
- Added `modules/hud/NotificationToast.qml`, command center DND/clear controls, and recent notification history.
- Avoided startup warning by probing `org.freedesktop.Notifications` before enabling the built-in server.

## 2026-05-04 - Network Detail Slice

- Reviewed launcher/notification slices; no blocking optimization needed before continuing.
- Added `services/NetworkDetailService.qml` using `nmcli` for active connections/VPN-like links and `bluetoothctl` for controller state.
- Added `NETWORK DETAIL` rows to the right monitor panel and network/VPN status to the command center overview.

## 2026-05-04 - Theme Profiles Slice

- Added persistent `visual.profile` settings support for `amber`, `green`, `blue`, and `red`.
- Updated `Theme.qml` to derive tactical accent/text colors from `SettingsService.themeProfile`.
- Added command center profile controls and documented the settings contract update.

## 2026-05-04 - Command Center Refactor

- Reviewed architecture before continuing; `SettingsPanel.qml` had become too broad and needed a seam before more feature work.
- Split command center implementation into `CommandCenterPanel.qml`, `CommandCenterOverviewColumn.qml`, `CommandCenterSettingsColumn.qml`, and `CommandCenterActionsColumn.qml`.
- Reduced `SettingsPanel.qml` back to a thin overlay wrapper that centers `CommandCenterPanel`.

## 2026-05-04 - Clipboard Buffer Slice

- Added `services/ClipboardService.qml` using `wl-paste` polling and `wl-copy` restore actions.
- Added command center clipboard buffer controls with refresh, clear, and click-to-copy history entries.
- Added clipboard service status to command center overview and updated the roadmap.

## 2026-05-04 - Calendar Agenda Slice

- Added `services/CalendarService.qml` with local date, month grid, and generated agenda state.
- Added local agenda and calendar grid to the command center.
- Replaced the bottom center access text with compact day/date telemetry.

## 2026-05-04 - Active Window Overview Slice

- Extended `HyprlandService.qml` with active toplevel title/class and current workspace window rows.
- Added active window telemetry to the top status bar and command center overview.
- Added clickable current-workspace window rows to the command center using Hyprland focus dispatch.

## 2026-05-04 - Mission Dock Slice

- Reviewed architecture before continuing; no blocking refactor was needed after command center decomposition.
- Added `modules/hud/MissionDock.qml` to render current workspace windows as compact bottom-bar targets.
- Mounted `MissionDock` in `BottomStatusBar.qml` and updated the roadmap.

## 2026-05-04 - Weather Slice

- Added `services/WeatherService.qml` using `wttr.in` via `curl` for local weather data with network fallback.
- Added weather status to command center overview and updated the roadmap.

## 2026-05-05 - Project Granularity Alignment

- Checked the active shell task against the current code structure and uncommitted weather slice.
- Aligned frontend Trellis guidelines with the existing `components/`, `modules/hud/`, `services/`, `theme/`, and Zig helper boundaries.
- Updated settings documentation to reflect implemented Zig persistence instead of a future helper plan.

## 2026-05-05 - Power Profile And Idle Slice

- Added `services/PowerProfileService.qml` using `powerprofilesctl` for profile reads/writes and `systemd-inhibit` for an idle inhibitor toggle.
- Added command center power profile controls and idle inhibitor status with fallback service lines.
- Updated the roadmap to mark the first power-profile/idle control surface covered.

## 2026-05-05 - Tray Drawer Slice

- Added `modules/hud/TrayDrawer.qml` for command-center status notifier items with tactical icon cells.
- Wired left-click activate and right-click secondary activate for tray entries.
- Updated the roadmap to distinguish covered tray drawer behavior from future popout menu bridging.

## 2026-05-05 - Keyboard Layout Slice

- Added `services/KeyboardService.qml` using `hyprctl devices -j` to expose active keyboard layout and keyboard rows.
- Added keyboard telemetry to command center overview and actions surfaces with Hyprland command fallback.
- Updated the roadmap to mark keyboard layout telemetry covered while leaving keybind recorder/list and emoji deferred.

## 2026-05-05 - Wi-Fi Scan Slice

- Extended `NetworkDetailService.qml` with `nmcli` Wi-Fi scan telemetry and fallback status.
- Added command center Wi-Fi scan rows showing SSID, signal, security, and active link state.
- Updated the roadmap to mark Wi-Fi list telemetry covered while leaving connection flows deferred.

## 2026-05-05 - Microphone Controls Slice

- Extended `AudioService.qml` with default source volume, mute state, fallback status, and `wpctl` microphone controls.
- Added microphone telemetry to command center overview metrics and microphone controls to settings.
- Updated the roadmap to mark microphone controls covered while leaving spectrum/lyrics deferred.

## 2026-05-05 - Interactive Panel Expansion Planning

- Captured the new direction: left/right panel child elements should become interactive tactical entry points.
- Planned the first MVP around clicking the left orbital globe to deploy a central enlarged orbital/solar-system analysis panel.
- Defined the visual requirement for ASCII/monospace planet position telemetry with mechanical/cyber deployment language and reusable overlay architecture.

## 2026-05-05 - Orbital Expansion MVP

- Added `services/ExpansionService.qml` to own central expansion overlay state.
- Added `modules/hud/OrbitalExpansionPanel.qml` with deterministic animated ASCII solar-system telemetry and mechanical/cyber tactical framing.
- Made `RotatingGlobe` clickable and wired `HudLayout.qml` to deploy/close the orbital overlay with a matching input region.

## 2026-05-05 - CPU Matrix Expansion Slice

- Added `modules/hud/CpuExpansionPanel.qml` as a right-panel drill-down surface using the shared expansion overlay pattern.
- Made the right monitor CPU core grid clickable and routed it through `ExpansionService.show("cpu")`.
- Updated the roadmap to mark CPU matrix expansion covered and leave network/filesystem/log drill-downs next.

## 2026-05-05 - Runtime Warning And Expansion Motion Fix

- Changed `PowerProfileService.qml` to probe `powerprofilesctl` through `command -v` before running it, preventing missing-binary startup warnings.
- Extended `ExpansionService.show()` with source-origin metadata for expansion surfaces.
- Updated orbital and CPU expansion placement so panels scale/move from their clicked source direction instead of flashing directly into the center.

## 2026-05-05 - Network Matrix Expansion Slice

- Added `modules/hud/NetworkExpansionPanel.qml` as a right-panel drill-down surface for throughput, link detail, active connections, and Wi-Fi scan rows.
- Made the right monitor network block clickable and routed it through `ExpansionService.show("network", "right-network")`.
- Updated the roadmap to mark network matrix expansion covered and leave filesystem/log drill-downs next.

## 2026-05-05 - Filesystem Matrix Expansion Slice

- Added `modules/hud/FilesystemExpansionPanel.qml` as a right-panel drill-down surface for mount usage, storage state, and memory coupling.
- Made the right monitor filesystem block clickable and routed it through `ExpansionService.show("filesystem", "right-filesystem")`.
- Updated the roadmap to mark filesystem expansion covered and leave log stream drill-down next.

## 2026-05-05 - Log Stream Expansion Slice

- Added `modules/hud/LogExpansionPanel.qml` as a right-panel drill-down surface for service status events and warning classification.
- Made the right monitor log stream clickable and routed it through `ExpansionService.show("logs", "right-logs")`.
- Updated the roadmap to mark the current interactive expansion MVP covered.

## 2026-05-05 - Audio Spectrum Slice

- Added a local deterministic spectrum signal to `AudioService.qml`, driven by volume/mute state and a lightweight timer.
- Added compact spectrum visuals to the top bar and command center overview without adding external audio dependencies.
- Updated the roadmap to mark spectrum/visualizer covered and leave optional lyrics deferred.

## 2026-05-05 - Tactical Background Modes Slice

- Added persistent `visual.backgroundMode` settings support for `void`, `grid`, and `radar`.
- Added grid/radar background rendering behind the HUD and command center controls for selecting background mode.
- Updated the settings contract and roadmap to mark local background mode management covered while leaving external wallpaper browsing/dynamic color deferred.

## 2026-05-05 - Keybind List Slice

- Added `services/KeybindService.qml` using `hyprctl binds -j` to expose Hyprland keybind rows with fallback status.
- Added keybind list telemetry to the command center actions column and service status overview.
- Updated the roadmap to mark keybind list covered while leaving recorder and emoji deferred.

## 2026-05-05 - Emoji Palette Slice

- Added `services/EmojiService.qml` with a local tactical emoji palette and `wl-copy` copy action.
- Added emoji cells to the command center actions column and emoji status to the overview.
- Updated the roadmap to mark local emoji palette covered while leaving keybind recorder deferred.

## 2026-05-05 - Tray Menu Bridge Slice

- Confirmed Quickshell v0.3 `SystemTrayItem` exposes `hasMenu` and `display(parentWindow, relativeX, relativeY)` for platform menu bridging.
- Updated `TrayStrip.qml` and `TrayDrawer.qml` right-click handling to open tray menus through `display()` when available, falling back to secondary activation.
- Updated the roadmap to mark tray menu bridging covered while leaving only deeper custom menu styling deferred.
