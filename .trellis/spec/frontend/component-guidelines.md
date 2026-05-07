# Component Guidelines

> How components are built in this project.

---

## Overview

The project uses three layers:

- `components/` for reusable tactical UI primitives
- `modules/hud/` for composed feature surfaces
- `services/` for state and external integrations

The guiding rule is: components render, modules compose, services fetch/state-manage.

---

## Component Structure

### Components

Files in `components/` should be small and visual-first. Components can contain local animation and pointer affordances, but they should not own cross-surface application state.

Examples:

- `TacticalFrame.qml`
- `MetricRow.qml`
- `SectionHeader.qml`
- `Sparkline.qml`
- `ToggleRow.qml`
- `AnalogOrbitClock.qml`
- `CentralPanelChrome.qml`

Good component traits:

- accepts simple props
- no shell-command execution
- no direct Hyprland/system parsing
- reusable across multiple modules
- uses `Theme.qml` for repeated colors/sizes
- exposes signals for user intent, such as `activated()`, rather than directly owning cross-surface state

### Modules

Files in `modules/hud/` should represent visible product features.

Examples:

- `TopStatusBar.qml`
- `LeftTacticalPanel.qml`
- `CenterTerminalPanel.qml`
- `RightMonitorPanel.qml`
- `SettingsPanel.qml`
- `CommandCenterDiagnosticsColumn.qml`

Good module traits:

- composes several components
- reads shaped data from services
- contains minimal glue logic only
- owns layout for one product surface or one expansion panel
- may compose many service status lines when the surface is explicitly a diagnostics/readout module

### Expansion Surfaces

Central drill-downs are product surfaces, not generic components.

Rules:

- put them in `modules/hud/*ExpansionPanel.qml`
- route open/close state through `services/ExpansionService.qml`
- size them from `HudLayout` central safe-area metrics
- keep the visual language tactical and high-density
- do not add separate popup/window owners per edge-panel child

## Scenario: Orbital Planet Map Rendering Contract

### 1. Scope / Trigger

- Trigger: optimizing or materially changing `modules/hud/OrbitalExpansionPanel.qml` rendering, animation, or orbital metadata.
- Applies to: graphical orbit paths, planet nodes, trails, labels, reticles, metadata rows, Canvas/animation repaint behavior, and close/safe-area integration.
- This is a central expansion surface contract because the orbital panel is the highest-priority visual drill-down and must preserve expansion behavior while improving rendering.

### 2. Signatures

- Surface: `OrbitalExpansionPanel { signal closeRequested() }` or equivalent existing close dispatch through `ExpansionService.close()`.
- Deployment owner: `HudLayout.qml` sets `width`, `height`, `x`, `y`, `scale`, `opacity`, and origin-aware motion.
- Time source: `services/Time.qml` / `Time.now` or existing local timer state.
- Planet data fields should remain local/offline and include at least:
  - `name: string`
  - `periodDays: number`
  - `epochLongitude: number`
  - `radiusScale` or display-distance equivalent
  - derived current longitude/phase for display metadata.

### 3. Contracts

- Planet positions must remain deterministic and derived from current time plus local orbital approximations; no network ephemeris dependency for this optimization phase.
- Orbital optimization must not move safe-area sizing or deployment geometry into `OrbitalExpansionPanel.qml`; `HudLayout.qml` remains the owner.
- Close behavior must stay consistent with other central panels: visible close affordance plus `Escape` routing via `HudLayout.qml`/`ExpansionService`.
- Canvas or animation repaint should be bounded to actual visual state changes or controlled timers; avoid unnecessary high-frequency redraw loops.
- Labels must elide, clamp, or reposition to remain readable at common 1080p and 1440p central safe-area dimensions.
- Visual language must remain tactical/sci-fi: warning-yellow accents, translucent sensor surface, orbit hierarchy, reticles, metadata, and mechanical/cyber motion language.

### 4. Validation & Error Matrix

- Missing/invalid planet field -> use safe default or skip that body; do not break the entire panel.
- Central safe area small -> labels/metadata elide or compress; no critical close affordance clipping.
- Time source unavailable -> use current local `Date` fallback or stable deterministic phase; no network requirement.
- Canvas repaint loop consumes visible CPU -> fail performance review; reduce timer frequency or repaint only on phase changes.
- Orbital surface computes global screen geometry -> fail review; duplicates `HudLayout.qml` responsibility.
- Close route changes or `Escape` regresses -> fail smoke/manual review.

### 5. Good/Base/Bad Cases

- Good: a rendering pass improves orbit hierarchy and label placement while planet phase still derives from period/epoch data and close/safe-area behavior is unchanged.
- Base: small visual tweaks to colors/trails can stay inside `OrbitalExpansionPanel.qml` if they use `Theme.qml` values and do not alter service contracts.
- Bad: replacing the panel with static mock positions, network-only astronomy data, or a new popup owner outside `ExpansionService`.

### 6. Tests Required

- QML lint: `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`.
- Runtime smoke: `timeout 8s quickshell -p .` must show `Configuration Loaded` without startup QML errors.
- Manual orbital smoke: click the analog orbital clock, verify the panel opens inside the central safe area, labels/metadata are readable, and close/backdrop/`Escape` still close it.
- Determinism assertion: changing current time changes derived planet phase without network access.
- Performance assertion: watch for obvious repaint/CPU spikes during idle orbital display after optimization.

### 7. Wrong vs Correct

#### Wrong

```qml
// Static positions look stable but break the time-derived ephemeris contract.
property var planets: [{ name: "MARS", x: 120, y: 80 }]
```

#### Correct

```qml
function longitudeFor(body: var, dayCount: real): real {
    return (body.epochLongitude + dayCount / body.periodDays * 360) % 360;
}
```

Keep orbital visuals grounded in deterministic local phase data while optimizing the graphical presentation.

## Scenario: Central Surface Chrome Contract

### 1. Scope / Trigger

- Trigger: adding or refactoring command-center or central expansion panel chrome.
- Applies to: `modules/hud/CommandCenterPanel.qml` and non-orbital `modules/hud/*ExpansionPanel.qml` surfaces, currently through `components/CentralPanelChrome.qml`.
- Exception: `OrbitalExpansionPanel.qml` may keep a custom translucent sensor-overlay layout when a full framed card would weaken the intended sci-fi sensor surface.

### 2. Signatures

- Shared chrome component: `CentralPanelChrome { property alias headerText; default property alias content; property bool commandCenter }`.
- Close affordance component: `PanelCloseButton { signal closeRequested() }`.
- Command center close action: `onCloseRequested: SettingsService.panelOpen = false`.
- Expansion close action: `onCloseRequested: ExpansionService.close()`.
- Surface sizing contract: `HudLayout.qml` sets `width`, `height`, `x`, and `y`; the surface must not compute global safe-area geometry itself.

### 3. Contracts

- Header text must be visible near the top of the surface and use `TacticalLabel` or `TacticalFrame.title`.
- The top-right close button must use `PanelCloseButton`, not a hand-rolled `Rectangle` + `MouseArea` clone.
- Margins and top offsets must use `Theme.panelPadding`, `Theme.gap`, and component implicit sizes instead of repeated one-off numbers when possible.
- Dense content must stay inside a `Flickable` or use `Text.ElideRight`; central surfaces should not rely on clipping alone to hide overflow.
- `HudLayout.qml` owns deployment animation, origin, and safe-area dimensions; child surfaces own only internal layout.

### 4. Validation & Error Matrix

- Missing close button -> fail review; user cannot consistently escape via visible UI.
- Surface computes global safe-area dimensions internally -> fail review; duplicates `HudLayout.qml` responsibility.
- Content overflows without scrolling/elision -> fail `quickshell -p .` manual smoke check on 1080p/1440p layouts.
- Orbital forced into generic framed panel -> fail visual review unless explicitly requested; it violates the sensor-overlay exception.

### 5. Good/Base/Bad Cases

- Good: CPU/network/filesystem/log panels share `PanelCloseButton`, common header spacing, and scroll/elide dense data.
- Good: power/battery drill-downs use `CentralPanelChrome`, are routed by `ExpansionService`, and reuse `BatteryService`/`PowerProfileService` rather than creating new service state.
- Good: media drill-downs use `CentralPanelChrome`, are routed by `ExpansionService`, and call existing `MediaService.control()` actions instead of duplicating playerctl commands.
- Base: a one-off experimental panel may use `TacticalFrame` directly, but still uses `PanelCloseButton` and `Theme` constants.
- Bad: each panel defines its own `CLOSE` rectangle, duplicated margins, and custom close behavior.

### 6. Tests Required

- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml` must pass after QML chrome changes.
- `git diff --check` must pass before the phase checkpoint.
- `timeout 5s quickshell -p .` or an equivalent short startup smoke check must show `Configuration Loaded` and no startup QML errors when a display/session is available.
- Manual assertion points: close button visible, close button works, `Escape` still closes via `HudLayout.qml`, panel remains inside central safe area, dense content remains reachable or elided.

### 7. Wrong vs Correct

#### Wrong

```qml
Rectangle {
    anchors.right: parent.right
    anchors.top: parent.top
    width: 74
    height: 24

    MouseArea {
        anchors.fill: parent
        onClicked: ExpansionService.open = false
    }

    Text { text: "CLOSE" }
}
```

#### Correct

```qml
PanelCloseButton {
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.rightMargin: Theme.panelPadding
    anchors.topMargin: 8
    onCloseRequested: ExpansionService.close()
}
```

---

## Props Conventions

- Prefer explicit typed properties like `property bool`, `property int`, `property string`.
- Use `required property` for delegate/model data when the component is invalid without it.
- Pass already-formatted display values into visual components when possible.

Examples:

- `MetricRow.qml` receives `label`, `value`, `progress`, `accent`.
- `LiveIndicator.qml` receives only `label`.

---

## Styling Patterns

- Centralize colors, spacing, sizing, and breakpoints in `theme/Theme.qml`.
- Centralize repeated motion timings and collapsed scale values in `theme/Theme.qml`.
- Do not scatter hard-coded tactical yellow/gray values across modules.
- Preserve the hard-edged machine-interface style: sharp corners, dense typography, thin borders, warning-yellow highlights, and translucent HUD layers.
- Scanline and polish effects should stay optional and controllable through settings state.
- Graphical sci-fi effects should still be built from small QML primitives or a focused Canvas/Shape surface, not copied wholesale from reference shells.

---

## Accessibility

This project is visual-first and desktop-shell-specific, but minimum interaction clarity still applies.

- clickable areas should have obvious hover/active feedback
- labels should elide rather than overflow
- fallback states should render readable text, not blank panels
- tray controls should show whether an item advertises a menu and should not call native menu display APIs without a real Window-backed surface

---

## Common Mistakes

- putting service logic inside `components/`
- growing `HudLayout.qml` instead of extracting a new module
- bypassing `Theme.qml` with ad-hoc constants
- copying the visual language of reference shells instead of adapting it to this project
