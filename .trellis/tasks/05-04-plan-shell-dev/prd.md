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

Follow-up feedback captured 2026-05-05:

- ASCII orbital rendering feels visually weak/ugly for the desired shell style.
- Future orbital expansion should use a graphical implementation instead of ASCII.
- The graphical orbital view must be strongly sci-fi: glowing orbit paths, animated planets, depth/scan effects, tactical labels, reticles, translucent overlays, warning-yellow accents, and mechanical/cyber motion language.

### Requirements (Evolving)

- Make command/settings panel entry discoverable from visible HUD affordances, not only a hidden keybind.
- Improve side-panel content sizing so panels expand/clamp based on real content and avoid clipped right-panel text.
- Set default tactical accent to a brighter target-like yellow and expose color/intensity adjustment in command/settings UI.
- Replace fixed-size expansion surfaces with central safe-area-aware sizing.
- Previous ASCII orbital direction has been superseded.
- Use a graphical sci-fi orbit system while preserving central safe-area sizing and deterministic local motion.
- Apply the same responsive expansion container behavior to CPU/network/filesystem/log drill-downs.

### Acceptance Criteria (Evolving)

- [x] A visible HUD control opens the command/settings panel.
- [x] Right monitor panel labels/values elide or wrap intentionally without disappearing or clipping critical text.
- [x] Default theme uses bright warning yellow close to `target.png`, and settings can adjust/tune the accent.
- [x] Expansion panels size themselves from the central safe area instead of fixed constants.
- [x] Graphical orbital expansion replaces ASCII with animated orbit rings, glowing planet nodes, trails, labels, reticles, and sci-fi HUD effects.
- [x] CPU/network/filesystem/log expansions no longer clip at common 1080p/1440p dimensions.

### MVP Decision: Visual Fit Pass 1

Chosen scope: option 2, recommended.

- Include visible settings entry, target-like bright yellow defaults/controls, right-panel text clipping fixes, shared central expansion sizing, and a reworked orbital expansion.
- Orbital expansion should be the main visual investment: semi-transparent ASCII top-down solar-system orbit map, live positions, and visible track history sized to the central safe area.
- CPU/network/filesystem/log expansions should use the improved shared dynamic container sizing, but detailed internal polish is deferred unless it is needed to avoid severe clipping.

Out of scope for this MVP:

- Full redesign of every non-orbital expansion panel.
- Exact pixel/color matching from `target.png`, because this environment cannot inspect the image directly; use updated `target.md` and user feedback as source of truth.

### Follow-up Plan: Graphical Orbital Rewrite

The ASCII orbital overlay was treated as a temporary prototype and has been replaced by a graphical top-down solar-system visualization:

- Uses QML/Qt Quick primitives (`Canvas`, `Rectangle`, `Repeater`) instead of text glyphs as the primary rendering language.
- Renders translucent orbit rings/ellipses sized from the central safe area.
- Animates planet nodes deterministically with local phase data; no network ephemeris required.
- Adds trails, glow halos, scan/radial lines, reticles, distance ticks, coordinate labels, and warning-yellow tactical annotations.
- Keeps the overlay partially transparent so it feels integrated into the central HUD rather than a modal card.
- Preserves the existing `ExpansionService` and central safe-area deployment behavior.
- Avoid a generic flat chart; the visual target is a high-density sci-fi tactical sensor display.

### Technical Notes

- The model cannot inspect `target.png` directly in this environment; use `target.md`, existing screenshot feedback, and user description as the source of truth unless a textual color/geometry spec is provided.

## 7. Refinement Backlog

Captured after tray menu fix on 2026-05-05.

### Runtime Fixes

- Quickshell platform tray menus require QApplication mode. Root `shell.qml` should keep `//@ pragma UseQApplication` before imports so `SystemTrayItem.display(...)` can open native platform menus.

### Refinement Opportunities

- Visual hierarchy: continue reducing dense text collisions by prioritizing primary telemetry, moving secondary diagnostics into command-center/expansion surfaces, and keeping edge panels readable at a glance.
- Motion language: make deploy/close transitions, scan sweeps, and graph animations feel consistently mechanical rather than generic fade/scale.
- Color controls: accent color is now configurable; future refinement can expose finer contrast/opacity controls for border, dim text, scanline opacity, and panel background.
- Central surfaces: settings and expansion panels now share safe-area sizing; future work should standardize close controls, headers, and status strips across every central surface.
- Tray UX: native menu bridging works through QApplication mode; future work can add visual state hints for items with native menus and safer fallback text when a tray item lacks menu support.
- Tray UX update: `PlatformMenuEntry.display()` needs a real Window, not an item delegate. Current implementation should avoid direct `display(item, ...)` calls and use `activate()`/`secondaryActivate()` fallback until a Window-backed or custom tray menu surface is implemented.
- Performance: Canvas orbital effects and polling services should be profiled if CPU usage becomes visible; keep deterministic local animation but avoid unnecessary repaint loops.

### Suggested Next Refinement MVP

- Standardize central panel chrome across command center and CPU/network/filesystem/log expansions.
- Standardize panel button styling, starting with central panel close buttons and close shortcuts.
- Add a small visual density setting (`compact`, `normal`, `dense`) that adjusts font sizes, row heights, and graph heights.
- Add a runtime diagnostics page in command center showing Quickshell mode, enabled services, missing commands, and recent service log warnings.

### Development Checkpoint Protocol

User instruction captured 2026-05-05:

- Continue project optimization as staged refinement work.
- After each completed development phase, run the relevant verification commands, create a git commit, and push the branch.
- Do not treat a phase as complete until the task journal/PRD or plan has been updated with the completed slice and verification result.
- If verification fails, fix or report the blocker before committing/pushing.
- If remote push is unavailable or rejected, keep the local commit and report the exact push blocker.

Definition of a completed phase for this project:

- A coherent optimization slice is implemented.
- `qmllint` passes for QML changes.
- `zig build` passes when Zig/settings helper behavior is touched.
- `git diff --check` passes.
- A short `quickshell -p .` smoke check passes when a display/session is available.
- Trellis journal is updated.

### Next Optimization MVP: Central Panel Chrome Unification

Decision captured 2026-05-05: prioritize central panel consistency before density controls, diagnostics, tray custom menus, or performance profiling.

Requirements:

- Standardize common central-surface chrome across command center and CPU/network/filesystem/log expansion panels.
- Preserve the existing graphical orbital surface style; do not force it into a heavy framed card if that would weaken the central sensor look.
- Reuse existing primitives first, especially `PanelCloseButton`, `TacticalFrame`, `TacticalLabel`, and theme constants.
- Avoid growing `HudLayout.qml` with surface internals; central surfaces should own their own layout while `HudLayout.qml` only positions/deploys them.
- Keep `Escape` close behavior and existing click-to-open expansion routes unchanged.
- Keep this phase focused on consistency, not a redesign of every panel's internal data visualization.

Acceptance Criteria:

- [x] Command center and CPU/network/filesystem/log expansion panels use a consistent top-right close affordance and header placement.
- [x] Shared dimensions, margins, border behavior, and close-button positioning come from reusable code or theme constants instead of repeated one-off values.
- [x] Central surfaces retain safe-area sizing from `HudLayout.qml` and remain scrollable/elided where content is dense.
- [x] Orbital expansion still opens as a translucent sci-fi sensor surface and keeps its current visual priority.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: central panels now share safe-area sizing and close behavior, but each panel still hand-rolls some chrome/header/layout details. This creates inconsistency and makes future central surfaces more expensive to add.
- Decision: implement a small shared central-panel chrome primitive or minimally extend existing primitives, then migrate command center and non-orbital expansion panels to it. Keep orbital mostly custom because it is intentionally a sensor overlay rather than a framed information panel.
- Consequences: improves consistency and reduces duplication with low product risk. The trade-off is that this does not yet solve visual density controls, diagnostics, tray custom menus, or performance profiling; those remain future phases.

### Next Optimization MVP: Time-Based Orbital Ephemeris

User instruction captured 2026-05-05: add a development phase for `OrbitalExpansionPanel` to calculate planet positions from the current time and display related orbital information on the panel.

Requirements:

- Replace purely arbitrary local phase movement with deterministic time-based orbital positions derived from the current date/time.
- Use local, offline astronomical approximations; do not require network ephemeris access.
- Display per-planet orbital metadata in the panel, such as heliocentric longitude/phase, orbital period, approximate distance scale, and update/source status.
- Preserve the current graphical sci-fi orbital surface, trails, reticles, labels, translucent overlay, and central safe-area sizing.
- Keep the implementation inside `OrbitalExpansionPanel.qml` unless reusable state becomes necessary; do not add a backend helper for this MVP.
- Clearly document that positions are approximate visual ephemerides, not precision astronomy data.

Acceptance Criteria:

- [x] Planet node positions are calculated from current time using each planet's orbital period and a known epoch offset.
- [x] The orbital display updates over time without network access.
- [x] The panel shows related orbital information for visible planets.
- [x] Existing orbital sci-fi visual language and close behavior are preserved.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: the orbital panel currently looks live but its motion is local/deterministic rather than grounded in actual date/time orbital phase.
- Decision: use simple circular heliocentric ephemeris approximations seeded from J2000-style epoch longitudes and sidereal orbital periods. This gives stable, time-derived top-down positions without adding network or precision ephemeris dependencies.
- Consequences: the visualization becomes more meaningful and explainable while remaining lightweight. The trade-off is limited astronomical precision; eccentricity, inclination, retrograde effects, and real ephemeris corrections remain out of scope unless a future task requires them.

### Panel Control Standardization

- Central overlays should close with a consistent shortcut: `Escape`.
- Command center should continue toggling with `Ctrl+Alt+S`, but `Escape` should close it when open.
- All central expansion panels should expose the same close affordance: top-right `CLOSE` tactical button, same dimensions, border logic, hover behavior, and text sizing.
- Future panel buttons should use a shared component rather than hand-rolled rectangles in each panel.
