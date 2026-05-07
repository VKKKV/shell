# brainstorm: next shell phase plan

## Goal

Define the next development phase for the Quickshell-based tactical shell, using the latest code review findings as input. The goal is to turn the review into a practical plan with a clear MVP boundary, priority order, and implementation slices that reduce risk and rework.

## What I already know

* The repo is a single-repo Quickshell/QML shell with a Zig settings helper.
* Current documentation covers settings persistence, Hyprland integration, and Niri integration.
* The README describes the shell as a tactical desktop environment with runtime appearance controls, integrated monitoring, and a persisted settings contract.
* The review report identifies high-risk issues in settings persistence, CPU accounting, clipboard injection, and audio command races.
* The review report also identifies cross-compositor gaps, animation/performance issues, and refactor opportunities in HUD expansion panels and settings handling.

## Assumptions (temporary)

* This phase should be organized as a roadmap or implementation plan, not direct code changes yet.
* The most valuable work likely starts with correctness and safety issues before larger refactors.
* Some items from the review may be deferred to later phases to keep the initial phase deliverable.

## Open Questions

* Whether the current phase should remain a plan-only task or proceed into implementation after the plan is approved.

## Requirements (evolving)

* Convert the review findings into a prioritized next-phase plan.
* Define an MVP scope that can be delivered without boiling the ocean.
* Keep future work visible by explicitly separating in-scope and out-of-scope items.
* Preserve compatibility with the existing Quickshell/QML and Zig split.
* Consider compositor differences where relevant.
* Prioritize correctness/security work before performance-only and extensibility-only work.
* Base the plan on the current code state, not only the pasted review text.
* Exclude Niri keyboard/keybind parity from the current development plan.
* Keep Niri keyboard/keybind testing/support in the future-plan backlog.

## Acceptance Criteria (evolving)

* [x] The next phase has a clear focus area: correctness/security.
* [x] High-risk issues are prioritized relative to lower-risk refactors.
* [x] The plan has explicit out-of-scope items.
* [x] The plan can be split into implementable steps.
* [x] Settings directory creation has regression coverage.
* [x] Current copy paths use direct argv `wl-copy` instead of shell-wrapped `printf`.
* [x] Current CPU accounting avoids guest/guest_nice double counting.
* [x] Current audio actions use queues to avoid command overwrite races.
* [x] Current session logout fallback avoids `terminate-user ""`.

## Definition of Done (team quality bar)

* Tests added/updated (unit/integration where appropriate)
* Lint / typecheck / CI green
* Docs/notes updated if behavior changes
* Rollout/rollback considered if risky

## Out of Scope (explicit)

* Large visual redesign unrelated to the review findings
* Broad architecture rewrites that are not needed for the MVP phase
* Adding new product features unrelated to the reported issues
* Niri keyboard/keybind parity fixes and runtime validation for this phase
* Performance-only HUD rendering improvements
* Extensibility refactors such as data-driven expansion panels, generated settings schemas, or shared polling infrastructure

## Technical Notes

* README: `README.md`
* Settings contract: `docs/settings.md`
* Hyprland integration: `docs/hyprland.md`
* Niri integration: `docs/niri.md`
* Settings helper: `src/settings/main.zig`
* HUD panels and services: `modules/hud/*.qml`, `services/*.qml`
* Current verification of high-risk review findings:
  * B1 settings directory creation failure: still worth handling. Current `ensureSettingsDir` logs and returns `void`, but `writeSettings` still proceeds to `createFile`; if directory creation failed, persistence still fails. The plan should make the failure mode explicit and non-fatal at the QML boundary, or improve helper behavior/test coverage.
  * B2 CPU usage undercounting: appears already fixed in current code. `services/SystemStats.qml` sums `values.slice(0, 8)`, avoiding guest/guest_nice double counting. Keep as regression test/manual check, not a main implementation item.
  * B3 shell injection in clipboard copy paths: appears already fixed for the cited copy paths. `ClipboardService.qml`, `KeybindService.qml`, and calculator copy in `LauncherService.qml` call `wl-copy` directly with argv instead of `sh -c printf`. Remaining shell execution in launcher `$` entries is an intentional feature and should be treated separately from copy-path injection.
  * B4 audio service race condition: appears already fixed. `AudioService.qml` uses sink and mic action queues around shared `Process` instances.
  * B5 Hyprland-only keyboard/keybind commands on Niri: partially addressed. `KeyboardService.qml` and `KeybindService.qml` choose Hyprland or Niri commands based on `CompositorService`, but Niri payload shape and command availability need validation against real `niri msg` output.
  * B7 unsafe `USER` fallback in session action: appears already fixed. `SessionService.qml` falls back from `terminate-user $USER` to `terminate-session $XDG_SESSION_ID`, otherwise returns `[]`.
* Current correctness/security candidate scope:
  * Harden settings persistence failure behavior and tests.
  * Add regression coverage/manual validation for CPU accounting.
  * Document and verify direct-argv `wl-copy` copy paths.
  * Verify queued audio actions do not drop rapid mute/volume changes.
  * Confirm session logout fallback behavior remains safe when environment variables are missing.
* Future-plan backlog:
  * Niri keyboard/keybind parity: validate `niri msg keyboard-layouts` and `niri msg binds` output shape, update parsers if needed, and add manual validation notes under the Niri support plan.

## Implementation Notes

* `src/settings/main.zig`: `ensureSettingsDir` now returns errors for real directory creation failures instead of only logging and continuing.
* `src/settings/main.zig`: `writeSettings` now uses `try ensureSettingsDir(...)`, making the helper failure explicit so QML can keep its existing recoverable `settings: helper write fallback` path.
* `src/settings/main.zig`: added a regression test proving nested settings directories are created before writing settings.
* Verified current implementations for the previously reported high-risk issues:
  * CPU totals already use fields `0..7` only.
  * Clipboard/keybind/calculator copy paths already call `wl-copy` directly through argv.
  * Audio sink and mic actions already use queues.
  * Session logout already falls back to `XDG_SESSION_ID` and returns `[]` if no safe target exists.
* Lower-priority review findings deferred by default:
  * B6 orbital panel animation driven by `Date.now()` in paint
  * O1 orbital panel repaint cost
  * O2 command center settings duplication
  * O3 calendar cache rebuild every minute
  * O4 background grid layout work while hidden
  * O5 repeated density comparisons in theme
  * E1 hardcoded expansion panels
  * E2 brittle compositor abstraction
  * E3 duplicated settings patterns between Zig and QML
  * E4 repeated polling infrastructure
  * E5 orbital elements hardcoded in QML
  * E6 non-generic settings change handlers
