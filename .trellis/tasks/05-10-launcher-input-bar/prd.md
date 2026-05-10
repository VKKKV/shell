# Launcher Input Bar

## Goal

Add a compact launcher input bar as an independently verifiable HUD slice, so apps/actions/calculator entries can be opened from a focused tactical bar without opening the full command center.

## What I Already Know

* `docs/development-plan.md` lists `Launcher input bar` as a future slice.
* `services/LauncherService.qml` already owns query state, app indexing, filtering, calculator entries, shell dispatch, actions, and launch execution.
* `modules/hud/CommandCenterPanel.qml` already has a `TextInput` bound to `LauncherService.query` and proves the service contract works.
* `modules/hud/HudLayout.qml` owns global HUD composition, input regions, settings/expansion layers, and shortcuts.
* `modules/hud/TopStatusBar.qml` has a right-side `ColumnLayout`; the tray lives in the lower row, leaving an appropriate area above the tray/settings/media strip for an embedded launcher input.
* Existing shortcuts are minimal: `Ctrl+Alt+S` toggles the command center, and `Escape` closes command center/expansion surfaces.
* `modules/hud/qmldir` registers module QML files explicitly.

## Assumptions

* Reuse `LauncherService` rather than creating a second launcher provider/service.
* First slice should focus on the bar surface, focus/dismiss behavior, result rendering, and launch activation.
* No provider persistence, plugin ordering, or fuzzy ranking changes should be added in this slice.
* No broad command execution changes beyond the behavior already present in `LauncherService`.
* The launcher bar should not replace the existing command center search input.

## Requirements

* Add a compact launcher bar surface inside `TopStatusBar`, in the space above the tray/settings/media row.
* A separate `modules/hud/LauncherInputBar.qml` may be used if it keeps `TopStatusBar` readable; if added, register it in `modules/hud/qmldir`.
* Add a launcher-open state and open/close/toggle methods in the appropriate service boundary, preferably `LauncherService` because it already owns query and launch state.
* Add a global shortcut to open/focus the launcher bar without conflicting with `Ctrl+Alt+S`; recommended default: `Ctrl+Space`.
* Render a focused `TextInput` bound to `LauncherService.query` and a small result list from `LauncherService.filtered`.
* Support keyboard behavior: type to filter, `Enter` launches the selected/top result, `Escape` closes the bar, and arrow keys should move selection if feasible.
* Add a clear empty/fallback state when there are no providers or no results.
* Keep launch/query logic inside `LauncherService`; the module should compose shaped service data and call service intent methods.
* Preserve command center search behavior and existing settings/expansion close behavior.
* Update `docs/development-plan.md` after completion.

## Acceptance Criteria

* [ ] A visible launcher input bar can be opened with a shortcut and dismissed with `Escape`.
* [ ] The input bar receives focus predictably when opened.
* [ ] Typing updates `LauncherService.query` and renders filtered actions/apps/calculator entries.
* [ ] Pressing `Enter` launches the selected/top result through `LauncherService`.
* [ ] No direct command execution or app parsing is added to the module/component layer.
* [ ] Existing command center search still works.
* [ ] Existing `Ctrl+Alt+S`, expansion close, tray, media controls, and left/right panel interactions are not regressed.
* [ ] `modules/hud/qmldir` is updated if a new module file is added.
* [ ] `docs/development-plan.md` records the completed slice and next safe follow-up.
* [ ] Verification includes `git diff --check`, `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`, and a short `quickshell -p .` smoke run where available.

## Definition Of Done

* Launcher input bar opens, focuses, filters, launches, and closes in a smoke run.
* Fallback/empty state is readable.
* Lint and smoke checks pass where available.
* The task is reviewed with `trellis-check` before completion.

## Technical Approach

Recommended MVP: extend `LauncherService` with bar visibility, selected index, `openBar()`, `closeBar()`, `toggleBar()`, `moveSelection(delta)`, and `launchSelected()` helpers. Add a compact launcher input surface in `TopStatusBar` above the tray/settings/media row, binding `TextInput.text` to `LauncherService.query`, displaying `LauncherService.filtered`, and delegating all launch behavior to the service.

In `HudLayout.qml`, add a `Ctrl+Space` shortcut that opens/focuses the top-bar launcher. `Escape` should close the launcher bar before closing settings/expansion surfaces when the bar is open. Because the bar lives inside `TopStatusBar`, the existing `topInputRegion` should continue to cover pointer input.

## Decision (ADR-lite)

**Context**: `LauncherService` already provides query/filter/launch behavior for the command center, so adding a second launcher service would duplicate state and ranking behavior.

**Decision**: Reuse and lightly extend `LauncherService`, and implement the first launcher bar slice inside `TopStatusBar` above the tray area.

**Consequences**: The feature stays small and consistent with the command center. Future ranking/provider work can happen inside `LauncherService` without changing the launcher bar contract.

## Out Of Scope

* Provider persistence or plugin ordering.
* New fuzzy ranking algorithm.
* New app indexing backend beyond existing `LauncherService` behavior.
* Broad shell command execution changes.
* Launcher history, pinning, or favorites.
* Replacing command center search.
* Screenshot bottom surface implementation.

## Technical Notes

* Roadmap source: `docs/development-plan.md`.
* Launcher state/service: `services/LauncherService.qml`.
* Existing search consumer: `modules/hud/CommandCenterPanel.qml`.
* Composition owners: `modules/hud/TopStatusBar.qml` for the visible bar and `modules/hud/HudLayout.qml` for global shortcut/Escape routing.
* Optional new module: `modules/hud/LauncherInputBar.qml` plus `modules/hud/qmldir` registration if extraction keeps the top bar simpler.
* Existing styling primitives: `components/TacticalFrame.qml`, `TacticalLabel`, `MetricRow`, `Theme.qml`.
* User decision: place the launcher input inside `TopStatusBar`, in the space above the tray.
