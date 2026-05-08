# Continue Shell Development Plan

## Goal

Choose the next independently verifiable shell development slice and keep the work aligned with the current tactical HUD roadmap. The immediate decision is whether to proceed with the documented OpenClaw CLI contract discovery or pick a visible local-only refinement that can be implemented and verified in this workspace.

## What I Already Know

* The previous continuation task completed HUD readability, Agent copy, Earth drag/coastline extraction, service log event stream, Nixie warning fix, and Network/Filesystem panel copy polish.
* `docs/development-plan.md` lists the current Agent track as complete through Hermes CLI contract mapping.
* The only named next slice in `docs/development-plan.md` is OpenClaw CLI contract discovery.
* OpenClaw work was previously deferred because this workspace did not have a local `openclaw` validation environment.
* `services/AgentService.qml` still probes `openclaw` and maps it to the placeholder command `openclaw agent`.
* `modules/hud/AgentExpansionPanel.qml` already labels OpenClaw as unvalidated and keeps the adapter safe.
* The project favors one small, independently verifiable vertical slice per task.

## Assumptions

* We should not implement unvalidated OpenClaw command behavior unless a local command contract can be verified.
* If OpenClaw is still unavailable, the next best slice should be visible, local-only, and smoke-testable with `quickshell -p .`.
* Broad redesign, plugin architecture, and multi-monitor support remain out of scope unless explicitly requested.

## Open Questions

* None blocking this slice.

## Requirements

* Implement the Nixie background settings polish slice.
* Improve command-center discoverability for the `nixie` background mode.
* Make clear that Nixie is optional/default-off and runs as a background layer mode selected by `SettingsService.backgroundMode`.
* Preserve existing `backgroundMode` values and persistence schema.
* Avoid changing `NixieBackgroundWindow` rendering, image assets, or wallpaper application behavior unless a defect is found while implementing the settings polish.
* Update `docs/development-plan.md` with the completed slice or current next step if roadmap wording changes.

## Acceptance Criteria

* [ ] The settings panel gives a clearer visual/text affordance for choosing `nixie` background mode.
* [ ] The UI distinguishes Nixie backdrop mode from wallpaper scan/apply actions.
* [ ] Nixie remains default-off through the existing `backgroundMode: "void"` default.
* [ ] Existing `void`, `grid`, `radar`, and `nixie` background values continue to normalize and persist unchanged.
* [ ] Verification includes `git diff --check`, `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`, and a short `quickshell -p .` smoke run where available.

## Definition Of Done

* Tests or smoke checks pass for the selected slice.
* Lint/type checks pass where applicable.
* Docs/notes are updated if behavior or roadmap changes.
* The task is reviewed with `trellis-check` before completion.

## Out Of Scope

* Multiple unrelated UI polish changes in one slice.
* Broad Agent UI redesign.
* Custom provider persistence or user-defined command storage.
* OpenClaw execution mapping without a verified local CLI contract.
* Nixie asset replacement or animation redesign.
* Wallpaper service behavior changes.
* Earth rendering optimization, coastline dataset replacement, terrain texture work, and preprocessing pipeline implementation.
* Multi-monitor, plugin, or lazy-loading architecture work.

## Technical Notes

* Development plan source: `docs/development-plan.md`.
* Agent provider service: `services/AgentService.qml`.
* Agent panel surface: `modules/hud/AgentExpansionPanel.qml`.
* Background mode persistence: `services/SettingsService.qml`.
* Background mode selector: `modules/hud/CommandCenterSettingsColumn.qml`.
* Nixie background layer: `modules/hud/NixieBackgroundWindow.qml`.
* Earth globe surface: existing Canvas2D globe rendering remains unchanged in this slice.
* Visual target reference: `target.md` and `target.png`.
* README describes current implemented feature surface and expected runtime fallbacks.

## Future Follow-up: Earth Globe Optimization Proposal

Plan A is a high-precision vector coastline plus procedural terrain texture upgrade for the Earth module. It should remain a future slice separate from the current Nixie settings polish work.

* Use Natural Earth 10m coastline data, targeting 10K+ coordinate points, to replace the current hand-authored/transitional coastline polylines.
* Add a one-time preprocessing pipeline that converts GeoJSON into compact QML/JS coordinate arrays for offline embedding.
* Keep rendering Canvas2D-compatible by composing explicit layers: ocean depth gradient plus seabed procedural noise, land fill plus terrain noise, high-precision coastline stroke plus atmospheric rim glow, then the existing tactical grid, signal nodes, and location markers.
* Reference Natural Earth, D3 geo projection math, and `world-map-gen` for data/projection pipeline ideas.
* Pros: fully offline, higher coastline detail, compatible with Canvas2D, and tactical styling remains controlled by the shell.
* Cons: requires preprocessing toolchain, increases embedded data size by roughly 200KB compressed, and does not provide real land textures; procedural noise only approximates terrain.
* Difficulty: medium; most work is data preprocessing and render-pipeline splitting.

## Decision (ADR-lite)

**Context**: The documented next Agent slice is OpenClaw CLI contract discovery, but OpenClaw remains unsafe to implement without a validated local CLI contract. The user selected Nixie settings polish as the next development slice.

**Decision**: Keep the task local-only and improve Nixie background mode discoverability/copy in the command-center settings surface while preserving existing settings persistence and background rendering behavior.

**Consequences**: This produces a visible, smoke-testable improvement without guessing external command behavior. OpenClaw remains deferred until a validation environment or real CLI contract is available.

## Candidate Slices

### A. OpenClaw CLI contract discovery

Proceed with the documented next Agent track slice. This is only appropriate if `openclaw` is now installed locally or you can provide the real CLI contract to validate.

### B. Agent panel response readability polish

Keep provider behavior unchanged, but improve how `AgentService.responseText` and error state are presented in the Agent expansion panel so Hermes responses and failures are easier to read in the tactical HUD.

### C. Nixie background settings polish

Keep the optional Nixie/vacuum-tube background default-off, but refine the settings/status copy and visible affordance so the user can more clearly discover and toggle the mode from the command center.

### D. HUD visual fidelity slice

Pick one target-image fidelity gap, such as sharper central terminal framing, bottom/footer immersion text, or stronger crosshair/decoration alignment, without changing service behavior.
