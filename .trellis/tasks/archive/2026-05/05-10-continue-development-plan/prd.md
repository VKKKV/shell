# Continue Development Plan

## Goal

Continue the active roadmap with the next independently verifiable shell slice. The current safe track is Earth globe visual fidelity/performance, but this task must first absorb the review feedback on the already-present procedural fidelity diff before adding more polish.

## What I Already Know

* `docs/development-plan.md` requires one independently verifiable vertical slice per task.
* The Agent track is complete through Hermes CLI contract mapping; OpenClaw remains deferred.
* The Earth track has completed offline coastline extraction, Natural Earth 50m replacement, compact render budgets, and an expanded-only procedural fidelity budget.
* `components/RotatingGlobe.qml` is a single Canvas2D globe component with offline coastline data, drag rotation, expanded/compact render budgets, ocean texture, land relief, tactical grid, signal nodes, night terminator, and optional location marker.
* `modules/hud/EarthExpansionPanel.qml` already describes the Natural Earth 50m dataset and current procedural model.
* The worktree already contains the previously completed Earth procedural fidelity slice; this task should build on it rather than revert it.
* User selected all three visual refinement directions: coastline stroke hierarchy, relief threshold tuning, and atmospheric rim polish.
* Review feedback found no blocking correctness bug, but raised performance/regression risk from expanded-mode per-frame drawing, visual naming mismatch for coastline-derived relief, dead compact bathymetry config, and fragile function-scoped variable reuse in the new bathymetry block.
* User selected not to add a lightweight profiling/debug timing hook in this slice.
* User wants a future feature added to the development plan: a left-panel module showing the shell's own resource usage and performance behavior.

## Assumptions

* Do not implement OpenClaw behavior without a verified local CLI contract.
* Do not replace the runtime coastline dataset with Natural Earth 10m in this slice.
* Keep runtime map data fully offline.
* Keep the public `RotatingGlobe` properties and signals stable.
* Prefer a small Canvas2D refinement and review cleanup over broad renderer restructuring.
* Record the shell self-performance module as a future roadmap feature, but do not implement it in this Earth slice.

## Review Findings To Address

* Expanded-mode drawing cost is the main regression risk because rotation repaints continuously.
* Existing `drawLandRelief()` samples coastline vertices, so the current effect is coastal/edge texture rather than true interior terrain.
* `bathymetryLatStep` and `bathymetryLonStep` currently expose compact-mode values even though bathymetry is expanded-only.
* New bathymetry code relies on function-scoped `var` reuse, which is valid but fragile.

## Open Questions

* None.

## Requirements

* Implement the selected Earth visual refinements: coastline stroke hierarchy, relief threshold tuning, and atmospheric rim polish.
* Address review cleanup before adding more drawing detail: localize bathymetry variables, remove or clarify dead compact bathymetry config, and rename coastline-derived relief if it remains coastline-sampled.
* Keep the added expanded-mode detail constrained by explicit budgets or thresholds.
* Do not add profiling/debug timing hooks in this slice.
* Preserve the existing offline Natural Earth 50m dataset and generated-data review workflow.
* Preserve current interactions: activate/click, horizontal drag rotation, grid, signal nodes, night terminator, and optional location marker.
* Keep compact mode bounded so the left-panel globe does not pay expanded-mode decorative cost.
* Update `docs/development-plan.md` after the slice is complete.
* Update Earth panel copy only if the visible model changes.

## Acceptance Criteria

* [ ] The task changes visible Earth rendering outcomes without changing public component API.
* [ ] Expanded mode receives richer coastline hierarchy, tuned relief texture, and rim/terminator polish.
* [ ] Review cleanup removes fragile variable reuse and avoids misleading dead compact bathymetry configuration.
* [ ] Coastline-derived relief is named/copy-described accurately unless a real interior sampler is implemented.
* [ ] Compact mode remains lower-budget than expanded mode.
* [ ] Runtime still imports offline coastline data and performs no map-data network fetch.
* [ ] `docs/development-plan.md` records the completed slice and the next safe follow-up.
* [ ] `docs/development-plan.md` adds a future left-panel shell self-performance/resource module without making it part of this implementation.
* [ ] Verification includes `git diff --check`, `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`, and a short `quickshell -p .` smoke run where available.

## Definition Of Done

* The selected slice is implemented and smoke-checked.
* Lint/type checks pass where available.
* Docs/roadmap notes are updated if behavior or next steps change.
* The task is reviewed with `trellis-check` before completion.

## Technical Approach

Implement the refinements in this order:

1. Review cleanup: use local variables in the bathymetry block, simplify expanded-only bathymetry constants or document intent, and rename coastline-derived relief to coastal relief/texture if the sampler remains coastline-based.
2. Coastline hierarchy: add or tune constrained expanded-mode coastline stroke layering so major coastlines read more clearly without changing runtime data.
3. Relief/rim polish: tune relief thresholds/alpha and atmospheric rim/terminator values, keeping compact mode sparse and avoiding additional broad passes unless justified.

Do not add timing/profiling support in this slice. Add the shell self-performance/resource module to `docs/development-plan.md` as a future feature so it can become its own service/module slice later.

## Decision (ADR-lite)

**Context**: The roadmap lists optional Natural Earth 10m evaluation plus further procedural Canvas2D refinement. The latest review found the current expanded-mode procedural diff visually reasonable but with performance and naming risks.

**Decision**: Defer 10m replacement and implement a review-informed Canvas visual refinement slice covering coastline hierarchy, relief threshold tuning, and rim polish, with cleanup before additional detail.

**Consequences**: The work remains visible and reviewable, but expanded-mode per-frame cost must stay bounded and any remaining coastline-derived relief must be described honestly rather than as true interior terrain.

## Out Of Scope

* OpenClaw CLI contract mapping.
* Natural Earth 10m runtime replacement.
* Runtime network fetching for map/coastline data.
* Full `RotatingGlobe.qml` renderer rewrite.
* Settings persistence or new user-facing configuration.
* Profiling/debug timing hooks for the globe renderer.
* Implementing the left-panel shell self-performance/resource module.
* Full real terrain/interior sampling unless it can be implemented as a small bounded pass.
* Multi-monitor, plugin, or lazy-loading architecture work.

## Technical Notes

* Roadmap source: `docs/development-plan.md`.
* Main render surface: `components/RotatingGlobe.qml`.
* Runtime data module: `components/EarthCoastlineData.js`.
* Earth panel copy: `modules/hud/EarthExpansionPanel.qml`.
* Review source: user-provided findings for `components/RotatingGlobe.qml` lines around bathymetry, land relief, animation repaint, and variable reuse.
* Future shell self-performance module should likely be its own cross-layer slice because it will need a service boundary for process/resource data and a left-panel module for display.
