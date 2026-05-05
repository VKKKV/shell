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

## 6. Optimization Feedback: Visual Fit And Tactical Expansion

User feedback captured 2026-05-05:

- Settings panel exists but is not discoverable enough; the user cannot find how to open it.
- Left/right panels should resize to content more reliably; current automatic scaling is not sufficient.
- Right-side panel text is clipped or incomplete in places.
- Overall color does not match `target.png`; default should be a bright warning yellow closer to the target, and this should be adjustable from the settings panel.
- Orbital expansion panel does not match expectations. It should open as a partially transparent ASCII solar-system orbit view, dynamically sized from the central empty safe area, with real-time positions and visible tracks rendered as ASCII characters from a top-down view.
- Other central expansion panels also suffer from fixed sizing and clipped content; they should use the same dynamic central safe-area sizing model.

### Requirements (Evolving)

- Make command/settings panel entry discoverable from visible HUD affordances, not only a hidden keybind.
- Improve side-panel content sizing so panels expand/clamp based on real content and avoid clipped right-panel text.
- Set default tactical accent to a brighter target-like yellow and expose color/intensity adjustment in command/settings UI.
- Replace fixed-size expansion surfaces with central safe-area-aware sizing.
- Rework orbital expansion into a partially transparent ASCII top-down solar-system view with dynamic orbit positions and track traces.
- Apply the same responsive expansion container behavior to CPU/network/filesystem/log drill-downs.

### Acceptance Criteria (Evolving)

- [ ] A visible HUD control opens the command/settings panel.
- [ ] Right monitor panel labels/values elide or wrap intentionally without disappearing or clipping critical text.
- [ ] Default theme uses bright warning yellow close to `target.png`, and settings can adjust/tune the accent.
- [ ] Expansion panels size themselves from the central safe area instead of fixed constants.
- [ ] Orbital expansion renders a semi-transparent ASCII orbit map with live-looking positions and visible track history.
- [ ] CPU/network/filesystem/log expansions no longer clip at common 1080p/1440p dimensions.

### MVP Decision: Visual Fit Pass 1

Chosen scope: option 2, recommended.

- Include visible settings entry, target-like bright yellow defaults/controls, right-panel text clipping fixes, shared central expansion sizing, and a reworked orbital expansion.
- Orbital expansion should be the main visual investment: semi-transparent ASCII top-down solar-system orbit map, live positions, and visible track history sized to the central safe area.
- CPU/network/filesystem/log expansions should use the improved shared dynamic container sizing, but detailed internal polish is deferred unless it is needed to avoid severe clipping.

Out of scope for this MVP:

- Full redesign of every non-orbital expansion panel.
- Exact pixel/color matching from `target.png`, because this environment cannot inspect the image directly; use updated `target.md` and user feedback as source of truth.

### Technical Notes

- The model cannot inspect `target.png` directly in this environment; use `target.md`, existing screenshot feedback, and user description as the source of truth unless a textual color/geometry spec is provided.
