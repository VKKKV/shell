# continue shell development

## Goal

Continue shell development with a small, verifiable feature slice focused on documentation polish and HUD readability. OpenClaw CLI support is deferred to future planning because there is no local `openclaw` environment available for contract validation.

## What I already know

* The task was created from the current session and is still in `planning`.
* `docs/development-plan.md` lists the Agent track as complete through Hermes CLI contract mapping.
* The same document marks the next slice as `OpenClaw CLI contract discovery`.
* `services/AgentService.qml` currently probes `hermes` and `openclaw`, but OpenClaw still uses the placeholder command `openclaw agent`.
* `modules/hud/AgentExpansionPanel.qml` still describes the provider UI as staged/deferred.
* `docs/settings.md` already documents the persisted provider IDs: `disabled`, `hermes`, and `openclaw`.
* There is no local `openclaw` binary/environment available for validation in this workspace.

## Assumptions (temporary)

* This slice should stay focused on docs cleanup plus one visible HUD readability fix.
* Hermes behavior should remain unchanged.
* If OpenClaw is unavailable or its real contract cannot be verified, the UI should keep a safe fallback state.

## Open Questions

* None blocking this slice.

## Requirements (evolving)

* Fix the JSON example in `docs/settings.md` so it is easier to read and copy.
* Improve one visible HUD layout/readability issue without broad redesign.
* Keep Hermes unchanged.
* Keep the staged Agent UI safe and readable.
* Avoid introducing custom provider support or backend execution in this slice.

## Acceptance Criteria (evolving)

* [x] The selected docs and HUD fixes are implemented as a small, verifiable slice.
* [x] `docs/settings.md` has a clean, consistent JSON example.
* [x] The selected HUD surface is more readable or better centered.
* [x] `AgentService` and Hermes behavior remain unchanged unless the selected slice requires otherwise.
* [x] The Agent panel remains consistent with the staged contract language.

## Definition of Done

* Tests added/updated where appropriate.
* Lint / typecheck / smoke checks green.
* Docs/notes updated if behavior changes.

## Out of Scope (explicit)

* OpenClaw CLI contract discovery.
* Custom provider execution.
* Provider persistence schema changes.
* Broad Agent UI redesign.

## Technical Notes

* Active implementation targets: `docs/settings.md` and one HUD layout surface.
* Related UI surface: likely `modules/hud/BottomStatusBar.qml` or a nearby status/readability surface.
* Plan source: `docs/development-plan.md`.
* OpenClaw CLI support remains deferred because the local `openclaw` command/environment is unavailable.
* Implemented `docs/settings.md` update for persisted `data.networkGeolocationEnabled`.
* Implemented `modules/hud/BottomStatusBar.qml` responsive widths for node, mission dock, and channel readouts to reduce rigid fixed-width pressure.
* Follow-up slice: cleaned stale Agent panel copy now that Hermes can execute locally when available.
* OpenClaw remains explicitly unvalidated/deferred until a local validation environment exists.

## Verification

* `git diff --check`: passed.
* `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed.
* `timeout 5s quickshell -p .`: passed; logs included `Configuration Loaded`.
* Independent `trellis-check` review: passed with no findings.

### Agent Copy Cleanup Slice

* `git diff --check`: passed.
* `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed.
* `timeout 5s quickshell -p .`: passed; logs included `Configuration Loaded`.
* Independent `trellis-check` review: passed with no findings.
