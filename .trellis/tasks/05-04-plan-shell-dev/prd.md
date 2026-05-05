# PRD: Quickshell-based Shell Development

## 1. Project Goal
Develop a desktop shell (status bar and widgets) using the [Quickshell](https://quickshell.org/) framework, matching the visual style of `target.png` and drawing inspiration from modern shell implementations like Caelestia, Noctalia, and DankMaterialShell.

## 2. Visual & Functional Requirements
- **Visuals**: Clean, modern aesthetic (transparency, rounded corners, consistent padding).
- **Bar**: A top or bottom bar (based on `target.png`) containing various widgets.
- **Panel Interactions**: Left/right HUD panel child elements should become interactive tactical entry points. Clicking high-signal widgets, starting with the orbital globe, should open an enlarged central analysis panel instead of only showing static telemetry.
- **Widgets**:
    - **Workspaces**: Indicator for virtual desktops, showing active/inactive states.
    - **Clock**: Date and time display.
    - **System Stats**: CPU, RAM, and Battery usage.
    - **Networking**: WiFi/Ethernet status.
    - **Audio**: Volume control and indicator.
    - **Media**: Current playing track and controls.
    - **System Tray**: Integration for background apps.
    - **Orbital Expansion**: Enlarged globe/solar-system panel with ASCII orbital telemetry and cyber/mechanical motion language.

## 3. Technical Architecture
- **Language**: QML (Qt Quick) for UI, JavaScript for logic.
- **Framework**: Quickshell (v0.3.0+).
- **Environment**: Wayland (specifically Hyprland integration where applicable).
- **Modular Design**: Each widget should be a separate `.qml` file in a `modules/` directory for maintainability.

## 4. Development Roadmap
### Phase 1: Foundation
- Project initialization.
- Basic `shell.qml` with a `PanelWindow`.
- Setup of `modules/` directory.

### Phase 2: Core Layout
- Define the main bar's geometry and styling (anchors, height, background, etc.).
- Implement a `RowLayout` for widget placement (Left, Center, Right sections).

### Phase 3: Essential Widgets
- **Clock**: Basic time display.
- **Workspaces**: Basic integration with WM (e.g., Hyprland).
- **Power/Session**: Simple logout/restart/shutdown buttons.

### Phase 4: System Integration
- **System Stats**: Data fetching via `Quickshell.Io.Process` or services.
- **Audio/Brightness**: Integration with Pipewire/sysfs.
- **Network**: Integration with NetworkManager or similar.

### Phase 5: Polish & Interactivity
- Hover effects and transitions.
- Theming support (colors, fonts).
- Final visual adjustments to match `target.png`.
- Interactive left/right panel expansion surfaces.

### Phase 6: Tactical Expansion Panels
- Make selected left/right panel child elements clickable without breaking edge input pass-through.
- Implement a central enlarged overlay opened from `LeftTacticalPanel`'s orbital globe.
- Render a top-down solar-system/orbital view using ASCII/monospace labels and mechanical/cyber HUD framing.
- Keep expanded panels modular so right-panel elements can reuse the same overlay pattern later.

Acceptance:
- Clicking the small orbital globe opens a central tactical expansion panel.
- The panel can be closed with an obvious control and does not permanently block the normal HUD.
- The expanded panel preserves the machine-interface visual language: hard frames, scanlines, dense labels, yellow/gray contrast, and monospaced ASCII content.
- Planet/orbit positions update over time or expose deterministic live-looking phase movement without requiring network access.
- The implementation is split into reusable expansion primitives and a specific orbital/solar-system surface.

## 5. References
- Quickshell Docs: https://quickshell.org/docs/v0.3.0/
- Caelestia Shell: https://github.com/caelestia-dots/shell
- Noctalia Shell: https://github.com/noctalia-dev/noctalia-shell
- DankMaterialShell: https://github.com/AvengeMedia/DankMaterialShell
