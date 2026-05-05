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

### Next Optimization MVP: Orbital Entry Clock Rework

User instruction captured 2026-05-05: replace the original globe child panel with a mimetic/skeuomorphic clock, then move the click-to-open planetary map interaction onto that clock.

Requirements:

- Replace the left tactical panel's small orbital/globe child surface with a clock-like tactical instrument.
- The clock should read as a physical/mechanical HUD clock rather than plain text: circular dial, tick marks, hands/sweep, reticle or bezel language, and current time labels.
- Clicking the clock opens the existing `OrbitalExpansionPanel` planetary map.
- Remove or stop using the old globe affordance as the primary orbital expansion entry.
- Preserve left-panel sizing/scroll behavior and `ExpansionService.show("orbital", ...)` semantics.
- Keep implementation local and minimal: reuse `Time.qml`, `Theme.qml`, `TacticalLabel`, and existing component boundaries.

Acceptance Criteria:

- [x] The left panel shows a mimetic/skeuomorphic clock where the globe entry used to be.
- [x] The clock displays current time using `Time.now` and updates live.
- [x] Clicking the clock opens the existing orbital/planetary expansion panel.
- [x] The old globe is no longer the primary visible click target for orbital expansion.
- [x] Left-panel adaptive height/scrolling remains intact.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: after adding time-based planetary positions, the expansion entry should visually communicate time/orbital mechanics more directly than a decorative globe.
- Decision: replace the globe entry with a dedicated tactical clock component that owns its visual dial but delegates click behavior to the existing left-panel `ExpansionService.show("orbital", ...)` path.
- Consequences: improves discoverability and semantic fit for the orbital map. The trade-off is losing the standalone globe visual; if desired later, globe imagery can return as secondary decoration inside the clock or orbital panel.

### Next Optimization MVP: Appearance Font Size Control

User instruction captured 2026-05-05: add a development phase for adjusting font size from the settings panel. Future settings should be able to tune all appearance-related controls, including fonts and similar visual parameters.

Requirements:

- Add a settings-panel control for global font scale/size.
- Persist the font setting through the existing settings pipeline instead of keeping it session-only.
- Apply the setting through `Theme.qml` so existing `Theme.fontTiny`, `Theme.fontSmall`, `Theme.fontNormal`, `Theme.fontLarge`, and `Theme.fontClock` consumers update consistently.
- Keep defaults matching the current visual size.
- Clamp allowed values to a safe range so panels remain usable.
- Treat this as the first step toward broader appearance settings; do not implement every appearance option in this phase.

Acceptance Criteria:

- [x] Command-center settings expose a font size/scale control.
- [x] Font scale persists via `SettingsService.qml` and `void-shell-settings`.
- [x] Theme font properties respond to the setting without changing every consumer manually.
- [x] Invalid persisted font scale values are normalized/clamped to safe defaults.
- [x] Existing panel layout remains usable at minimum/default/maximum font scale.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: visual tuning currently covers accent/profile/background/intensity but not typography size, which is a core appearance control for dense HUD readability.
- Decision: add a single persisted `visual.fontScale` control first and derive existing theme font sizes from it. This is smaller and safer than introducing many per-font settings.
- Consequences: users can tune readability immediately, and future appearance controls can follow the same settings-service/helper/theme pattern. The trade-off is coarse global scaling rather than independent per-surface typography control.

### Next Optimization MVP: Appearance Opacity And Scanline Controls

User instruction context: continue broadening settings-panel appearance controls after font scaling so visual parameters can be tuned from the UI rather than hard-coded.

Requirements:

- Add settings-panel controls for panel opacity and scanline strength.
- Persist both settings through `SettingsService.qml` and `void-shell-settings`.
- Apply panel opacity through `Theme.qml` so tactical frames and shared panel backgrounds update consistently.
- Apply scanline strength through existing scanline rendering points without duplicating per-panel logic.
- Keep current defaults visually equivalent to the existing shell.
- Clamp values to safe ranges so panels remain readable.

Acceptance Criteria:

- [x] Command-center settings expose `PANEL OPACITY` and `SCANLINE STRENGTH` controls.
- [x] `visual.panelOpacity` and `visual.scanlineStrength` persist and normalize through the Zig helper.
- [x] Tactical frame backgrounds respond to panel opacity without changing every panel manually.
- [x] Existing scanline overlays respond to scanline strength and can still be disabled by `scanlinesEnabled`.
- [x] Defaults match the current look closely.
- [x] `qmllint`, `zig build`, `git diff --check`, settings helper clamp checks, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: after adding `visual.fontScale`, the next highest-value appearance controls are panel opacity and scanline strength because they affect global readability and visual density.
- Decision: add two coarse global settings, `visual.panelOpacity` and `visual.scanlineStrength`, instead of many per-component opacity knobs.
- Consequences: improves user-facing visual tuning while preserving simple global theme contracts. Fine-grained border/text/background opacity remains future work.

### Next Optimization MVP: Fine Appearance Contrast Controls

User choice captured 2026-05-05: continue appearance settings by adding `borderOpacity`, `dimTextOpacity`, and `lineContrast` controls.

Requirements:

- Add settings-panel controls for border opacity, dim text opacity, and line/accent contrast.
- Persist all three settings through `SettingsService.qml` and `void-shell-settings`.
- Apply them through `Theme.qml` so existing consumers inherit the values without per-panel rewrites.
- Keep current defaults visually equivalent to the current shell.
- Clamp values to safe ranges so low-contrast settings remain usable.
- Keep this phase focused on global visual tuning, not per-panel style profiles.

Acceptance Criteria:

- [x] Command-center settings expose `BORDER OPACITY`, `DIM TEXT`, and `LINE CONTRAST` controls.
- [x] `visual.borderOpacity`, `visual.dimTextOpacity`, and `visual.lineContrast` persist and normalize through the Zig helper.
- [x] `Theme.border`, `Theme.textDim`, `Theme.line`, and `Theme.lineDim` respond through central theme derivation.
- [x] Defaults match the current look closely.
- [x] `qmllint`, `zig build`, `git diff --check`, settings helper clamp checks, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: opacity and scanline controls improve large-surface tuning, but the HUD still needs user-facing controls for border subtlety, secondary text readability, and accent intensity.
- Decision: add three global visual parameters in `visual.*` and derive existing theme colors from them.
- Consequences: gives users more control over contrast without introducing per-component style state. The trade-off is that all panels share the same contrast profile.

### Priority Insert: Orbital Central Chrome Alignment

User instruction captured 2026-05-05: before continuing broader appearance control work, make the planetary/orbital panel border and central panel styling consistent with the other central panels.

Requirements:

- Update `OrbitalExpansionPanel.qml` so it uses the same central panel border/chrome language as the command center and CPU/network/filesystem/log panels.
- Preserve the orbital visualization, time-based ephemeris, planet labels, trails, and metadata.
- Preserve close behavior, `Escape` behavior, safe-area sizing, and `ExpansionService` routing.
- Avoid regressing the earlier requirement that orbital remains a strong sci-fi sensor surface; the shared chrome should frame it rather than turn it into a generic flat card.
- Finish this style alignment before continuing fine appearance contrast settings.

Acceptance Criteria:

- [x] `OrbitalExpansionPanel` uses the shared central panel chrome or an equivalent shared border/header/close implementation.
- [x] Orbital content remains visible and visually prioritized inside the unified frame.
- [x] The panel still displays time-based orbital metadata.
- [x] Close button and `Escape` behavior remain intact.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: `OrbitalExpansionPanel` intentionally stayed custom while central chrome was standardized, but the current product direction now prioritizes visual consistency across all central panels.
- Decision: align orbital with `CentralPanelChrome` or a shared equivalent while keeping the sensor surface as the content body.
- Consequences: improves central panel consistency. The trade-off is a slightly more framed orbital presentation, which should be mitigated by preserving translucent sensor content and dense orbital HUD details.

### Panel Control Standardization

- Central overlays should close with a consistent shortcut: `Escape`.
- Command center should continue toggling with `Ctrl+Alt+S`, but `Escape` should close it when open.
- All central expansion panels should expose the same close affordance: top-right `CLOSE` tactical button, same dimensions, border logic, hover behavior, and text sizing.
- Future panel buttons should use a shared component rather than hand-rolled rectangles in each panel.
