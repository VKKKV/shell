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
