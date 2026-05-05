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
- `Sparkline.qml`
- `ToggleRow.qml`

Good component traits:

- accepts simple props
- no shell-command execution
- no direct Hyprland/system parsing
- reusable across multiple modules
- uses `Theme.qml` for repeated colors/sizes

### Modules

Files in `modules/hud/` should represent visible product features.

Examples:

- `TopStatusBar.qml`
- `LeftTacticalPanel.qml`
- `CenterTerminalPanel.qml`
- `RightMonitorPanel.qml`
- `SettingsPanel.qml`

Good module traits:

- composes several components
- reads shaped data from services
- contains minimal glue logic only
- owns layout for one product surface or one expansion panel

### Expansion Surfaces

Central drill-downs are product surfaces, not generic components.

Rules:

- put them in `modules/hud/*ExpansionPanel.qml`
- route open/close state through `services/ExpansionService.qml`
- size them from `HudLayout` central safe-area metrics
- keep the visual language tactical and high-density
- do not add separate popup/window owners per edge-panel child

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

---

## Common Mistakes

- putting service logic inside `components/`
- growing `HudLayout.qml` instead of extracting a new module
- bypassing `Theme.qml` with ad-hoc constants
- copying the visual language of reference shells instead of adapting it to this project
