# Continue Development Plan

## Goal

Continue the shell development plan with the next independently verifiable slice after the Nixie settings polish. The current roadmap points to the Earth globe high-precision coastline and procedural terrain upgrade; this task should choose a safe first vertical slice that advances that plan without destabilizing the Canvas2D globe.

## What I Already Know

* `docs/development-plan.md` lists OpenClaw CLI contract discovery first, but it is deferred until a local validation environment exists.
* The next local-only roadmap item is Earth globe high-precision coastline and procedural terrain upgrade.
* `components/RotatingGlobe.qml` renders the globe with Canvas2D and imports `components/EarthCoastlineData.js`.
* `components/EarthCoastlineData.js` is explicitly transitional and says future Natural Earth preprocessing can replace the arrays without changing the rendering contract.
* The existing globe already has offline coastlines, grid lines, signal nodes, night terminator, drag-to-rotate, and optional location marker behavior.
* The previous task recorded Plan A: Natural Earth 10m coastline data, GeoJSON-to-QML/JS preprocessing, layered Canvas2D composition, and procedural terrain texture.

## Assumptions

* OpenClaw should remain deferred unless a real local CLI contract is available.
* The Earth work should be split into small slices because full Natural Earth 10m ingestion plus render pipeline splitting is medium complexity.
* Runtime network access should not be introduced; any geographic data must be generated or embedded offline.
* Existing drag, grid, signal nodes, and location marker behavior should keep working.

## Open Questions

* None blocking this slice.

## Requirements (evolving)

* Implement the Earth globe preprocessing pipeline scaffold slice.
* Add a repeatable offline path that can convert GeoJSON-like coastline data into compact JS arrays compatible with `EarthCoastlineData.coastlines`.
* Add a small visible procedural Earth slice that improves realism without waiting for full Natural Earth 10m data replacement.
* Add Natural Earth generated-data evaluation support before replacing the active runtime coastline data.
* Add a local-only generated coastline candidate review workflow with manifest validation before any Natural Earth runtime replacement.
* Preserve the existing `RotatingGlobe` public contract and runtime rendering behavior in this slice.
* Keep all globe data offline at runtime.
* Document how future Natural Earth 10m input should flow through the pipeline without checking in unverified large generated data yet.
* Avoid mixing full data replacement and broad visual redesign into this task.

## Acceptance Criteria (evolving)

* [ ] The repo has a documented offline coastline preprocessing scaffold.
* [ ] The scaffold output format matches the current `EarthCoastlineData.coastlines` shape: an array of polylines, each polyline containing `[lat, lon]` pairs.
* [ ] Existing globe interactions still work: click/activate, horizontal drag rotation, signal nodes, grid, and optional location marker.
* [ ] Runtime does not fetch map data from the network.
* [ ] Current runtime coastline data remains unchanged unless a tiny fixture/sample is clearly separated from active runtime data.
* [ ] The globe includes visible ocean/land/atmosphere procedural detail while preserving the tactical HUD style.
* [ ] Generated coastline candidates can be inspected offline for polyline count, point count, byte size, coordinate bounds, and longest polyline before runtime replacement.
* [ ] Generated coastline candidates can be reviewed through a manifest that records provenance, generation command, inspector stats, smoke checks, and reviewer notes.
* [ ] Verification includes `git diff --check`, `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`, and a short `quickshell -p .` smoke run where available.

## Definition Of Done

* Tests or smoke checks pass for the selected slice.
* Lint/type checks pass where applicable.
* Docs/notes are updated if behavior or roadmap changes.
* The task is reviewed with `trellis-check` before completion.

## Out Of Scope (unless explicitly selected)

* OpenClaw CLI contract mapping.
* Runtime network fetching for map/coastline data.
* Full Earth rendering rewrite.
* Full Natural Earth 10m data replacement.
* Replacing the tactical HUD style with realistic satellite imagery.
* Multi-monitor, plugin, or lazy-loading architecture work.

## Technical Notes

* Roadmap source: `docs/development-plan.md`.
* Main render surface: `components/RotatingGlobe.qml`.
* Current data module: `components/EarthCoastlineData.js`.
* Earth panel copy: `modules/hud/EarthExpansionPanel.qml`.
* Left panel tooltip: `modules/hud/LeftTacticalPanel.qml`.
* Existing render layers in `RotatingGlobe`: ocean fill, latitude/longitude grids, land mass fill, coastline strokes, signal nodes, night terminator, scan rings, outer rings, location marker, labels.

## Decision (ADR-lite)

**Context**: The Earth globe upgrade has several valid paths, but full Natural Earth 10m data replacement and procedural terrain changes are too broad for one safe continuation slice.

**Decision**: Start with the preprocessing pipeline scaffold. Build the offline conversion path first, keep the runtime globe data and rendering stable, and document the expected input/output contract for future Natural Earth data.

**Consequences**: This reduces risk and makes future high-detail coastline work repeatable. It may not produce an immediate visible globe improvement until a later slice swaps in generated data.

## Follow-up Decision (ADR-lite)

**Context**: The preprocessing scaffold is complete, but the globe still needs a user-visible step toward the more realistic Earth roadmap before a reviewed Natural Earth 10m data swap is safe.

**Decision**: Add a minimal procedural visual layer pass in `RotatingGlobe.qml`: ocean hash texture, clipped land terrain hints, and atmospheric rim glow. Keep existing coastline arrays, public properties/signals, drag behavior, signal nodes, grid, marker, and scan rings unchanged.

**Consequences**: The globe reads as more detailed while the data pipeline remains stable. The procedural terrain is approximate tactical styling, not a real satellite or elevation texture, and should be tuned again after generated coastline data is reviewed.

## Follow-up Decision 2 (ADR-lite)

**Context**: The preprocessing scaffold and procedural terrain pass are complete, but replacing the active runtime coastline data still needs a review gate for Natural Earth provenance, generated file size, point counts, coordinate bounds, and drag repaint risk.

**Decision**: Add a small dependency-free generated coastline inspector plus a documented Natural Earth review checklist. Keep `components/EarthCoastlineData.js` unchanged until a generated candidate has source/version/license notes, generation command, inspector output, and smoke-check results.

**Consequences**: The next data replacement slice can be reviewed with objective stats instead of only visual inspection. This adds no runtime cost and does not introduce network access or large unverified data into the repository.

## Follow-up Decision 3 (ADR-lite)

**Context**: The inspector reports objective generated-data stats, but a real Natural Earth replacement still needs a repeatable review artifact that ties those stats to source provenance, generation inputs, smoke checks, and reviewer approval without committing large intermediate files.

**Decision**: Add a local-only candidate review workflow. Use `/tmp/opencode/coastline-candidates/<candidate-name>/` for raw input, generated output, and review manifests; add a dependency-free manifest validator that can compare recorded inspector stats against a local generated JS file. Keep runtime coastline data unchanged in this slice.

**Consequences**: A future replacement task can require a validated manifest before touching `components/EarthCoastlineData.js`. The manifest fixture is intentionally tiny and synthetic, so it validates tooling shape but does not prove Natural Earth visual quality or Canvas repaint performance.

## Candidate Slices

### A. Preprocessing Pipeline Scaffold (Recommended)

Add an offline script/tool path that converts a checked-in or documented GeoJSON input shape into compact JS coastline arrays matching the existing `EarthCoastlineData.coastlines` contract. Keep the current hand-curated data for runtime until the generated output is reviewed.

Pros: validates the riskiest part of the plan first, preserves runtime behavior, and creates a repeatable path for Natural Earth data.

Cons: user-visible globe detail may not change yet unless a small generated sample is also included.

### B. Render Pipeline Split

Refactor `RotatingGlobe.qml` painting into named helper functions for ocean, grids, land, coastline, nodes, terminator, rings, marker, and labels before changing data volume.

Pros: reduces risk before adding 10K+ points and procedural texture layers.

Cons: mostly internal refactor; visual improvement is limited.

### C. Visual Terrain Prototype

Add procedural ocean/land noise and atmospheric rim glow while keeping the current coastline data.

Pros: immediate visual improvement and keeps data unchanged.

Cons: can hide data-quality problems and may make later layer splitting harder if done first.

### D. Full Generated Coastline Replacement

Replace `EarthCoastlineData.js` with generated Natural Earth-style data and tune rendering in one slice.

Pros: biggest visible coastline improvement.

Cons: highest risk; larger data diff, performance uncertainty, and harder review.
