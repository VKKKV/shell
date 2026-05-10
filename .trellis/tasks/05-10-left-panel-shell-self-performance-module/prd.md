# Left Panel Shell Self Performance Module

## Goal

Add a small left-panel module that shows the shell process's own resource usage and runtime health, so the HUD can distinguish global system load from shell self-cost. The first slice should be independently verifiable and must keep collection logic behind a service boundary.

## What I Already Know

* `docs/development-plan.md` lists this as the next roadmap slice: a left-panel shell self-performance/resource module.
* `modules/hud/LeftTacticalPanel.qml` currently composes visual modules and reads shaped service data; it should not run commands itself.
* `services/SystemStats.qml` already polls global CPU, memory, filesystem, and network stats with `Process`, `PollingSchedule`, `SettingsService.liveDataEnabled`, and `SettingsService.updateIntervalMs`.
* `services/ServiceLogService.qml` keeps recent service warning/error events and can be used to expose recent shell/service health.
* `components/MetricBlock.qml`, `components/MetricRow.qml`, and `components/Sparkline.qml` already provide compact left/right-panel readouts.
* `services/qmldir` registers singleton services explicitly.

## Assumptions

* The first MVP should display the current Quickshell process plus direct child/helper processes, not recursive process-tree aggregation.
* Linux `/proc` is available in the target environment because the project is a Quickshell desktop shell.
* Missing `/proc` or command failure should render readable fallback rows, not blank UI.
* No settings persistence should be added in this slice.
* No central expansion panel is required for the MVP unless the implementation naturally needs one.

## Requirements

* Add a service-owned shell self-performance data source, likely `ShellPerformanceService.qml`.
* Register the service in `services/qmldir`.
* Add a compact left-panel module/readout in `LeftTacticalPanel.qml` using existing components.
* Show shell-specific CPU, memory, direct child count, uptime or cadence/status, and recent warning/error state where feasible.
* Respect `SettingsService.liveDataEnabled` and `SettingsService.updateIntervalMs` for live polling.
* Use conservative polling and readable fallback rows if process data cannot be collected.
* Keep all command/process parsing inside `services/`, not `modules/hud/` or `components/`.
* Preserve existing left-panel interactions for orbital, Earth, agent, telemetry, and media drilldown.
* Update `docs/development-plan.md` when the slice is complete.

## Acceptance Criteria

* [ ] Left panel includes a visible shell self-performance/resource readout.
* [ ] The readout is backed by a service singleton and shaped rows/history, not direct module command parsing.
* [ ] The service reports shell CPU and memory for the current shell process plus direct children, or clear fallback values if unavailable.
* [ ] The service exposes recent health/warning status using existing project service/log patterns.
* [ ] Polling stops or avoids starting when `SettingsService.liveDataEnabled` is false.
* [ ] Existing left-panel modules remain usable and visually aligned.
* [ ] `services/qmldir` is updated for any new singleton.
* [ ] `docs/development-plan.md` records the completed slice and next safe follow-up.
* [ ] Verification includes `git diff --check`, `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`, and a short `quickshell -p .` smoke run where available.

## Definition Of Done

* The MVP is implemented as a small cross-layer slice: service plus left-panel display.
* Fallback behavior is visible and non-spammy.
* Lint and smoke checks pass where available.
* The task is reviewed with `trellis-check` before completion.

## Technical Approach

Recommended MVP: add `services/ShellPerformanceService.qml` as a singleton that obtains the shell PID using a low-risk local process command such as `sh -c 'printf %s "$PPID"'` or an equivalent Quickshell-safe current-process probe, then samples `/proc/<pid>/stat`, `/proc/<pid>/status`, and direct children from `/proc/*/stat` through a service-owned `Process`. The service should aggregate only the root shell PID plus direct children, then expose compact `rows`, `history`, and `statusLine` properties for the left panel.

In `modules/hud/LeftTacticalPanel.qml`, add a small `MetricBlock` plus optional `Sparkline` near the existing telemetry area. The panel reads only shaped service properties.

## Decision (ADR-lite)

**Context**: The project already has global `SystemStats`, but this feature needs shell-specific self-cost so users can tell whether the HUD itself is expensive.

**Decision**: Implement a dedicated service rather than mixing shell self metrics into global `SystemStats`, and aggregate the current shell PID plus direct child/helper processes for the MVP.

**Consequences**: This adds one singleton and one compact panel readout, but preserves service/module boundaries and leaves recursive process-tree aggregation, child-process attribution, and deeper frame timing for later slices.

## Out Of Scope

* Recursive process-tree aggregation beyond direct child processes.
* Per-child process attribution or detailed helper-process drilldown.
* Frame-perfect render timing or QML profiler integration.
* A central expansion panel for shell performance details.
* Settings persistence or user-configurable thresholds.
* Global system monitor changes unrelated to shell self metrics.
* OpenClaw or Agent provider changes.

## Technical Notes

* Roadmap source: `docs/development-plan.md`.
* Likely UI surface: `modules/hud/LeftTacticalPanel.qml`.
* Likely new service: `services/ShellPerformanceService.qml` plus `services/qmldir` registration.
* Existing global stats reference: `services/SystemStats.qml`.
* Existing health/log source: `services/ServiceLogService.qml`.
* Existing UI primitives: `components/MetricBlock.qml`, `components/MetricRow.qml`, `components/Sparkline.qml`.
* User decision: MVP uses current Quickshell process plus direct child/helper processes.
