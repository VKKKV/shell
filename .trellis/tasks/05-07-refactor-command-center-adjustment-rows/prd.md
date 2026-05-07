# refactor command center adjustment rows

## Goal

Reduce duplicated QML in `modules/hud/CommandCenterSettingsColumn.qml` by extracting the repeated two-button numeric adjustment row pattern into a reusable presentation component.

## Requirements

* Add a reusable component for paired decrement/increment controls.
* Replace repeated numeric adjustment rows in `CommandCenterSettingsColumn.qml`.
* Preserve existing labels, click behavior, clamping behavior, layout height, spacing, and tactical styling.
* Keep external command/service logic out of the new component.

## Acceptance Criteria

* [x] The new component is registered in `components/qmldir`.
* [x] Existing adjustment rows behave the same after refactor.
* [x] `CommandCenterSettingsColumn.qml` is materially shorter and easier to maintain.
* [x] QML lint and smoke checks pass.

## Definition of Done

* Tests added/updated where appropriate
* Lint / typecheck / CI green
* Docs/notes updated if behavior changes
* Rollout/rollback considered if risky

## Out of Scope

* Replacing palette/background/density grids
* Changing settings ranges or persisted settings contract
* Visual redesign

## Technical Notes

* Repeated rows currently appear for intensity, font scale, panel opacity, scanline strength, border opacity, dim text, line contrast, and poll rate.
* Existing component registration lives in `components/qmldir`.

## Implementation Notes

* Added `components/AdjustmentRow.qml` for paired decrement/increment controls.
* Replaced eight repeated numeric adjustment rows in `CommandCenterSettingsColumn.qml`.
* Preserved existing labels, clamps, and click behavior.
