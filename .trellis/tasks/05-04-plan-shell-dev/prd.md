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

### Next Optimization MVP: Visual Density Profiles

User instruction context: continue staged shell optimization after fine appearance controls by implementing the backlog item for visual density tuning.

Requirements:

- Add a settings-panel control for visual density with `compact`, `normal`, and `dense` profiles.
- Persist the density profile through `SettingsService.qml` and `void-shell-settings` as `visual.density`.
- Keep default behavior visually equivalent by defaulting to `normal`.
- Apply density through `Theme.qml` so shared row heights, control heights, graph heights, and spacing can respond without one-off per-panel knobs.
- Clamp/normalize invalid persisted values back to `normal` in both QML and Zig.
- Keep the phase focused on coarse global density, not per-panel layout customization.

Acceptance Criteria:

- [x] Command-center settings expose `DENSITY` controls for `COMPACT`, `NORMAL`, and `DENSE`.
- [x] `visual.density` persists and normalizes through the Zig settings helper.
- [x] `Theme.qml` exposes density-derived sizing primitives for controls, rows, graphs, and spacing.
- [x] At least the command-center settings controls and major CPU/network/filesystem expansion graph/row surfaces use density-derived sizing.
- [x] Invalid persisted density values fall back to `normal`.
- [x] `qmllint`, `zig build`, `git diff --check`, settings helper normalization checks, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: typography, opacity, scanlines, and contrast are now tunable, but dense HUD surfaces still use fixed row/control/graph heights. Users need a coarse way to trade compactness against readability without editing QML.
- Decision: add a single persisted `visual.density` profile and derive common layout sizes from `Theme.qml`.
- Consequences: global density tuning becomes available with a small contract. The trade-off is that individual surfaces do not yet have independent density profiles; those can be added later only if real use shows a need.

### Next Optimization MVP: Runtime Diagnostics Page

Plan source: refinement backlog item for a runtime diagnostics page in command center showing Quickshell mode, enabled services, missing commands, and recent service log warnings.

Requirements:

- Add a command-center diagnostics surface/section using existing service state first.
- Show runtime mode and shell health signals such as QApplication/native tray mode, settings helper status, live-data state, scanlines state, and update interval.
- Show service availability/status lines for core integrations: Hyprland, system stats, network, audio/mic, media, weather, clipboard, launcher, tray, notifications, keyboard/keybinds, battery, and power/session.
- Highlight fallback/missing/warning states without dumping raw stderr into the UI.
- Include recent service log events from the existing structured log path.
- Keep the slice QML-only unless a new backend contract proves necessary.

Acceptance Criteria:

- [x] Command center exposes a discoverable diagnostics section or column.
- [x] Diagnostics include runtime mode/settings status and live-data/toggle state.
- [x] Diagnostics list core service status/fallback lines with warning emphasis.
- [x] Recent structured service log events are visible from the diagnostics surface.
- [x] Dense content scrolls/elides and respects existing command-center safe-area sizing.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: service fallbacks now exist across many integrations, but runtime health is distributed across overview/actions/log panels. A single diagnostics page makes missing command and fallback state easier to inspect.
- Decision: add diagnostics as a command-center module that composes existing service status fields and `ServiceLogService` events instead of adding a new backend helper.
- Consequences: improves operability with low implementation risk. The trade-off is that diagnostics are read-only and coarse; deeper profiling or raw log tailing remains future work.

### Next Optimization MVP: Mechanical Expansion Motion Pass

Plan source: refinement backlog item to make deploy/close transitions, scan sweeps, and graph animations feel consistently mechanical rather than generic fade/scale.

Requirements:

- Centralize common motion constants in `Theme.qml` instead of repeating one-off durations in `HudLayout.qml`.
- Apply the same expansion deploy timing to orbital, CPU, network, filesystem, and log expansion panels.
- Preserve origin-aware deployment from the clicked edge widget into the center safe area.
- Add a subtle overlay backdrop fade so expansion deploy/close feels staged instead of a hard flash.
- Keep the phase focused on motion consistency; do not redesign panel internals.

Acceptance Criteria:

- [x] Expansion panel `x`, `y`, `scale`, and `opacity` animations use shared theme motion constants.
- [x] Orbital and right-panel drill-downs use the same base timing/easing language while preserving their existing origins.
- [x] Expansion backdrop has a transition that does not block close behavior.
- [x] No click-to-open, close button, backdrop-close, or `Escape` close behavior regresses.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: central expansion surfaces already deploy from source widgets, but animation durations are repeated and orbital uses slightly different timing from the other panels.
- Decision: introduce small motion constants in `Theme.qml` and reuse them across the expansion layer.
- Consequences: improves consistency and keeps future expansion surfaces from copying magic animation values. The trade-off is not adding more advanced keyframed mechanical motion yet; that can follow if visual feedback calls for it.

### Next Optimization MVP: Tray Menu Affordance Polish

Plan source: refinement backlog item for tray UX hints and safer fallback text when a tray item lacks native menu support.

Requirements:

- Add visible state hints for tray items that expose native menus or are menu-only.
- Avoid attempting secondary/native menu activation when a tray item reports no menu.
- Keep using `activate()`/`secondaryActivate()` only; do not reintroduce `PlatformMenuEntry.display(item, ...)` until a Window-backed or custom tray menu surface exists.
- Improve drawer fallback copy so users understand left/right click behavior and menu availability.
- Preserve current tray strip and command-center drawer layout.

Acceptance Criteria:

- [x] Top tray strip visually differentiates menu-capable and menu-only items.
- [x] Tray drawer shows explicit `MENU`, `ONLY`, or `ACT` affordance per item.
- [x] Right-click on items without menus falls back to normal activation instead of unsafe menu display attempts.
- [x] No `PlatformMenuEntry.display(item, ...)` calls are introduced.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: tray menus previously failed when display was called with an item delegate. The current implementation avoids that by using activation fallbacks, but users still need clearer per-item affordance hints.
- Decision: keep the safe activation path and improve visible protocol labels instead of building custom menu rendering.
- Consequences: tray UX becomes clearer without risking native menu runtime errors. The trade-off is that menu styling and deeper menu browsing remain delegated/deferred.

### Next Optimization MVP: Command Center Settings Grouping

Plan source: prioritized command-center note to keep settings controls available but group them so the panel does not become a long flat list.

Requirements:

- Add clear tactical section headers inside `CommandCenterSettingsColumn.qml`.
- Preserve all existing settings controls, order, persistence, and behavior.
- Group related controls into readable clusters: visual palette, backdrop/wallpaper, system/data toggles, panel visibility, typography/density, surface/scanline opacity, contrast, and polling.
- Use reusable styling for section headers instead of ad-hoc repeated labels.
- Keep the settings column scrollable inside the existing command-center safe-area sizing.

Acceptance Criteria:

- [x] Settings column has visible grouped sections instead of one undifferentiated list.
- [x] No existing settings controls are removed or renamed in a way that breaks behavior.
- [x] Section header styling is reusable and registered in `components/qmldir` if implemented as a component.
- [x] Command-center layout and scroll behavior remain unchanged.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: the command center has grown into a broader control surface, but the settings column is still a long flat list of controls.
- Decision: add lightweight section dividers and group labels while preserving the current single-column scroll model.
- Consequences: improves discoverability and scanning with low risk. The trade-off is that this is not a full settings navigation/sidebar redesign.

### Planned Future Work: Niri Compositor Support

User instruction captured 2026-05-05: add Niri support to the development plan.

Requirements:

- Add Niri as a first-class future compositor target alongside Hyprland.
- Keep compositor-specific workspace/window parsing inside services, not HUD modules or visual components.
- Introduce a compositor-agnostic workspace/window service contract before replacing `HyprlandService` consumers.
- Preserve Hyprland behavior while adding Niri fallback/detection.
- Document expected Niri command/API integration before implementing it.

Acceptance Criteria:

- [x] Niri support has a scoped implementation phase before code changes begin.
- [x] A shared compositor state contract defines active workspace, workspace rows, active window, current workspace windows, status line, and focus/switch actions.
- [x] Hyprland and Niri implementations can degrade to readable fallback state without QML errors.
- [x] HUD modules consume the shared compositor contract rather than directly importing compositor-specific APIs.
- [x] `qmllint`, compositor fallback smoke checks, and relevant command availability checks pass before any Niri implementation commit.

Decision (ADR-lite):

- Context: current workspace/window behavior is Hyprland-first. Niri support would otherwise risk scattering compositor conditionals across HUD modules.
- Decision: plan Niri behind a shared service boundary and defer implementation until the contract is explicit.
- Consequences: reduces future cross-compositor churn. The trade-off is one extra abstraction layer when Niri work starts.

### Next Optimization MVP: Compositor Service Facade

Plan source: first Niri support prerequisite from the multi-compositor workspace contract.

Requirements:

- Add `CompositorService.qml` as the shared QML-facing compositor contract.
- For this phase, proxy existing `HyprlandService` behavior through the facade without changing runtime behavior.
- Migrate HUD modules from direct `HyprlandService` consumption to `CompositorService`.
- Keep `HyprlandService.qml` as the Hyprland-specific implementation detail.
- Do not implement Niri parsing yet; this phase only creates the safe boundary.

Acceptance Criteria:

- [x] `CompositorService.qml` exposes `available`, `compositorName`, `statusLine`, `activeWorkspace`, `activeWindowClass`, `activeWindowTitle`, `currentWorkspaceWindows`, `isOccupied()`, `switchWorkspace()`, and `focusWindow()`.
- [x] HUD modules no longer reference `HyprlandService` directly for workspace/window state.
- [x] Existing Hyprland workspace switching and focus behavior are preserved through the facade.
- [x] Missing/fallback compositor state remains readable and no-op safe.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: Niri support should not introduce compositor conditionals into UI modules.
- Decision: introduce a facade first, backed by Hyprland, then implement Niri behind it in a later phase.
- Consequences: creates a stable migration point with low behavior risk. The trade-off is one extra service indirection before Niri functionality exists.

### Next Optimization MVP: Orbital Planet Map Optimization

User instruction captured 2026-05-05: add planetary map optimization to the development plan.

Requirements:

- Improve `OrbitalExpansionPanel.qml` visual quality and performance without changing the existing click-to-open route.
- Preserve approximate time-based ephemeris calculations and visible orbital metadata.
- Optimize rendering so Canvas/animation repaint work remains bounded and does not visibly increase shell CPU usage.
- Improve visual depth with clearer orbit hierarchy, planet trails, labels, reticles, and warning-yellow tactical overlays.
- Keep the panel offline/deterministic unless a future precision astronomy task explicitly introduces external ephemeris data.

Acceptance Criteria:

- [x] Planet positions still derive from current time and local orbital-period data.
- [x] Rendering avoids unnecessary full-canvas repaint loops when visual state is unchanged.
- [x] Labels remain readable at common 1080p and 1440p central safe-area sizes.
- [x] The orbital panel keeps the shared close behavior, safe-area sizing, and expansion motion.
- [x] `qmllint`, `git diff --check`, `quickshell -p .`, and a short manual open/close orbital smoke check pass before commit.

Decision (ADR-lite):

- Context: the orbital panel is now graphical and time-derived, but future polish should improve visual hierarchy and performance together.
- Decision: treat orbital optimization as a focused rendering contract, not a rewrite of `ExpansionService` or compositor layout.
- Consequences: keeps the highest-impact visual surface improving while protecting existing central expansion behavior.

### Next Optimization MVP: Niri Compositor Service

Plan source: planned Niri support and the completed `CompositorService` facade prerequisite.

Requirements:

- Add Niri as a second compositor backend behind `CompositorService.qml` without regressing Hyprland behavior.
- Keep Niri command/API probing and parsing inside `services/NiriService.qml`; HUD modules must keep consuming only `CompositorService`.
- Use local offline Niri IPC commands: `niri msg --json workspaces`, `niri msg --json windows`, `niri msg action focus-workspace <id>`, and `niri msg action focus-window --id <window-id>`.
- Prefer Hyprland when the Quickshell Hyprland service is available; use Niri only when Hyprland is unavailable and Niri state is valid.
- Missing Niri binary, unavailable IPC, parse failures, or unavailable compositor state must degrade to readable fallback values and no-op-safe actions.
- Add user-facing Niri notes documenting command assumptions and fallback behavior.

Acceptance Criteria:

- [x] `NiriService.qml` exposes workspace/window state shaped for the shared compositor facade.
- [x] `CompositorService.qml` selects Hyprland, then Niri, then fallback without HUD-module conditionals.
- [x] `CompositorService.qml` exposes shared workspace rows consumed by the top workspace strip.
- [x] Workspace switch and window focus actions dispatch through the active compositor backend and are no-op safe when unavailable.
- [x] Missing Niri/Hyprland state remains readable without QML errors.
- [x] `docs/niri.md` documents command/API assumptions and expected fallback behavior.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: the previous compositor-facade phase removed direct Hyprland consumption from HUD modules, leaving Niri as the next backend to implement safely.
- Decision: add a small QML `NiriService` that polls Niri JSON IPC commands and adapts rows/actions into the existing `CompositorService` contract, while preserving Hyprland as the preferred backend.
- Consequences: Niri can power the HUD without UI rewrites. The trade-off is command-output-shape risk across Niri versions; fallback parsing keeps the shell readable, and deeper Niri-specific behavior can be refined from real runtime output.

### Follow-up Refactor: Workspace Row Facade

Refactor source: post-Niri documentation/code sync review on 2026-05-06.

Requirements:

- Expose workspace rows from `CompositorService.qml` instead of making HUD modules reconstruct workspace buttons from hard-coded ids.
- Keep Hyprland behavior visually equivalent by shaping five default Hyprland workspace rows.
- Preserve Niri's dynamic workspace labels/ids when Niri is the active backend.
- Provide fallback workspace rows so the top bar remains readable without a supported compositor.

Acceptance Criteria:

- [x] `HyprlandService.qml` exposes `workspaces` rows with `{ id, label, active, occupied }`.
- [x] `CompositorService.qml` exposes backend-selected `workspaces` rows and fallback rows.
- [x] `TopStatusBar.qml` consumes `CompositorService.workspaces` instead of a hard-coded numeric model.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: Niri support added a backend facade, but the top workspace strip still recreated workspace state from a hard-coded five-item model and direct occupancy checks.
- Decision: make workspace rows a first-class facade field so UI modules consume already-shaped compositor state.
- Consequences: improves the multi-compositor boundary and lets Niri surface dynamic workspace ids/labels. The trade-off is a small amount of row-shaping duplication in compositor services until more compositor backends justify a shared helper.

### Next Optimization MVP: Compositor Diagnostics Visibility

Plan source: continue the multi-compositor support plan after adding Niri and workspace-row facade support.

Requirements:

- Surface active compositor backend details in the command-center diagnostics view so Niri/Hyprland fallback behavior is visible without reading logs.
- Keep backend-specific imports out of HUD modules; expose already-shaped diagnostic rows from `CompositorService.qml`.
- Show active backend, Hyprland backend status, Niri backend status, workspace row/window counts, and active window identity.
- Preserve existing diagnostics layout, service matrix, log clear behavior, and command-center safe-area scrolling.

Acceptance Criteria:

- [x] `CompositorService.qml` exposes backend/workspace diagnostic status lines and `diagnosticRows`.
- [x] `CommandCenterDiagnosticsColumn.qml` renders a compositor matrix from `CompositorService.diagnosticRows`.
- [x] HUD diagnostics do not import `HyprlandService` or `NiriService` directly.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: Niri support is now implemented behind a facade, but users still need a visible way to confirm which backend is active and whether the inactive backend is falling back.
- Decision: add shaped compositor diagnostic rows to `CompositorService` and render them inside the existing diagnostics column.
- Consequences: improves operability with minimal UI change. The trade-off is a little more facade surface area, but it keeps backend-specific services out of HUD modules.

### Next Optimization MVP: Compositor Transition Logging

Plan source: continue compositor operability after exposing backend diagnostics in the command center.

Requirements:

- Emit structured service-log events when the active compositor backend, backend status line, or workspace/window count summary changes.
- Keep logging centralized in `CompositorService.qml`; do not add backend-specific log wiring to HUD modules.
- Use warning severity when compositor status enters fallback, and info severity for normal online/transition updates.
- Avoid repeatedly logging unchanged status on every binding reevaluation or poll tick.

Acceptance Criteria:

- [x] `CompositorService.qml` records backend/status/workspace summary transitions through `ServiceLogService.push()`.
- [x] Repeated identical compositor states are deduplicated by last-logged state.
- [x] Fallback compositor status is logged as `warn`; normal transitions are logged as `info`.
- [x] Existing diagnostics event stream displays these compositor events without UI changes.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: the command center now shows current compositor backend state, but transient backend/fallback changes are not preserved after the current state moves on.
- Decision: log compositor transitions from the facade using a small last-state cache.
- Consequences: improves diagnostics history while keeping backend services and HUD modules simple. The trade-off is that log granularity is limited to facade-level summaries, not raw backend command stderr.

### Next Optimization MVP: Compositor Overview Surfacing

Plan source: continue compositor support visibility outside the diagnostics-only surface.

Requirements:

- Show the active compositor backend and workspace/window summary in the command-center overview, not only the diagnostics column.
- Keep the overview consuming `CompositorService` only.
- Update user-facing Hyprland/Niri docs so they describe `CompositorService` as the HUD-facing compositor contract.
- Preserve overview layout and existing network/window controls.

Acceptance Criteria:

- [x] `CommandCenterOverviewColumn.qml` shows active compositor backend and `CompositorService.workspaceStatusLine`.
- [x] Overview still reads active window and workspace/window state from `CompositorService`.
- [x] `docs/hyprland.md` describes Hyprland as a backend behind `CompositorService`.
- [x] `docs/niri.md` lists the expanded facade fields and explains where to inspect backend status.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: compositor diagnostics are visible in the diagnostics column, but the command-center overview still starts at workspace/window data and hides which compositor is active.
- Decision: add a compact compositor/status line to the existing overview and align user-facing docs with the facade-based architecture.
- Consequences: improves discoverability with minimal UI impact. The trade-off is one additional overview line in an already dense column.

### Next Optimization MVP: Stable Window Focus Keys

Plan source: continue strengthening the multi-compositor facade after Niri support and overview surfacing.

Requirements:

- Add a stable `windowKey` field to compositor window rows so HUD modules do not focus windows by display title.
- Use compositor-native identifiers where available: Hyprland window address and Niri window id.
- Keep title fallback for legacy or malformed rows.
- Update dock and command-center overview focus actions to pass `windowKey`.
- Document the row contract in frontend state-management and compositor docs.

Acceptance Criteria:

- [x] `HyprlandService.qml` includes `windowKey` in `currentWorkspaceWindows` rows and focuses by address when possible.
- [x] `NiriService.qml` includes `windowKey` in `currentWorkspaceWindows` rows and focuses by id.
- [x] `MissionDock.qml` and `CommandCenterOverviewColumn.qml` pass `windowKey` to `CompositorService.focusWindow()`.
- [x] Duplicate-title windows no longer rely on title matching when compositor-native keys are available.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: after adding Niri, the facade still exposed window rows where focus actions commonly passed display titles. Titles are not stable identifiers and can collide.
- Decision: add `windowKey` to the shared row shape and make HUD focus calls use it while keeping title fallback for compatibility.
- Consequences: improves focus correctness across compositors with minimal UI change. The trade-off is a slightly larger row contract.

### Next Optimization MVP: Compositor Action Feedback

Plan source: continue reliability work after stable window focus keys by making compositor action no-ops visible.

Requirements:

- Add a compositor action status line for workspace switch and window focus attempts.
- Log compositor user actions through `ServiceLogService`, including no-op/fallback paths.
- Keep feedback centralized in `CompositorService.qml`; HUD modules should not log compositor actions directly.
- Include the action status in diagnostics through the existing compositor matrix.

Acceptance Criteria:

- [x] `CompositorService.qml` exposes `actionStatusLine`.
- [x] Workspace switch and window focus attempts update action status and service-log events.
- [x] Unsupported compositor state and missing window keys produce warning status/log entries instead of silent no-ops.
- [x] `CompositorService.diagnosticRows` includes the current action status.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: compositor action routes are no-op safe, but unsupported backends or malformed window keys can fail silently from the user's perspective.
- Decision: add facade-level action feedback and structured logging while keeping backend services focused on command dispatch/parsing.
- Consequences: improves diagnostics and user confidence with small state surface growth. The trade-off is that successful Hyprland dispatch cannot currently confirm compositor-side completion beyond dispatch intent.

### Next Optimization MVP: Workspace Label Fit

Plan source: continue Niri UI robustness after exposing compositor-provided workspace rows.

Requirements:

- Make top workspace buttons handle compositor-provided labels that are longer than single-digit Hyprland ids.
- Keep numeric Hyprland workspace buttons visually equivalent.
- Clamp button width so long labels do not consume the top bar.
- Elide labels inside the button instead of clipping text.

Acceptance Criteria:

- [x] `TopStatusBar.qml` derives workspace button width from label width within a small clamp.
- [x] Workspace labels elide inside the button.
- [x] Numeric Hyprland labels still render as compact square buttons.
- [x] `docs/niri.md` and frontend state specs document that compositor workspace labels may be longer than numeric ids.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: the compositor facade now passes workspace labels through from Niri, but the top workspace strip still used fixed 34px buttons designed for numeric labels.
- Decision: make buttons label-aware with a bounded width and text elision.
- Consequences: Niri workspace names become usable without destabilizing top-bar layout. The trade-off is that very long labels are abbreviated in the strip and full names remain a future tooltip/details concern.

### Next Optimization MVP: Niri Occupancy Refresh

Plan source: continue Niri compositor robustness after workspace label fit and executable contract update.

Requirements:

- Keep Niri workspace `occupied` flags in sync with the latest window list, not only the previous poll's `knownWindows` state.
- Preserve raw workspace payloads so workspace rows can be reshaped after `niri msg --json windows` updates.
- Do not change the shared `CompositorService.workspaces` row shape.
- Preserve missing-command/parse fallback behavior.

Acceptance Criteria:

- [x] `NiriService.qml` stores raw workspace payloads separately from shaped `workspaces` rows.
- [x] `NiriService.qml` shapes workspace rows through a single helper.
- [x] Window refresh recomputes workspace occupancy from the latest known windows.
- [x] Niri fallback clears raw workspace state as well as shaped rows/window rows.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: Niri workspace occupancy could lag because workspace rows were shaped before the fresh window list arrived.
- Decision: store raw workspace payloads and recompute shaped workspace rows immediately after the window payload updates.
- Consequences: makes occupancy indicators more accurate in the same poll cycle. The trade-off is one extra raw-state property inside `NiriService`.

### Waiting For Test: Niri Runtime Validation

Plan source: only remaining explicit Niri plan item after implementing the shared compositor facade and Niri backend. This is not active development while the local machine is not running Niri.

Requirements:

- Track real Niri session runtime IPC validation as waiting-for-test.
- Document the exact environment blocker and provide a manual validation checklist.
- Do not mark Niri runtime behavior as manually validated unless `niri msg --json workspaces` and `niri msg --json windows` run inside a Niri session.

Acceptance Criteria:

- [x] `command -v niri` was checked.
- [x] `niri msg --json workspaces` and `niri msg --json windows` were attempted.
- [x] Environment blocker is documented: current session is Hyprland and `NIRI_SOCKET` is not set.
- [x] `docs/niri.md` includes a manual validation checklist with assertion points.
- [x] Niri runtime validation is moved out of the active development path and into waiting-for-test tracking.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: all code-level Niri support slices are complete, but actual runtime behavior still needs validation in a Niri session.
- Decision: treat Niri runtime validation as waiting-for-test in the current Hyprland session and document exact commands/assertions for the first Niri session run.
- Consequences: active development can continue without pretending Niri was manually validated. The trade-off is that real Niri behavior still needs a future manual run on the target compositor.

### Next Optimization MVP: Power Grid Expansion Panel

User direction captured 2026-05-06: continue with expanded interaction panels.

Requirements:

- Add a central drill-down opened from the right panel's `POWER SOURCE` block.
- Reuse existing `BatteryService` and `PowerProfileService`; do not add a new backend/helper.
- Preserve the existing `ExpansionService` central safe-area deployment model and shared chrome.
- Show battery/AC state, power profile, idle inhibitor state, and power profile controls.
- Keep power profile and idle actions using existing service methods.

Acceptance Criteria:

- [x] Clicking `POWER SOURCE` in `RightMonitorPanel.qml` opens a central power expansion surface.
- [x] `PowerExpansionPanel.qml` uses `CentralPanelChrome` and existing services only.
- [x] Panel displays battery telemetry, profile status, idle inhibitor state, and action hints.
- [x] Profile buttons call `PowerProfileService.setProfile()` and idle control calls `toggleIdleInhibitor()`.
- [x] Safe-area sizing, backdrop close, close button, and `Escape` close behavior are preserved through `HudLayout.qml`/`ExpansionService`.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: CPU/network/filesystem/log drill-downs already use the central expansion pattern, but `POWER SOURCE` is still a high-signal right-panel metric with no drill-down.
- Decision: add a focused `PowerExpansionPanel.qml` using existing power services and the shared central chrome/deployment path.
- Consequences: expands the interaction model without introducing new service contracts. The trade-off is that detailed battery history is not added yet; the slice focuses on current telemetry and controls.

### Next Optimization MVP: Media/Lyrics Expansion Panel

Plan source: continue the user-selected expanded interaction panel direction after the power drill-down.

Requirements:

- Add a central drill-down opened from the left panel's `TELEMETRY` block.
- Reuse existing `MediaService` and `AudioService`; do not duplicate `playerctl` command logic in the HUD module.
- Show player state, active track, audio spectrum, lyric lookup status, and local lyric lines.
- Expose existing previous/play-pause/next actions through `MediaService.control()`.
- Preserve shared central safe-area deployment, close button, backdrop close, and `Escape` close behavior.

Acceptance Criteria:

- [x] Clicking `TELEMETRY` in `LeftTacticalPanel.qml` opens a central media expansion surface.
- [x] `MediaExpansionPanel.qml` uses `CentralPanelChrome` and existing services only.
- [x] Panel displays media status, track text, audio spectrum, and lyrics fallback/file lines.
- [x] Transport controls call `MediaService.control()`.
- [x] Safe-area sizing and close behavior are preserved through `HudLayout.qml`/`ExpansionService`.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: left-panel `TELEMETRY` shows media/audio/power summary but only the orbital clock has a left-panel central drill-down.
- Decision: add a focused media/lyrics expansion surface from the telemetry block, reusing `MediaService` and `AudioService`.
- Consequences: expands left-side interaction without new backend state. The trade-off is that lyrics remain local-file fallback only; network lyrics are out of scope.

### Next Optimization MVP: Expansion Panel Status Strips

User direction captured 2026-05-06: optimize non-orbital expansion panels for content density and cyber-machine visual language before the orbital rewrite.

Requirements:

- Add a shared `PanelStatusStrip` component to unify the top status bar across all six non-orbital central expansion panels.
- Each strip must show left (source/live), center (bus/telemetry summary), and right (close hint) labels.
- Warning styling when the backing service reports fallback status.
- Preserve existing panel content and safe-area sizing.
- Do not change the orbital panel; it is deferred for the J2000 rewrite.

Acceptance Criteria:

- [x] `components/PanelStatusStrip.qml` exposes `leftText`, `centerText`, `rightText`, and `warning` properties.
- [x] CPU/Network/Filesystem/Log/Power/Media expansion panels use `PanelStatusStrip` at the top of their content.
- [x] Each strip shows a service-specific bus label and live data summary.
- [x] Warning state correctly reflects service fallback status.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: expansion panels have no shared status chrome; each panel's top area shows raw data with no common bus/status language.
- Decision: add a lightweight shared `PanelStatusStrip` that each panel instantiates with its own service labels.
- Consequences: improves visual consistency and information density with minimal per-panel code change. The trade-off is that this is a surface-level chrome addition, not a deep content redesign.

### Planned Next: J2000 3D Orbital Rewrite

User direction captured 2026-05-06: rewrite the orbital expansion panel as a 3D side-view J2000 solar system with cosmic coordinate frame, drag-to-rotate, zoom, real-time heliocentric XYZ/AU for each planet, and cyber-machine visual language.

Design constraints recorded:

- Rendering target: QML Canvas 2.5D pseudo-3D projection.
- Ephemeris: J2000 approximate orbital elements with Kepler approximation, offline real-time calculation.
- Display: heliocentric ecliptic XYZ in AU per planet, orbital tracks, coordinate ticks, reticle/grid, glow/trail effects.
- Interaction: drag to rotate view, scroll/gesture zoom, reset view control.
- Priority: orbital rewrite starts after non-orbital panel density/cyber style passes are complete.
- Existing contracts to preserve: `ExpansionService`, `CentralPanelChrome`, safe-area sizing, close/backdrop/Escape behavior, `Time.now` time source, offline/deterministic calculation, and the `AnalogOrbitClock` entry point.

### Next Optimization MVP: J2000 3D Orbital Rewrite

Implemented 2026-05-07 after non-orbital expansion panel status strips.

Requirements:

- Rewrite `OrbitalExpansionPanel.qml` as a 2.5D pseudo-3D J2000 solar-system projection using QML Canvas and existing QML primitives.
- Replace circular longitude-only phase with offline approximate Kepler orbital elements seeded from J2000 values.
- Display heliocentric ecliptic XYZ/AU, current distance, longitude/anomaly metadata, orbit tracks, coordinate grid, reticles, labels, and trail effects.
- Add drag-to-rotate, wheel/trackpad zoom, and a reset-view control without introducing a new backend/helper.
- Preserve `ExpansionService`, `HudLayout` safe-area sizing, close/backdrop/Escape behavior, `Time.now`, and the `AnalogOrbitClock` entry point.

Acceptance Criteria:

- [x] Planet positions derive from J2000-style orbital elements and current time through an offline Kepler approximation.
- [x] The orbital surface renders a pseudo-3D ecliptic coordinate frame with orbit tracks, projected planet nodes, trails, labels, and tactical HUD overlays.
- [x] The panel shows heliocentric XYZ/AU and related orbital metadata for visible planets.
- [x] Drag rotation, wheel/trackpad zoom, and reset view controls are available locally in the panel.
- [x] Existing central deployment, close button, backdrop close, and `Escape` close behavior remain owned by `HudLayout.qml`/`ExpansionService.qml`.
- [x] `qmllint`, `zig build`, `git diff --check`, and a short `quickshell -p .` smoke check pass before commit.
- [x] The completed phase is committed and pushed, or any push blocker is reported explicitly.

Decision (ADR-lite):

- Context: the orbital expansion panel was already graphical and time-derived, but it was still a top-down circular/elliptical view with limited astronomical shape and no 3D viewpoint control.
- Decision: keep the implementation local to `OrbitalExpansionPanel.qml` and use approximate J2000 orbital elements plus a small Kepler solver to produce heliocentric ecliptic XYZ positions, projected through a bounded pseudo-3D camera.
- Consequences: the highest-priority orbital surface now carries stronger sci-fi depth and more meaningful metadata without adding services or network ephemerides. The trade-off is that the result remains approximate visual astronomy, not precision ephemeris output.

### Planned Future Work: Orbital Map Rendering Optimization

User direction captured 2026-05-07: keep optimizing the planetary/orbital map after the initial J2000 rewrite.

Requirements:

- Improve drag/zoom smoothness beyond the current Canvas throttling and reduced drag-time sampling.
- Investigate replacing or supplementing QML Canvas orbit drawing with more GPU-friendly Qt Quick primitives, cached layers, or a dedicated renderer path.
- Preserve the current J2000/Kepler offline ephemeris, heliocentric XYZ/AU metadata, drag/zoom/reset interaction, and central expansion routing.
- Keep coordinate readability high when zoomed in or out, including clear axis labeling and unclipped planet readouts.
- Avoid adding network ephemeris data or external astronomy dependencies unless a later precision task explicitly requires them.

Acceptance Criteria:

- [ ] Dragging the orbital map remains responsive on common shell hardware without obvious frame stalls.
- [ ] Orbit tracks and coordinate overlays retain visual quality after any rendering backend change.
- [ ] Planet labels and metadata stay readable at minimum/default/maximum zoom.
- [ ] Rendering changes do not regress close/backdrop/`Escape` behavior or safe-area deployment.
- [ ] `qmllint`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision (ADR-lite):

- Context: the first performance pass reduced JS/Canvas churn but the orbital surface is still Canvas-heavy and may benefit from cached or GPU-friendlier rendering.
- Decision: track deeper rendering optimization as a future slice rather than mixing it with small visual bug fixes.
- Consequences: preserves current stability while making room for a more deliberate rendering backend evaluation.

### Next Optimization MVP: Cached Orbital Track Rendering

Implemented 2026-05-07 as the first step in the orbital map rendering optimization plan.

Requirements:

- Move expensive orbit-track Kepler sampling out of every Canvas repaint.
- Cache high-quality and drag-time orbital path samples locally in `OrbitalExpansionPanel.qml`.
- Preserve live planet positions, labels, metadata, drag/zoom controls, and existing visual styling.
- Keep this slice QML-only and avoid introducing a new renderer/backend before measuring need.

Acceptance Criteria:

- [x] Canvas orbit-track redraw projects cached 3D path points instead of recomputing Kepler samples per paint.
- [x] Drag mode still uses a lighter path while idle mode uses a higher-quality path.
- [x] Current planet positions and metadata remain time-derived from current `Time.now`.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision (ADR-lite):

- Context: the first drag performance pass reduced update frequency, but Canvas redraw still solved Kepler repeatedly for every orbit sample.
- Decision: cache static orbit paths because orbital shape is stable for this approximate visual model; live planet nodes still compute current time-derived positions separately.
- Consequences: drag and zoom spend less time in JS orbital math while preserving the visual model. The trade-off is that any future time-varying orbital elements would need cache invalidation.

### Next Optimization MVP: Canvas Planet Node Rendering

Implemented 2026-05-07 as the next orbital rendering optimization slice.

Requirements:

- Move planet node circles, trail dots, and reticle crosses from QML `Rectangle` delegates into the existing orbital Canvas.
- Keep QML `TacticalLabel` readouts for planet coordinate labels so text remains crisp and elidable.
- Preserve cached orbit-track paths, current-time planet position calculation, drag/zoom controls, and visual styling.
- Reduce live QML item/binding count during drag and zoom interactions.

Acceptance Criteria:

- [x] Canvas draws planet nodes, glow rings, trails, and reticle crosses for all visible planets.
- [x] QML delegates no longer create per-planet node/trail/cross `Rectangle` items.
- [x] Planet coordinate labels remain visible and positioned from projected planet coordinates.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision (ADR-lite):

- Context: cached orbit paths removed repeated Kepler solving from Canvas repaint, but QML still maintained many per-planet visual primitives whose bindings updated during every view change.
- Decision: draw non-text planet marks directly in Canvas and leave only text labels in QML.
- Consequences: reduces QML scene graph item churn and binding work while preserving label readability. The trade-off is that planet node styling now lives in the Canvas drawing routine.

### Next Optimization MVP: Orbital Corner Chrome Fix

User issue captured 2026-05-07: the planetary panel has four incorrect right-angle corner effects.

Requirements:

- Fix the four orbital panel corner chrome effects so each corner draws the correct inward-facing L shape.
- Remove duplicated or mirrored corner primitives that create visually incorrect right-angle artifacts.
- Keep the existing orbital panel content, drag/zoom behavior, close button, and central deployment unchanged.

Acceptance Criteria:

- [x] The orbital panel shows exactly four correctly oriented corner brackets.
- [x] No duplicate top-left/bottom-right heavy corner artifacts remain.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

### Code Review Backlog: Correctness Fixes

Review source captured 2026-05-07: code review comments for Void Shell. These are added to the development plan only; do not implement as part of this capture step.

Implemented 2026-05-07 as the first code-review maintenance slice.

Priority: address correctness/security issues before further visual optimization unless the user explicitly selects another slice.

Requirements:

- Fix `Theme.qml` `dimAccent` fallback so the fallback is a six-digit hex color and alpha is applied through theme alpha helpers.
- Make session logout compositor-aware. `SessionService.commandForAction("logout")` should not hardcode Hyprland when the active compositor is Niri or fallback.
- Make the settings helper path robust when Quickshell is launched outside the repository root. Avoid relying only on `./zig-out/bin/void-shell-settings`.
- Adjust `SystemStats` network bar scaling so typical 100-500 KiB/s desktop traffic remains visible.
- Make `NiriService` polling respect the user update interval setting or otherwise document/centralize its polling contract.
- Remove shell-injection risk from `WeatherService` wttr location handling by avoiding `sh -c` string concatenation with `WTTR_LOCATION`.
- Rename `NotificationService.serverEnabled` or expose a clearer alias because the current boolean means the shell should own notifications when no other daemon is found.
- Split `AudioService` action/read-back processes or otherwise prevent action/read poll command races and stale refresh behavior.
- Debounce `WallpaperService.select()` so rapid wallpaper clicks do not spawn overlapping ImageMagick sample processes.
- Clarify or remove the empty `HudExclusionZone` mask when invisible/zero-thickness so input semantics are not misleading.

Acceptance Criteria:

- [x] Security-sensitive process invocations avoid shell string interpolation for user/env-derived values.
- [x] Compositor/session actions degrade correctly on Hyprland, Niri, and fallback states.
- [x] Settings helper discovery works outside the repository working directory or fails with clear diagnostics.
- [x] Network throughput bars remain visible for low/normal desktop traffic.
- [x] Polling services honor shared update timing contracts or document exceptions.
- [x] Audio and wallpaper actions avoid overlapping-process races under rapid user interaction.
- [x] Naming/docs make notification ownership semantics obvious.
- [x] `qmllint`, `zig build`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision (ADR-lite):

- Context: the review identified small correctness, security, and race-condition risks across services and theme defaults.
- Decision: group these into a dedicated correctness-fix slice so they can be handled before lower-risk refactors.
- Consequences: reduces user-visible failures and security risk with focused changes. The trade-off is delaying broader architecture cleanup until correctness is stable.

### Code Review Backlog: Performance And Duplication Refactors

Review source captured 2026-05-07: performance and duplication comments for Void Shell. These are planned follow-up slices, not immediate implementation.

Implementation slices completed 2026-05-07: extracted shared expansion-panel deployment slot, cached calendar month rows/cells, reduced repeated settings clamp/save handlers, reduced orbital projection allocations, and staggered polling startup.

Requirements:

- Extract repeated `HudLayout.qml` expansion-panel deployment animation and input-region boilerplate into a reusable primitive such as `ExpansionPanelBase` or equivalent shared helper.
- Reduce repetitive `SettingsService` clamp/save handlers through a shared normalization/save routing pattern.
- Continue orbital rendering optimization by avoiding unnecessary full Canvas redraws and reducing hot-path JS object allocation in projection/orbital math.
- Consider narrower `/proc/stat` parsing if system-stat parsing becomes measurable overhead.
- Cache derived theme colors or otherwise avoid repeated expensive color derivation if profiling shows theme bindings are hot.
- Stagger service polling startup/timers so SystemStats, Audio, Niri, Clipboard, Battery, and Network do not all fire simultaneously.
- Cache calendar month-row computation so `buildMonthRows()` is not repeated unnecessarily every minute.

Acceptance Criteria:

- [x] Expansion panel deployment boilerplate is reduced without changing safe-area deployment, close, backdrop, or `Escape` behavior.
- [x] Settings persistence remains validated/clamped while reducing repeated handler code.
- [x] Orbital drag/zoom remains smooth and preserves J2000/Kepler metadata and readability.
- [x] Service polling avoids avoidable synchronized CPU spikes.
- [x] Calendar/theme/stat optimizations preserve existing visible behavior.
- [x] `qmllint`, `zig build` when settings helper changes, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision (ADR-lite):

- Context: the shell has accumulated repeated animation, settings, and polling patterns as features were added in vertical slices.
- Decision: track performance/duplication work separately from correctness fixes so refactors can be verified without mixing behavior changes.
- Consequences: improves maintainability and responsiveness. The trade-off is that some duplicated code remains until this slice is selected.

### Code Review Backlog: Extensibility And Test Infrastructure

Review source captured 2026-05-07: extensibility comments for Void Shell. These are medium/long-term planning items unless user prioritizes them.

Implementation slices completed 2026-05-07: added Zig settings-helper validation tests, `zig build test` support, and settings version normalization/future-version rejection.

Requirements:

- Revisit `CompositorService` after Niri validation; consider backend registration/delegation instead of repeated Hyprland/Niri ternaries before adding a third compositor.
- Consolidate settings schema duplication across QML defaults, Zig `Settings`/validation, and default JSON, potentially through a single schema source.
- Add an expansion panel base component before creating more central panels.
- Introduce layout configuration or theme-derived positioning before making panel positions user-configurable.
- Defer a plugin/extension system until third-party widgets or dynamic external consumers are explicit requirements.
- Plan multi-monitor support around screen-aware `HudWindow`/layout instances before implementation.
- Add test infrastructure, starting with Zig settings-helper validation tests and QML parser/service fixtures for malformed command output.
- Add keyboard navigation for command center, expansion panels, and critical controls beyond `Ctrl+Alt+S`/`Escape`.
- Add settings version-check and migration logic before relying on future incompatible settings changes.
- Revisit static service discovery/lazy loading only if memory/startup overhead becomes visible or optional service count keeps growing.

Acceptance Criteria:

- [x] Extensibility work is split into separate implementation tasks before coding, not mixed into bug-fix slices.
- [x] Any settings schema/migration change includes Zig validation tests.
- [x] Settings version checks/migration behavior are covered for missing, old, current, and future versions.
- [ ] Any compositor-backend extensibility change preserves Hyprland behavior and Niri fallback behavior.
- [ ] Multi-monitor/plugin/lazy-loading work has explicit product requirements before implementation.

Decision (ADR-lite):

- Context: review found several architectural seams that are acceptable for the current first-party shell but will become expensive as compositors, panels, settings, and optional services grow.
- Decision: record them as planned extensibility/test-infrastructure work, with tests and settings migrations as the most concrete early candidates.
- Consequences: keeps the current shell pragmatic while preventing these concerns from being lost. The trade-off is that plugin, multi-monitor, and registry work remain intentionally deferred.

### Orbital Detail Telemetry Polish

Implemented 2026-05-07 as a focused orbital panel detail/readability slice after the rendering optimization work.

Requirements:

- Improve the J2000 orbital panel's tactical readout density without changing central expansion routing.
- Add a selected-planet detail pane with orbital elements, live heliocentric/geocentric state, phase, apparent magnitude estimate, and zodiac sector.
- Add local planet selection controls and right-click planet selection.
- Preserve drag rotation, zoom, reset behavior, safe-area deployment, close behavior, and offline Kepler approximation.

Acceptance Criteria:

- [x] Orbital panel exposes richer per-planet metadata while preserving the existing J2000/Kepler offline model.
- [x] Selected planet can be changed locally without adding backend state.
- [x] Runtime smoke shows no Repeater `index` reference warnings.
- [x] `qmllint`, `zig build test`, `zig build`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision (ADR-lite):

- Context: the orbital panel had the computational model and performance optimizations, but the detail surface could expose more useful orbital metadata and target-selection affordances.
- Decision: keep the work local to `OrbitalExpansionPanel.qml`, expanding the visual/readout layer without changing services or deployment contracts.
- Consequences: improves the highest-value central panel's usefulness and cyber-machine feel. The trade-off is more QML logic in the orbital surface; extract only if another astronomy surface reuses it.

### Keyboard Navigation Foundation

Implemented 2026-05-07 as the first keyboard accessibility slice.

Requirements:

- Add keyboard activation to shared close/toggle controls and high-value command-center/orbital actions.
- Use `Tab` focus plus `Enter`/`Return`/`Space` activation where QML controls are custom rectangles.
- Preserve existing mouse behavior, visual styling, command routing, and `Escape` close behavior.
- Keep the slice focused; do not redesign every panel into a full focus-chain system yet.

Acceptance Criteria:

- [x] `PanelCloseButton` can be focused and activated from the keyboard.
- [x] `ToggleRow` can be focused and toggled from the keyboard.
- [x] Command-center action controls for power/session, keybind copy, emoji, clipboard, and launcher results expose keyboard activation.
- [x] Orbital reset/top/edge and previous/next target controls expose keyboard activation.
- [x] `qmllint`, `zig build test`, `zig build`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision (ADR-lite):

- Context: the shell was mostly mouse-driven, with only global shortcuts and the keybind recorder handling keyboard input.
- Decision: add keyboard support first to shared primitives and high-value controls instead of building a large focus-management abstraction.
- Consequences: improves accessibility and everyday usability while keeping implementation risk low. The trade-off is that some lower-priority custom controls still need future focus-chain work.

### Next Optimization MVP: Fixed HUD Tooltip Box

User direction captured 2026-05-07: add mouse-hover tooltips, but show them like FL Studio in a fixed framed box instead of positioning the tooltip near the mouse cursor.

Implemented 2026-05-07 as the first tooltip infrastructure slice.

Requirements:

- Add a reusable tooltip state/service for hover help text from HUD controls.
- Render tooltip content in a fixed tactical frame/box in the HUD, not next to the pointer.
- Use FL Studio-like behavior conceptually: hovering controls updates a shared information box with label/detail text.
- Preserve existing mouse click/hover behavior and keyboard activation behavior.
- Start with key interactive controls, not every decorative label.
- Keep visual language tactical: framed, monospaced, warning-yellow accents, readable at a glance.

Acceptance Criteria:

- [x] Hovering supported controls updates one fixed tooltip box.
- [x] Tooltip box position is layout-owned and stable; it does not follow mouse coordinates.
- [x] Tooltip hides or returns to standby when leaving supported controls.
- [x] Shared tooltip API is reusable from modules/components without duplicating popup rectangles.
- [x] `qmllint`, `zig build test`, `zig build`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision (ADR-lite):

- Context: the HUD has many dense custom controls, and conventional cursor-following tooltips would fight the tactical layout and edge panels.
- Decision: use a single fixed tooltip/readout surface updated by hover events, similar in spirit to FL Studio's fixed hint panel.
- Consequences: improves discoverability without visual jitter or pointer occlusion. The trade-off is that controls need explicit tooltip wiring over time.

### Next Optimization MVP: Expanded Tooltip Coverage

Implemented 2026-05-07 as the follow-up tooltip infrastructure coverage slice.

Requirements:

- Extend the fixed HUD tooltip/readout box to more high-value interactive controls.
- Reuse `TooltipService.qml`; do not add another tooltip state model or cursor-following popup.
- Cover command-center network actions, active window focus rows, tray drawer entries, session/power controls, keybind recorder/copy, emoji copy, clipboard controls/items, and launcher results.
- Preserve existing mouse click behavior, keyboard activation behavior, command routing, and panel layout.

Acceptance Criteria:

- [x] Mission dock and command-center window rows expose focus-action hover help.
- [x] Command-center network, notification, power/session, keybind, emoji, clipboard, launcher, and tray drawer controls update the fixed tooltip box on hover.
- [x] Tooltip integration reuses `TooltipService.show()`/`clear()` without creating duplicate popup rectangles or services.
- [x] Existing click/keyboard command behavior remains unchanged.
- [x] `qmllint`, `zig build test`, `zig build`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision (ADR-lite):

- Context: the fixed tooltip box existed and covered the most visible HUD/edge controls, but many command-center and tray interactions still required prior knowledge.
- Decision: add explicit hover wiring to the next tier of high-value controls while leaving decorative/read-only rows untouched.
- Consequences: improves discoverability using the established fixed hint pattern. The trade-off is incremental per-control wiring until a reusable interactive-button primitive is justified.

### Planning Update: Fixed Tooltip Box Placement

User feedback captured 2026-05-07: the fixed hover tooltip box should be moved out of the central empty/safe area because it can interfere with normal window usage and central expansion panels. The exact destination needs discussion before implementation.

Requirements:

- Keep the FL Studio-like fixed hover readout behavior; do not switch to cursor-following tooltips.
- Move `HudTooltipBox` out of the central safe-area slot used by normal windows and central expansion surfaces.
- Preserve hover wiring through `TooltipService.show()`/`clear()` and avoid per-control popup rectangles.
- Choose a placement that remains visible without blocking high-value HUD controls, expansion panels, or common application windows.
- Keep input-region semantics honest: the tooltip should not create a large invisible click shield over normal workspace content.

Placement options to discuss:

- Bottom status strip, above or integrated with the bottom bar: closest to FL Studio's hint-line pattern, low central interference, but may compete with bottom HUD content.
- Top-right compact readout near the command/settings entry: discoverable and away from center, but may crowd tray/audio/media controls.
- Left panel footer under telemetry/orbital clock: thematically HUD-like and out of center, but can increase left panel height pressure.
- Right panel footer under monitor blocks: useful near drill-down controls, but can worsen right-panel text density.
- Hidden-until-hover edge drawer: least intrusive while idle, but adds more motion/complexity and is less fixed/readout-like.

Acceptance Criteria:

- [x] Tooltip box no longer occupies the central empty/safe area.
- [x] Central expansion panels and normal application windows are not covered by the tooltip surface during idle or hover states.
- [x] Hovering supported controls still updates one fixed tactical readout.
- [x] Tooltip location remains stable and does not follow cursor coordinates.
- [x] Input regions match the visible tooltip bounds only.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision status:

- Decision: bottom status strip/hint-line placement, because it best matches the requested FL Studio behavior while freeing the central safe area.

### Planned Next: Orbital Panel Scientific And Cyberpunk Redesign

User feedback captured 2026-05-07: update the development plan to optimize the planetary/orbital panel using the provided redesign summary. The current J2000 surface should be strengthened scientifically and visually rather than replaced with a network-backed astronomy dependency.

Implemented 2026-05-07 as a focused local `OrbitalExpansionPanel.qml` pass.

Requirements:

- Improve scientific grounding of `OrbitalExpansionPanel.qml` while staying offline and deterministic.
- Replace inaccurate or ambiguous orbital element handling with a clearer J2000/Meeus-style orbital element contract suitable for visual ephemerides.
- Remove hardcoded orbital-period mean motion where orbital elements can derive mean anomaly progression more explicitly.
- Improve Kepler solving robustness beyond fixed five-iteration `E0 = M` behavior where needed.
- Correct Earth element semantics so the model does not mix geocentric solar values with heliocentric planet rows.
- Add or document the gravitational/solar constant assumptions used by the visual model when deriving motion/state.
- Display Julian Date/current ephemeris timestamp in the panel.
- Keep current interaction contracts: central expansion routing, safe-area sizing, close/backdrop/`Escape`, drag rotate, wheel zoom, reset/top/edge controls, and right-click planet selection.
- Keep performance optimizations: cached orbit paths, scratch projection objects, bounded Canvas repaints, and no dead helper code.

Information display scope:

- Right detail panel should show all seven orbital elements for the selected planet: `a`, `e`, `i`, `Ω`, `ϖ`, `L0`, and `M0`.
- Current state should show `r`, Earth distance, true anomaly `ν`, ecliptic longitude `λ`, and ecliptic latitude `β`.
- Phase angle should be calculated from Sun/planet/Earth XYZ vectors.
- Apparent magnitude should derive from absolute magnitude, distance, and phase approximation.
- Constellation/zodiac sector should derive from ecliptic longitude, using labels from `ARI` through `PSC`.
- Bottom ephemeris should show a compact color-coded row per planet, for example `ME r0.395 λ324.8° β-6.1°`.

Visual/cyber-machine scope:

- Assign distinct per-planet colors and use them for planet nodes and orbit paths instead of all dim-gray tracks.
- Add zodiac/constellation markers around the ecliptic ring.
- Extend motion trails to a denser fading trail history, around 29 points where performance allows.
- Add stronger outer-planet glow using radial gradient styling for Jupiter through Neptune.
- Add animated pulsing/dashed selection reticle using deterministic sine alpha.
- Improve Sun center marker with a stronger crosshair and red core dot.
- Preserve view preset controls `[RESET]`, `[TOP]`, and `[EDGE]`.
- Preserve selected-planet cycle buttons near the close/control area.

Acceptance Criteria:

- [x] Selected-planet detail readout exposes the full orbital element set and current derived state.
- [x] Phase angle, apparent magnitude, and zodiac sector are computed from local state rather than static labels.
- [x] Bottom ephemeris table is compact, color-coded, and readable at common central panel sizes.
- [x] Orbit paths, planet nodes, trails, and selection reticle use per-planet/cyberpunk visual language without regressing readability.
- [x] Cached orbit paths and scratch projection pattern remain in place; drag/zoom does not reintroduce obvious frame stalls.
- [x] Dead helper code is removed as part of the redesign cleanup.
- [x] Existing central expansion deployment, close behavior, and tooltip placement changes do not conflict.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass before checkpoint.

Decision (ADR-lite):

- Context: the J2000 orbital panel already moved beyond a flat top-down ASCII/2D surface, but user feedback calls for stronger scientific readouts, richer ephemeris information, and a more cyberpunk visual hierarchy.
- Decision: plan a focused `OrbitalExpansionPanel.qml` redesign pass that improves approximate offline ephemeris calculation, readout density, and visual coding while preserving existing central expansion contracts.
- Consequences: the orbital surface becomes more meaningful and visually distinct without adding network astronomy dependencies. The trade-off is more local mathematical/rendering complexity inside the panel; extract only if another astronomy surface reuses it.

Implementation notes:

- Planet rows now include approximate J2000 base elements plus secular rates and absolute magnitude metadata.
- `elementsFor()` derives current approximate `a`, `e`, `i`, `Ω`, `ϖ`, `L`, `M`, and mean motion from the active Julian offset.
- Orbit paths remain cached and sampled around the current epoch, while current planet nodes/readouts remain live from `Time.now`.
- Phase angle now uses planet-to-Earth and planet-to-Sun vectors, and apparent magnitude uses local distance/phase approximations.
- Detail readout includes JD, eccentric anomaly, mean motion, and widened panel space for dense scientific rows.
- Selection reticle gained a stronger pulse/arc overlay while preserving the Canvas rendering path.

Follow-up cleanup implemented 2026-05-07:

- Removed leftover helper functions superseded by `elementsFor()`.
- Added visible source/precision lines to the selected-planet detail pane, including the local GM constant and the visual-ephemeris limitation.
- Preserved all routing, rendering, and interaction behavior.

Follow-up layout/readability pass implemented 2026-05-07:

- Made orbital map bounds account for the actual widened right detail pane instead of using the old fixed right-side allowance.
- Reused explicit map bounds for map size, map center, planet label clamping, zodiac label clamping, and axis label clamping.
- Reused shared `detailWidth` and `ephemerisWidth` geometry properties for overlay panels.
- Preserved Canvas rendering, cached orbit paths, selected-planet controls, and expansion routing.
