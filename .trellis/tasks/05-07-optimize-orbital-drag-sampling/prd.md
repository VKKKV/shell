# optimize orbital drag sampling

## Goal

Reduce Canvas work in `modules/hud/OrbitalExpansionPanel.qml` while the user is dragging the orbital view, without changing the steady-state look of the panel.

## What I already know

* The orbital panel already caches high/low orbit paths and rebuilds dynamic states.
* `orbitSampleCount` currently switches between 96 and 42 depending on `dragActive`.
* The code review called out unnecessary repaint cost during interaction.
* The panel already uses a timer-driven pulse animation, so the remaining obvious drag cost is path sample density.

## Assumptions (temporary)

* The best first optimization is to reduce drag-time orbit samples further, not to rewrite the whole Canvas.
* The user-visible goal is smoother dragging, not a visual redesign.

## Open Questions

* None for now.

## Requirements (evolving)

* Lower drag-time orbit sampling to reduce per-frame Canvas work.
* Keep steady-state orbit quality unchanged when not dragging.
* Preserve the existing orbit cache structure and selection logic.

## Acceptance Criteria (evolving)

* [x] Drag mode uses fewer orbit samples than the current 42-sample low path.
* [ ] Non-drag mode still uses the full 96-sample orbit path.
* [ ] The panel still renders and responds to selection/zoom correctly.

## Definition of Done (team quality bar)

* Tests added/updated (unit/integration where appropriate)
* Lint / typecheck / CI green
* Docs/notes updated if behavior changes
* Rollout/rollback considered if risky

## Out of Scope (explicit)

* Rewriting the orbital Canvas into layered offscreen caches
* Changing the visual design of the orbital panel
* Niri support work

## Technical Notes

* Target file: `modules/hud/OrbitalExpansionPanel.qml`
* Existing low-path sample count: 42
* Existing high-path sample count: 96

## Implementation Notes

* Drag sampling was reduced from 42 to 12 to lower Canvas work while dragging.
