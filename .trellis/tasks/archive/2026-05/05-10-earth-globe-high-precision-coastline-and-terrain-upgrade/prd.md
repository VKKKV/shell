# Earth Globe High-Precision Coastline And Terrain Upgrade

## Goal

Improve the rotating Earth globe as the next development-plan slice by evaluating a higher-precision coastline path and tightening procedural terrain rendering without adding runtime network dependencies or unreviewed large map artifacts.

## What I Already Know

* `docs/development-plan.md` says this is the next slice after the Nixie background work.
* The current runtime globe uses `components/RotatingGlobe.qml` and imports `components/EarthCoastlineData.js`.
* `components/EarthCoastlineData.js` currently contains reviewed Natural Earth 50m coastline data with 1,425 polylines and 28,853 points.
* Runtime map data must stay offline; raw downloads and temporary generated artifacts should stay outside the repo.
* Existing tools support the candidate workflow: `tools/preprocess-coastlines.js`, `tools/inspect-coastlines.js`, and `tools/validate-coastline-candidate.js`.
* `docs/earth-coastline-preprocessing.md` already defines the Natural Earth 10m candidate review workflow and manifest shape.
* `RotatingGlobe.qml` already has compact vs expanded budgets for coastline point/polyline stride, ocean texture, bathymetry, coastal relief, and land fill.

## Requirements

* Evaluate a Natural Earth 10m or equivalent high-precision coastline candidate through the existing local-only candidate workflow.
* Do not replace `components/EarthCoastlineData.js` unless inspector stats and smoke checks show acceptable Canvas repaint behavior.
* Preserve the runtime coastline contract: `var coastlines = [[[lat, lon], ...]]` imported by QML.
* Keep all runtime map data offline; no runtime fetching and no checked-in raw downloads.
* Commit only reviewed compact generated JS modules if a replacement is approved.
* Preserve existing interactions: compact left-panel globe, central expanded Earth panel, horizontal drag-to-rotate, signal nodes, grid, and optional location marker.
* Left-panel globe may stay lower-fidelity because its display size is small.
* Central Earth panel must not have a noticeable open/load stall when activated.
* Keep compact rendering budgeted; expanded mode may show richer detail than compact mode.
* Refine procedural terrain only where visible artifacts or budget improvements justify it.

## Acceptance Criteria

* [ ] A local high-precision coastline candidate is generated or explicitly rejected with recorded stats.
* [ ] Candidate provenance, generation command, inspector stats, and smoke evidence are recorded in task notes or docs.
* [ ] `tools/validate-coastline-candidate.js --check-output` passes for any approved generated candidate.
* [ ] If runtime data is replaced, `components/EarthCoastlineData.js` header records source/provenance/generation stats.
* [ ] Compact globe does not attempt to repaint every high-detail point; stride/budget behavior remains explicit.
* [ ] Left-panel globe can remain lower-detail without harming readability.
* [ ] Central Earth panel opens without a noticeable stall beyond the normal panel transition.
* [ ] Expanded globe shows improved coastline/procedural detail or the PRD records why 50m remains the best runtime choice.
* [ ] `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml` passes where available.
* [ ] `git diff --check` passes.

## Technical Approach

Recommended MVP:

1. Use the existing candidate workflow under `/tmp/opencode/coastline-candidates/` to evaluate Natural Earth 10m coastline data.
2. Run `preprocess-coastlines.js` with explicit precision/simplification settings, inspect output, and validate manifest with `--check-output`.
3. Compare the candidate against current 50m stats and current `RotatingGlobe.qml` budgets, with special attention to central-panel activation time.
4. If 10m is too large, keeps the central panel laggy, or is not visibly better at HUD scale, keep 50m runtime data and only document the rejected candidate plus any small rendering-budget refinement.
5. If 10m is acceptable, replace `components/EarthCoastlineData.js` with the reviewed generated JS module and tune stride/budget constants so compact mode stays bounded and central activation stays responsive.
6. Make any terrain rendering refinements inside `components/RotatingGlobe.qml` without changing service/module boundaries.

## Decision (ADR-lite)

**Context**: The current 50m data already improved the Earth panel, but the plan leaves room for 10m high-precision coastline evaluation and terrain refinements.

**Decision**: Treat high-precision coastline replacement as evidence-driven. The task may conclude with either an approved replacement or a documented rejection if size/performance/visual trade-offs are not acceptable.

**Consequences**: This avoids blindly committing very large generated data while still allowing a higher-fidelity globe if the existing offline toolchain proves it is safe.

## Out Of Scope

* Runtime network map fetching.
* Committing raw Natural Earth downloads, shapefiles, or scratch GeoJSON inputs.
* Replacing the globe with a 3D engine or shader pipeline.
* Changing Earth geolocation service behavior.
* Adding real land texture rasters unless separately planned and licensed.
* Reworking unrelated HUD panels.

## Technical Notes

* Runtime renderer: `components/RotatingGlobe.qml`.
* Runtime data: `components/EarthCoastlineData.js`.
* Candidate docs: `docs/earth-coastline-preprocessing.md`.
* Tools: `tools/preprocess-coastlines.js`, `tools/inspect-coastlines.js`, `tools/validate-coastline-candidate.js`.
* Existing 50m stats: 1,425 polylines, 28,853 points, about 492 KB generated JS before provenance header.
* Required smoke checks are documented in `docs/earth-coastline-preprocessing.md`.

## Implementation Notes — 2026-05-10

The Natural Earth 10m candidate was generated and reviewed locally under `/tmp/opencode/coastline-candidates/ne-10m-coastline-2026-05-10/`. Its manifest passed `tools/validate-coastline-candidate.js --check-output`, but the candidate was rejected for runtime adoption in this slice: 3,690 polylines, 70,823 points, and 1,209,415 bytes would multiply central-panel activation and Canvas repaint work by roughly 2.5x over the current 50m runtime data. The current 50m dataset remains the best HUD-scale runtime trade-off.

Renderer work therefore focused on activation-stutter reduction without replacing offline data: expanded mode now uses explicit point/polyline terrain budgets instead of stride-1 rendering across all detail passes. Full candidate provenance, commands, stats, validation result, and trade-off notes are recorded in `notes.md` beside this PRD.
