# HUD Layout and Agent Module Design Plan

## Goal

Improve the visual balance, information density, and interaction quality of the HUD shell, then add a left-panel neural-network style Agent module that can open a central interaction panel and later connect to a configurable agent backend.

## User-Reported Problems

- The top tray sits in an empty central area, but its visual weight is too small, making the top bar feel unbalanced.
- The bottom active-window module is cramped on the left, and long window titles overflow their text frame, creating a cheap/plastic feeling.
- The bottom hover hint module takes too much width, and the left `HINT BUS` label overlaps with internal text.
- The orbital expansion panel has overcrowded header text; the top-right `ACTIVE` and arrow controls overlap the `CLOSE` button.
- The earth expansion panel looks too plastic; coastlines are too simple and need a better visual strategy.
- Several left/right panel expansion surfaces have too little content and only occupy the center of the central panel, making them feel unbalanced.
- The CPU MATRIX rectangles are too small, making usage content hard to read.
- The top SETTINGS button is too small and sits too close to tray content in the top center, making the layout feel odd.
- The analog orbital clock module's two circular borders are too thin, making the widget look fragile and underbuilt.
- Add a new left-panel module: a nearly spherical dynamic mesh structure reacting to hover and drag, representing a neural network. It should connect to an agent such as Hermes or OpenClaw, configurable from the settings panel. Clicking it opens a central panel.
- Add an optional nixie/vacuum tube clock background setting in the settings panel. It should default off. Quickshell feasibility should be checked against docs. DivergenceMeter is cloned at `../DivergenceMeter/` and should be used as visual/code reference.

## Requirements

- Rebalance the top bar so tray and settings have clear roles, spacing, and visual hierarchy.
- Rework bottom active-window and hover-hint modules so text clips/elides correctly and labels do not overlap content.
- Redesign crowded expansion headers with explicit control zones and no overlapping actions.
- Increase information density and spatial coverage for central expansion panels that currently feel sparse.
- Improve CPU MATRIX readability with larger cells or grouped visual encoding.
- Strengthen the analog orbital clock border treatment so the left-panel clock feels structurally intentional rather than brittle.
- Define an earth panel visual upgrade approach before implementation.
- Design the new Agent neural module as an interactive QML component with hover and drag response.
- Add a central Agent expansion panel opened from the left module.
- Plan configuration surface for selecting an agent provider, without hard-coding a backend contract before requirements are confirmed.
- Add a `nixie` optional background mode using a local QML/Canvas implementation first, with true background-layer window support left as a follow-up if needed.
- Document Quickshell and DivergenceMeter reference information in `AGENTS.md`.

## Acceptance Criteria

- [x] Top bar feels balanced on desktop and does not cluster unrelated controls in the center.
- [x] Bottom active-window title never overflows its frame.
- [x] Hover hint label and message never overlap.
- [x] Orbital panel header controls never overlap at normal viewport sizes.
- [x] Earth panel has an agreed visual direction and implementation scope.
- [ ] Sparse central panels use more of the available expansion area with meaningful content or intentional composition.
- [x] CPU MATRIX content is legible at the target resolution.
- [x] Analog orbital clock rings have stronger visual weight without losing the tactical thin-line language.
- [x] Agent neural module has a clear interaction design and opens a central panel.
- [x] Agent provider selection is represented in settings or a documented staged follow-up.
- [x] `zig build`, `qmllint ...`, and `timeout 8s quickshell -p .` pass after implementation.
- [x] Optional nixie/vacuum tube clock background is available from settings and defaults off.
- [x] Quickshell background feasibility and DivergenceMeter reference path are documented.

## Stage 1 Verification

- `git diff --check`: passed
- `zig build`: passed
- `qmllint shell.qml components/*.qml modules/hud/*.qml services/*.qml theme/Theme.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded` with no startup warnings observed

## Stage 2 Scope

- Add a visual-only neural mesh Agent module to the left panel.
- Add an Agent central expansion panel opened through `ExpansionService`.
- Represent Hermes/OpenClaw/custom provider selection as placeholder UI language only.
- Do not add provider persistence, IPC, commands, or settings schema changes.

## Stage 2 Verification

- `git diff --check`: passed
- `zig build`: passed
- `qmllint shell.qml components/*.qml modules/hud/*.qml services/*.qml theme/Theme.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded` with no startup warnings observed

## Stage 3 Scope

- Improve the Earth panel through the tactical/abstract route rather than external map textures.
- Keep the globe local Canvas-based and offline.
- Add layered scan rings, signal nodes, finer grid lines, and a synthetic night terminator to reduce the plastic look.

## Stage 3 Verification

- `git diff --check`: passed
- `zig build`: passed
- `qmllint shell.qml components/*.qml modules/hud/*.qml services/*.qml theme/Theme.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded` with no startup warnings observed

## Stage 4 Scope

- Add a `nixie` background mode in settings, defaulting to `void` / off.
- Implement the first vacuum tube clock wallpaper as local QML Canvas inside the existing HUD background layer.
- Update QML and Zig settings normalization to accept `visual.backgroundMode: "nixie"`.
- Document Quickshell background-layer feasibility and `../DivergenceMeter/` reference location in `AGENTS.md`.

## Stage 4 Verification

- `git diff --check`: passed
- `zig build`: passed
- `zig build test`: passed
- `qmllint shell.qml components/*.qml modules/hud/*.qml services/*.qml theme/Theme.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded` with no startup warnings observed
- `./zig-out/bin/void-shell-settings defaults`: passed; `backgroundMode` defaults to `void`
- `./zig-out/bin/void-shell-settings write '{"visual":{"backgroundMode":"nixie"}}'`: passed; normalized output keeps `backgroundMode: "nixie"`
- `./zig-out/bin/void-shell-settings write '{"visual":{"backgroundMode":"void"}}'`: passed; restored local config to default-off background mode

## Technical Notes

- This is primarily frontend/QML work, with possible backend/helper work only if agent provider configuration needs persistence.
- Avoid adding real agent IPC before the provider contract is defined.
- Prefer staged implementation: layout fixes first, then panel polish, then Agent module shell, then backend integration.
- Confirmed stage 1 implementation starts immediately after this plan approval.
- Primary target is 4K desktop monitors; additional resolution optimization is future work.
- Agent neural module may be visual-only in the first pass.
- Agent provider configuration should be UI placeholder only in the first pass; do not persist provider config yet.

## Stage 1 Scope

- Rebalance the top bar settings/tray/media cluster without changing service contracts.
- Fix bottom active-window and hover-hint layout overflow/overlap.
- Fix orbital header control overlap.
- Improve CPU MATRIX legibility with larger central cells.
- Strengthen analog orbital clock ring/border visuals.
- Keep changes QML-only and localized.

## Future Plan

- Optimize layouts for non-4K resolutions after the 4K-first layout is stable.
- Add Earth visual upgrade after choosing the tactical/abstract vs higher-fidelity coastline direction.
- Add visual-only Agent neural module and central Agent panel.
- Define and persist agent provider config only after the backend/provider contract is clear.

## Open Questions

- None blocking stage 1.
