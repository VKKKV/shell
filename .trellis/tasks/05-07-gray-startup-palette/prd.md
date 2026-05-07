# brainstorm: gray startup palette

## Goal

Make the shell start in a gray tactical palette by default, while keeping the existing accent/profile system intact and preserving the current runtime controls.

## What I already know

* The current default theme profile is `amber` in `services/SettingsService.qml`.
* `Theme.qml` derives most visual colors from `SettingsService.themeProfile`, `SettingsService.accentColor`, and the contrast helpers.
* `docs/settings.md` currently documents `visual.profile` as `amber`, `green`, `blue`, or `red`.
* `WallpaperService.qml` can suggest a profile from sampled wallpaper color, but startup defaults still come from `SettingsService`.
* The project already treats theme/profile settings as persistent settings normalized by the Zig helper.

## Assumptions (temporary)

* “Gray startup palette” should be a default startup visual state, not necessarily a new full-color theme system.
* The current profile system should remain the same unless a new gray option is required to represent the startup default cleanly.

## Open Questions

* None.

## Requirements (evolving)

* Capture a development plan from the project-wide code review findings.
* Change the startup default so the shell loads in a gray palette.
* Keep current runtime profile switching and settings persistence intact.
* Ensure the default is represented consistently in QML, docs, and Zig normalization if a new profile value is introduced.
* Add `gray` as a persistent profile option and make it the default.
* Use `#8A8A8A` as the default gray accent.

## Acceptance Criteria (evolving)

* [x] The shell starts with a gray palette by default when no persisted settings override it.
* [x] Existing settings persistence still loads and saves theme values correctly.
* [x] Runtime profile controls include `gray`.
* [x] `gray` is documented and normalized consistently.
* [x] The review findings are ordered into a follow-up development plan.

## Definition of Done (team quality bar)

* Tests added/updated (unit/integration where appropriate)
* Lint / typecheck / CI green
* Docs/notes updated if behavior changes
* Rollout/rollback considered if risky

## Out of Scope (explicit)

* Redesigning the full theme engine
* Changing unrelated settings defaults
* Altering the wallpaper color suggestion flow unless needed to support gray

## Technical Notes

* Current default profile: `SettingsService.themeProfile = "gray"`
* Current default accent: `SettingsService.accentColor = "#8A8A8A"`
* Current profile contract: `docs/settings.md` and `src/settings/main.zig`

## Decision (ADR-lite)

**Context**: The user requested gray as the startup default. The existing settings model already has a persisted `visual.profile` field, but actual line/accent color is driven by `visual.accentColor`.

**Decision**: Add `gray` as a first-class profile and set both default `visual.profile` and default `visual.accentColor` to gray.

**Consequences**: Existing persisted user settings continue to override defaults. The cross-layer settings contract must be updated in QML, Zig helper validation/defaults, docs, and tests.

## Development Plan

### PR1: Gray Startup Palette (implemented in this task)

* Add `gray` as a persistent `visual.profile` value.
* Set default startup `visual.profile` to `gray`.
* Set default startup `visual.accentColor` to `#8A8A8A`.
* Update QML settings controls, Zig helper defaults/validation/tests, docs, and code-spec.

### PR2: Settings Save Reliability

* Fix `SettingsService.saveNow()` so changes made while `writeProcess` is running are not lost.
* Add a `dirtyWhileWriting` or queued-payload mechanism.
* Verify rapid settings changes persist the latest payload.
* Status: implemented with `activeWritePayload`, `queuedWritePayload`, and `writeQueued`.

### PR3: Network Action Serialization

* Prevent `NetworkDetailService` shared action processes from dropping rapid reconnect/down/toggle commands.
* Use action queues or running guards per action category.
* Keep status lines readable and refresh after each completed action.
* Status: implemented with a generic `actionQueue` and serialized `actionProcess` dispatch for reconnect/down/bluetooth power actions.

### PR4: Clipboard Fidelity

* Preserve raw clipboard text in history instead of `trim()`-normalizing it.
* Keep preview compaction separate from stored text.
* Decide whether all-whitespace clipboard entries should be stored or ignored explicitly.

### PR5: Network Parser Robustness

* Replace naive `line.split(":")` parsing for `nmcli -t` output with an escaped-colon-aware parser or a more stable output format.
* Validate active connections and Wi-Fi rows with names/SSIDs containing colons.

### PR6: Niri Keybind Diagnostics

* Fix backend-specific fallback text in `KeybindService` so Niri failures do not report `hyprctl fallback`.
* Validate the real `niri msg binds` output shape before expanding parser support.

## Research Notes

### Feasible approaches here

**Approach A: Gray as a new profile** (Recommended)

* How it works: add `gray` to the `visual.profile` / `SettingsService.themeProfile` contract, give it a gray startup default, and update theme mapping/persistence.
* Pros: explicit, persistent, easy to document, consistent with the existing profile model.
* Cons: requires contract updates in Zig, QML, and docs.

**Approach B: Gray as the default accent only**

* How it works: keep profiles unchanged, but change startup `accentColor` and possibly `lineContrast`/panel values so the shell looks gray on first launch.
* Pros: smaller contract change.
* Cons: startup state is less explicit; profile and accent semantics become easier to confuse.

Which approach do you prefer: A or B?
