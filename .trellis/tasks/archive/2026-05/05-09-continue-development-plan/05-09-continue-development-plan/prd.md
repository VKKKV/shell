# Continue Development Plan

## Goal

Continue the shell roadmap with the next independently verifiable slice, aligned with `docs/development-plan.md` and the current code granularity. The active local track is Earth globe fidelity/performance; OpenClaw remains deferred until a real local CLI contract can be validated.

## What I Already Know

* `docs/development-plan.md` says each task should be one independently verifiable vertical slice.
* The Agent track is complete through Hermes CLI contract mapping; OpenClaw CLI discovery is deferred until a local validation environment exists.
* The Earth roadmap has already completed preprocessing, candidate review tooling, Natural Earth 50m runtime replacement, procedural terrain prototype, and compact rendering budgets.
* `components/RotatingGlobe.qml` is a single Canvas2D component with offline coastlines, drag rotation, compact/expanded render budgets, ocean texture, land terrain hints, rim glow, grid, signal nodes, night terminator, and optional location marker.
* `docs/earth-coastline-preprocessing.md` documents the current 50m dataset and a future 10m review flow, but 10m replacement is optional and should only happen after candidate review and repaint validation.
* `modules/hud/EarthExpansionPanel.qml` already describes the Natural Earth 50m dataset and procedural surface model.

## Assumptions

* Do not implement OpenClaw behavior without a verified local CLI contract.
* Do not replace `components/EarthCoastlineData.js` with 10m data in this slice because that would mix candidate acquisition/review, data replacement, and repaint tuning.
* Keep the public `RotatingGlobe` contract stable.
* Keep runtime map data fully offline.

## Requirements

* Implement a small Earth globe fidelity/budget slice, not a broad render rewrite.
* Improve the existing procedural Earth rendering in `RotatingGlobe.qml` using internal budgeted parameters derived from `expanded` and `globeSize`.
* Preserve the existing offline Natural Earth 50m coastline data and generated-data review workflow.
* Preserve existing interactions: activate/click, horizontal drag rotation, grid, signal nodes, night terminator, and optional location marker.
* Keep compact mode bounded so the left-panel globe does not process expanded-level decorative detail every repaint.
* Update Earth surface copy/docs only if the visible model or roadmap wording changes.

## Acceptance Criteria

* [ ] The next slice changes one visible Earth rendering outcome without replacing coastline data or changing public properties/signals.
* [ ] Expanded mode gains a visible procedural fidelity improvement that fits the tactical HUD style.
* [ ] Compact mode keeps lower texture/detail budgets than expanded mode.
* [ ] Runtime still imports offline coastline data and performs no map-data network fetch.
* [ ] Earth panel copy remains accurate for dataset, detail, drag, grid, nodes, light, and fallback behavior.
* [ ] `docs/development-plan.md` is updated with the completed slice and next safe follow-up.
* [ ] Verification includes `git diff --check`, `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`, and a short `quickshell -p .` smoke run where available.

## Definition Of Done

* The selected slice is implemented and smoke-checked.
* Lint/type checks pass where available.
* Docs/roadmap notes are updated if behavior or next steps change.
* The task is reviewed with `trellis-check` before completion.

## Technical Approach

Tune and budget the already-existing procedural layer instead of adding new data. Candidate implementation: add internal `terrainDetailStride`/detail density properties or equivalent small helpers in `RotatingGlobe.qml`, add a constrained expanded-only land/ocean detail pass that reuses existing projection/noise functions, and keep compact mode intentionally sparse. Update panel/docs copy only to reflect real behavior.

## Decision (ADR-lite)

**Context**: The documented next Earth idea includes optional Natural Earth 10m evaluation and procedural terrain refinement. The code already has a reviewed 50m replacement and compact render budgets, so a 10m data swap would be too large for the next safe slice.

**Decision**: Continue with a small procedural fidelity and budget refinement slice on top of the current 50m runtime dataset. Do not fetch or commit new map data, and do not refactor the whole Canvas renderer.

**Consequences**: This keeps the work visible and verifiable while preserving the future 10m path. It may not address coastline precision beyond the already-approved 50m dataset.

## Out Of Scope

* OpenClaw CLI contract mapping.
* Natural Earth 10m runtime replacement.
* Runtime network fetching for map/coastline data.
* Full `RotatingGlobe.qml` rendering rewrite.
* Replacing the tactical HUD style with satellite imagery.
* Multi-monitor, plugin, or lazy-loading architecture work.

## Technical Notes

* Roadmap source: `docs/development-plan.md`.
* Earth preprocessing docs: `docs/earth-coastline-preprocessing.md`.
* Main render surface: `components/RotatingGlobe.qml`.
* Runtime data module: `components/EarthCoastlineData.js`.
* Earth panel copy: `modules/hud/EarthExpansionPanel.qml`.
