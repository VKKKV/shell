# Shell Development Plan

## Planning Status
- Status: core HUD implemented; next work should close functional gaps using `target.md` as the authoritative visual brief.
- Trellis context: `implement.jsonl`, `check.jsonl`, and `debug.jsonl` are initialized.
- Task type: frontend.
- Primary deliverable: a Quickshell tactical desktop dashboard matching the VOID-Hyprland cyberpunk interface described in `target.md`.

## Constraints And Assumptions
- The shell is built with Quickshell/QML for Wayland, with Hyprland as the first compositor target.
- This repository already contains a runnable Quickshell HUD structure; implementation should proceed as small vertical slices against the existing `components/`, `modules/hud/`, `services/`, and `theme/` boundaries.
- `target.md` defines the required visual and functional granularity: top status bar, left tactical/thermal/power panels, central terminal frame, right monitoring matrix, and bottom status bar.
- Reference projects are for architecture patterns only. Do not copy large blocks from Caelestia, Noctalia, or DankMaterialShell.
- Prefer feature slices that connect an existing tactical surface to real service data. Static mock data is acceptable only where a real integration has not been prioritized yet.

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
  ToggleRow.qml
  AnalogOrbitClock.qml
  CentralPanelChrome.qml
  PanelCloseButton.qml
  TrayStrip.qml
  TerminalLine.qml
  TerminalSection.qml
modules/
  hud/
    HudWindow.qml
    HudLayout.qml
    TopStatusBar.qml
    LeftTacticalPanel.qml
    CenterTerminalPanel.qml
    RightMonitorPanel.qml
    BottomStatusBar.qml
    SettingsPanel.qml
    CommandCenterPanel.qml
    CommandCenterOverviewColumn.qml
    CommandCenterSettingsColumn.qml
    CommandCenterActionsColumn.qml
    OrbitalExpansionPanel.qml
    CpuExpansionPanel.qml
    NetworkExpansionPanel.qml
    FilesystemExpansionPanel.qml
    LogExpansionPanel.qml
services/
  Time.qml
  HyprlandService.qml
  NiriService.qml
  CompositorService.qml
  SystemStats.qml
  SettingsService.qml
  ExpansionService.qml
  AudioService.qml
  MediaService.qml
  NetworkDetailService.qml
  WallpaperService.qml
  ServiceLogService.qml
  EnvironmentService.qml
  KeyboardService.qml
  KeybindService.qml
  EmojiService.qml
theme/
  Theme.qml
src/settings/
  main.zig
```

## Architecture Decisions
- `shell.qml` owns only `ShellRoot` and module startup.
- `modules/hud/HudWindow.qml` owns `PanelWindow`, layer-shell anchors, transparent window color, fullscreen geometry, and screen binding.
- `modules/hud/HudLayout.qml` owns the global grid: top status bar, left sidebar, central terminal panel, right monitor panel, and bottom status bar.
- `modules/hud/HudLayout.qml` owns edge panel placement, exclusion-aware metrics, central safe-area sizing, and expansion-surface deployment.
- `theme/Theme.qml` is the single source of truth for tactical colors, line widths, spacing, font sizes, panel dimensions, and animation durations.
- `components/` contains reusable presentational primitives only. Keep business logic out of these files.
- `services/` contains external state and command integration. A widget should read state from services and dispatch user actions, not parse command output inline unless it is a temporary spike.
- `services/ExpansionService.qml` is the single owner for central expansion state; edge panels should call it instead of owning popups directly.
- `components/AnalogOrbitClock.qml` is the current left-panel orbital expansion affordance. `RotatingGlobe.qml` remains available as a visual primitive but is not the primary orbital entry.
- `components/CentralPanelChrome.qml` owns shared command-center/non-orbital expansion panel chrome; `HudLayout.qml` still owns deployment geometry and animation.
- `src/settings/main.zig` provides the first backend helper for settings persistence/normalization; keep QML as presentation state and Zig as durable data validation/persistence.
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
- The UI reads as VOID tactical/HUD rather than generic status widgets.

### Slice 3: Top And Bottom Status Bars
- Add `services/Time.qml` or a minimal local `Timer` if only `Clock.qml` needs it.
- Implement top-left large digital time and date.
- Implement top-center workspace selector 1-5 using `Quickshell.Hyprland` first.
- Implement top-right labels: `// VOID.SYS.V2.0` and `HYPRLAND // QML RENDERER`.
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
- Hyprland and Niri workspace logic should stay isolated behind `CompositorService.qml` so other compositors can be added later without rewriting the HUD.
- Polling system commands too often can create avoidable CPU overhead.
- Dense tactical UI can become unreadable quickly; prioritize spacing, hierarchy, and monospaced alignment over adding more numbers.

## Deferred Work
- Dynamic widget registry and user-configurable widget ordering.
- Multi-compositor workspace support beyond Hyprland, starting with planned Niri support.
- Large plugin/IPC system until multiple first-party widgets need dynamic registration.
- Persistent user configuration and migrations.

## Next Development Roadmap

Current status: all concrete planned phases below are covered by first-party slices. Future work should start from new user feedback, screenshot comparisons, or a new Trellis task rather than extending this roadmap indefinitely.

Checkpoint policy: every completed development phase must be verified, recorded, committed, and pushed before moving to the next phase, unless verification or remote push is blocked. Use this policy for future optimization slices in this task.

Current next phase: review screenshot/user feedback for the next visual tuning slice or open a new Trellis task for any larger product direction; all concrete planned shell-development slices in this task are now covered.

### Phase A: Runtime Cleanliness And Visual Tuning
- Fix all Quickshell runtime warnings before adding larger features.
- Use real screenshots from the running shell as the visual feedback source.
- Tune panel proportions, font sizes, yellow intensity, scanline opacity, and graph density against `target.md` and `target.png`.
- Add screenshot checkpoints after major visual changes.

Acceptance:
- `quickshell -p .` loads without QML warnings in normal startup.
- No binding loops or layout/anchor undefined behavior warnings remain.
- The HUD remains readable on the user's monitor resolution.

Status: covered by repeated `quickshell -p .` smoke checks, target palette alignment, adaptive side-panel heights, command-center scrolling, and graphical orbital tuning. Real screenshot-driven fine-tuning remains a feedback activity, not a missing planned slice.

### Phase B: Hyprland Integration Docs And Compositor Polish
- Add `docs/hyprland.md` with recommended `layerrule`/blur settings for the `void-hud` namespace.
- Document expected behavior for overlay/top layer, transparency, blur, and workspace click actions.
- Keep blur optional; the shell must remain usable without compositor blur.

Acceptance:
- A user can copy the documented Hyprland rules and understand what each rule changes.
- No shell code depends on blur being enabled.

Status: covered in `docs/hyprland.md`; blur remains optional.

### Phase B2: Niri Compositor Support
- Add Niri as the next compositor target without regressing Hyprland behavior.
- The shared compositor service contract is `services/CompositorService.qml`: active workspace, active window class/title, current workspace window lists, status line, occupied workspace checks, and switch/focus actions.
- Keep Niri command/API parsing inside `services/NiriService.qml` and expose already-shaped values to HUD modules.
- User-facing command assumptions and fallback behavior live in `docs/niri.md`.

Acceptance:
- Hyprland and Niri can each provide workspace/window state through the same QML-facing contract.
- Missing compositor commands or unavailable compositor state produce readable fallback values, not QML errors.
- HUD modules do not import compositor-specific APIs directly.

Status: covered by `NiriService.qml` behind `CompositorService.qml`; manual validation inside a real Niri session remains the next environment-specific check.

### Phase C: Responsive And Monitor Fit
- Add layout guardrails for smaller monitors and non-16:9 resolutions.
- Make right and left panels configurable or clamp their widths from theme values.
- Ensure center terminal text elides or compresses before overflowing panels.

Acceptance:
- No important content is clipped on the user's monitor.
- The HUD remains usable at common 1080p and 1440p widths.

Status: covered by theme width clamps, central safe-area expansion sizing, adaptive side-panel heights, and scrollable dense panels/command-center columns.

### Phase D: Service Reliability, Fallbacks, And Logging
- Add service-level fallback states for unavailable commands, missing mounts, and missing Hyprland data.
- Add lightweight structured logging for service failures without spamming the UI.
- Keep command/process parsing inside `services/` only.

Acceptance:
- Missing `/data`, no swap, or unavailable command paths do not create QML errors.
- The UI shows safe fallback values while logs preserve enough detail for debugging.

Status: covered by service fallback states, `SystemStats` missing-mount handling, and `ServiceLogService` recent event display.

### Phase E: Settings Panel In Tactical Style
- Settings panel foundation exists and matches the VOID/techwear visual language.
- Current settings control theme intensity, scanlines, and live data state boundaries.
- Zig helper `void-shell-settings` exists and normalizes settings JSON.
- Next step is wiring QML `SettingsService` to `void-shell-settings read/write`.

Acceptance:
- Settings UI feels like part of the tactical shell.
- User can adjust key visual/system options without editing QML during the current session.
- Persistent read/write is implemented through Zig before settings are considered complete.

Status: covered by command-center settings controls and `void-shell-settings` read/write persistence.

### Phase F: Feature Expansion Toward Reference Shells
- Add richer widgets inspired by reference projects while preserving this shell's style: audio, media/MPRIS, network detail, tray, notifications, launcher, power/session, and optional dashboard popouts.
- Add features as vertical slices with a working visual surface plus service integration.
- Avoid adding large registry/plugin systems until there are enough widgets to justify them.

Acceptance:
- Each new feature has a visible tactical UI, service boundary, fallback behavior, validation, and commit checkpoint.

Status: covered for audio/mic, media/lyrics, battery, tray, notifications, launcher, network, wallpaper, power/session, clipboard, calendar, weather, keyboard/keybind/emoji, dock/window overview, and expansion surfaces. Commit checkpoints are intentionally not created unless explicitly requested in this session.

### Phase G: Zig Backend Preference
- Prefer Zig for new backend/helper binaries when QML/Quickshell service code becomes too slow, too complex, or too shell-command-heavy.
- Implemented helper: `void-shell-settings` for settings defaults/read/write normalization.
- Candidate future helpers: system metrics daemon, log tail/normalizer, hardware sensor aggregation, and IPC bridge.
- Keep Zig helpers optional at first and communicate through simple stdout JSON, files, or local IPC.

Acceptance:
- Zig is used where it simplifies reliability/performance, not as premature architecture.
- QML remains responsible for presentation; Zig helpers own data collection or durable backend behavior.

Status: covered for settings persistence via `src/settings/main.zig`; further Zig helpers are deferred until QML command parsing becomes too slow or unreliable.

### Phase H: Interactive Tactical Expansion Surfaces
- Turn selected left/right panel child elements into click targets that open central enlarged tactical panels.
- Current target: `LeftTacticalPanel` uses `AnalogOrbitClock` as the orbital entry; clicking it opens an enlarged orbital analysis panel in the center safe area.
- Expanded orbital panel shows a graphical top-down solar-system view using QML drawing primitives, approximate time-based planet positions, orbit rings, trails, reticles, translucent overlays, and tactical warning-yellow labels.
- The previous ASCII/globe direction is superseded and preserved only as historical context.
- The transition should feel mechanical/cybernetic: the expanded panel should visibly deploy from the clicked source widget using origin-aware scale/position motion, then lock into the center safe area with hard-frame deployment, warning accent flashes, scanline continuity, and dense diagnostic labels.
- Use a reusable overlay pattern in `modules/hud/` instead of folding expansion logic into individual components.
- Keep data local/deterministic for the MVP; real astronomy ephemeris or network-backed space data is deferred.

Acceptance:
- Clicking the left `AnalogOrbitClock` opens a central expanded orbital panel that scales/moves out from the left-panel origin instead of flashing in at the center.
- Closing the expanded panel restores normal HUD interaction and input regions.
- Overlay remains inside the center safe area and does not invalidate edge exclusion-zone behavior.
- Graphical orbital content replaces ASCII with high-density sci-fi visual language while preserving approximate time-based local ephemeris motion and central safe-area sizing.
- The first implementation is reusable for later right-panel expansions such as CPU core matrix, network graph, filesystem matrix, or log stream drill-down.

Status: covered by `ExpansionService`, graphical `OrbitalExpansionPanel`, and CPU/network/filesystem/log expansion panels using shared central safe-area deployment. ASCII acceptance is superseded by the graphical orbital requirement.

### Phase I: Orbital Planet Map Optimization
- Improve the graphical orbital map's visual hierarchy and performance as a dedicated rendering pass.
- Preserve current-time approximate ephemeris, trails, labels, reticles, translucent overlays, close behavior, and central safe-area sizing.
- Optimize Canvas/animation repaint behavior if CPU usage becomes visible; avoid unnecessary redraw loops.
- Improve depth through clearer orbit hierarchy, label placement, glow/trail restraint, and tactical metadata density.

Acceptance:
- Planet positions remain deterministic and time-derived without network access.
- Orbital labels and tracks stay readable at common 1080p/1440p central safe-area dimensions.
- A short manual orbital open/close smoke check passes after `quickshell -p .`.

Status: covered by the completed orbital planet map optimization phase; future orbital work should be driven by screenshot/performance feedback.

## Prioritized Next Steps

1. Screenshot-driven visual tuning.
   - Tune panel proportions, font sizes, yellow intensity, scanline opacity, and graph density from real screenshots.
   - Keep `quickshell -p .` warning-free after every visual pass.
   - Verify edge exclusion zones push real Hyprland windows into the center safe area on the target monitor.

2. Tactical command center.
   - Convert the settings overlay into a broader command center with quick toggles, system overview, service statuses, and power actions.
   - Keep settings controls available, but group them so the panel does not become a long flat list.
   - Use existing services first; avoid adding plugin registries.

3. Broader reference-shell features.
   - Candidate features: interactive tactical expansion surfaces, richer tray drawers, idle/power profile controls, wallpaper/theme management, keyboard layout/keybind surfaces, and optional desktop widgets.
   - Each feature should include a tactical visual module, service boundary, fallback behavior, validation, and commit checkpoint.

4. Left/right panel interaction model.
   - Current left orbital entry is `AnalogOrbitClock`; it replaced the original globe affordance after time-based orbital ephemeris work.
   - Use a central overlay module controlled by small shared state instead of turning each edge panel into a separate popup owner.
   - Apply the same interaction pattern to additional right/edge drill-downs when new domains need central detail surfaces.

5. Niri compositor support.
    - Covered: `CompositorService.qml` provides the shared boundary and `NiriService.qml` provides Niri fallback/documented command integration.
    - Covered: command-center diagnostics now surface active backend, Hyprland/Niri status, workspace rows, and active window identity through `CompositorService.diagnosticRows`.
    - Covered: compositor backend/status/workspace transitions are recorded in `ServiceLogService` for diagnostics history.
    - Covered: command-center overview and user docs now expose the active compositor backend through the shared facade.
    - Covered: window focus uses stable compositor `windowKey` values instead of display titles when available.
    - Covered: compositor workspace/focus actions update visible action status and structured service-log entries.
    - Covered: top workspace strip clamps and elides compositor-provided workspace labels for Niri compatibility.
    - Remaining check is manual validation inside a real Niri session when available.

6. Orbital planet map optimization.
    - Covered: graphical orbital depth, label hierarchy, and bounded repaint behavior were improved while preserving current ephemeris contracts.

## Reference Feature Gap Analysis

The reference shells provide a much broader desktop environment than the current tactical HUD. Missing features should be added as vertical slices, preserving this project's machine-interface visual language instead of copying Material/Noctalia/Caelestia styling.

### Already Covered In This Project
- Full-screen tactical HUD surface.
- Top/bottom status bars.
- Hyprland workspace display and switching.
- Live CPU, memory, network, and filesystem stats.
- Audio and microphone volume/mute polling and controls via `wpctl`.
- Local audio spectrum visualizer driven by live volume/playback state.
- Session lock/logout/reboot/shutdown controls with confirmation.
- Power profile and idle inhibitor controls with command fallback.
- Battery/power-source display with AC/no-battery fallback.
- Media/MPRIS display and previous/play-pause/next controls via `playerctl`.
- Minimal system tray strip and command-center tray drawer using Quickshell status notifier items, including Quickshell v0.3 menu display bridging.
- Edge exclusion zones that reserve real screen space and push Hyprland windows into the center safe area.
- Command center foundation with app/action launcher search.
- Notification server fallback, DND/history controls, and tactical toast UI.
- Network/VPN/Bluetooth detail and Wi-Fi scan telemetry from `nmcli` and `bluetoothctl`.
- Persistent theme profiles for amber/green/blue/red tactical palettes.
- Persistent tactical background modes for void/grid/radar surfaces.
- Clipboard buffer using `wl-paste`/`wl-copy` with command center history controls.
- Local calendar grid and agenda state in the command center.
- Active window telemetry and current workspace window overview.
- Compact mission dock in the bottom bar for current workspace windows.
- Local weather via wttr.in with safe fetch fallback.
- Environment/night-light telemetry via local process detection fallback.
- Keyboard layout telemetry from Hyprland devices with command fallback.
- Hyprland keybind list telemetry with command fallback.
- Local emoji palette with clipboard copy fallback.
- Interactive orbital expansion overlay originally had ASCII solar-system telemetry, now superseded by the graphical surface.
- Interactive orbital expansion overlay uses a graphical sci-fi orbit/sensor view with approximate time-based ephemeris positions.
- Left orbital entry uses a mimetic analog clock instead of the original globe.
- CPU core matrix drill-down expansion using the shared central overlay pattern.
- Network matrix drill-down expansion using the shared central overlay pattern.
- Filesystem matrix drill-down expansion using the shared central overlay pattern.
- Log stream drill-down expansion using the shared central overlay pattern.
- Tactical settings panel foundation.
- Launcher calculator provider (`=<expr>`) and shell command provider (`$ <command>`).
- Lightweight structured service event log in the command center.
- Zig settings helper with JSON normalization.
- Hyprland namespace/blur documentation.

### Missing High-Value Features From References
- Interactive tactical expansion surfaces.
  - References: dashboard popouts, detail drawers, and desktop widget overlays in Caelestia/Noctalia/DankMaterialShell.
  - Tactical version: click left/right panel child elements to deploy central enlarged machine-interface panels. The orbital clock opens a graphical time-based ephemeris surface, and CPU, network, filesystem, and log stream drill-downs are implemented; later surfaces can drill into tray or weather if needed.
  - Covered: the orbital ASCII/globe prototype has been replaced with an analog-clock entry and a graphical sci-fi orbit/sensor surface.

- Dashboard/control center popout.
  - References: Caelestia dashboard, Noctalia panels, DankDash/control center.
  - Tactical version: command-center panel with quick toggles, system overview, media, calendar, weather, and power actions.

- App launcher and search.
  - References: Caelestia launcher, Noctalia launcher providers, Dank app drawer/search.
  - Tactical version: keyboard-first command palette with apps, actions, settings entries, calculator, and shell commands.

- Notifications and toast system.
  - References: Caelestia notifications/sidebar, Noctalia notification history/rules/toasts, Dank notification service/toasts.
  - Tactical version: alert stream, notification history drawer, rules, DND toggle, and tactical toast cards.

- Audio, microphone, and media/MPRIS.
  - References: Caelestia Audio/Players/Lyrics, Noctalia AudioService/MediaService/SpectrumService, Dank AudioService/MprisController/MediaPlayerTab.
  - Tactical version: audio levels, microphone controls, mute controls, MPRIS track display, local spectrum/visualizer, and local lyrics file fallback.

- Network detail, VPN, Bluetooth.
  - References: Caelestia Network/Nmcli/VPN/Bluetooth popouts, Noctalia Network/VPN/Bluetooth services, Dank Network/VPN/Bluetooth services.
  - Tactical version: network detail panel, Wi-Fi list, VPN status, Bluetooth device monitor, Wi-Fi rescan/connect actions, active connection reconnect/drop actions, and Bluetooth power toggle.

- Wallpaper/theme/color management.
  - References: Caelestia wallpapers/colours, Noctalia theme/color/wallpaper services, Dank wallpaper/theme browser.
  - Tactical version: theme profile selector, warning-yellow palette tuning, local tactical background modes, local wallpaper scan/apply integration, and sampled color-to-profile suggestion.

- Dock/taskbar/active window overview.
  - References: Dank dock/taskbar/overview, Noctalia dock/desktop widgets, Caelestia active window/window info.
  - Tactical version: compact mission dock, active window details, workspace overview overlay.

- System tray.
  - References: Caelestia tray, Noctalia tray panel/widget settings, Dank system tray bar.
  - Tactical version: tray drawer with square tactical icon cells, activate/secondary-activate controls, `SystemTrayItem.display()` menu bridging, and explicit protocol affordance text. Native menu styling remains delegated to the platform bridge by design.

- Session/power/idle/lock controls.
  - References: Caelestia session/idle/lock, Noctalia session menu/idle/power profile, Dank session/power sleep/idle services.
  - Tactical version: authenticated power menu, idle inhibitor, power profile, profile hints, and lock/logout/reboot/shutdown actions.

- Clipboard, keyboard layout, emoji, keybinds.
  - References: Noctalia clipboard/emoji/keyboard services, Dank keybinds/clipboard, Caelestia keyboard layout popout.
  - Tactical version: clipboard buffer panel, keyboard layout indicator, keybind list, local keybind recorder/template copier, and local emoji palette.

- Weather, calendar, location/night light.
  - References: all three have weather/calendar/location-related panels or services.
  - Tactical version: environmental telemetry card with weather, calendar agenda, night-light status.

- Desktop widgets and plugin/IPC system.
  - References: Noctalia plugins/desktop widgets/IPC, Dank plugins/desktop widgets/IPC, Caelestia utilities/drawers.
  - Tactical version: intentionally out of scope for this task. The current shell uses first-party modules/services only; no plugin registry or IPC layer is needed until external consumers or user-configurable third-party widgets are explicitly required.

### Remaining Scope Decision

All concrete high-value roadmap gaps for this planning task are now covered as first-party tactical slices. Further work should be opened as new Trellis tasks only if it introduces a new product direction, such as third-party widget plugins, custom tray menu rendering beyond Quickshell's native bridge, or deeper network credential management.

### Recommended Feature Build Order

0. Interactive panel expansion MVP.
- Covered: central expansion overlay state and module, left analog clock click target, origin-aware cyber/mechanical orbital deployment animation, and approximate time-based orbital ephemeris telemetry.
   - Covered: orbital surface rewritten as graphical sci-fi orbit visualization; ASCII prototype removed from the active surface.
   - Covered: right-panel CPU matrix drill-down using the shared central overlay pattern.
   - Covered: right-panel network matrix drill-down using the shared central overlay pattern.
   - Covered: right-panel filesystem matrix drill-down using the shared central overlay pattern.
   - Covered: right-panel log stream drill-down using the shared central overlay pattern.
   - Next expansions are optional polish or new domains, not required for the current interactive expansion MVP.

1. Settings persistence wiring.
   - Connect QML `SettingsService` to `void-shell-settings` read/write.
   - Add panel visibility and update interval controls.

2. Audio and power/session controls.
   - Add first everyday-shell controls before broader dashboard features.

3. Battery and media/MPRIS.
   - Fill the remaining PRD status widgets with graceful hardware/session fallbacks.

4. System tray.
   - Implement after confirming Quickshell v0.3 status-notifier support.

5. Tactical command center.
   - Create the first large popout/panel surface.
   - Include quick toggles, service logs, power actions, and system overview.

6. Launcher/search.
   - Implement keyboard-first app/action/settings search.
   - Keep providers simple before adding registry abstractions.

7. Notifications/toasts.
   - Add notification capture, history, DND, and tactical toast visuals.

8. Network/VPN/Bluetooth detail.
   - Expand current network stats into actionable connectivity panels.

9. Wallpaper/theme management.
   - Add theme profiles and wallpaper/background controls.

10. Dock/taskbar/desktop controls.
   - Add mission dock, tray drawer, active window overview, and power/session menu.

11. Optional plugin/IPC system.
   - Defer until multiple first-party panels/widgets need dynamic registration.
