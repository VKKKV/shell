# continue shell development

## Goal

Polish the current shell continuation slice by tightening staged Agent panel wording, fixing settings contract readability, and resolving the real startup/layout risks identified during review.

## Requirements

- Keep Agent provider integration staged as UI-only language.
- Make the Agent panel copy clearer about what is implemented versus deferred.
- Fix the indentation and shape of the JSON example in `docs/settings.md`.
- Avoid introducing backend/provider execution or new persistence contracts.
- Convert `PollingSchedule.qml` to the standard service singleton shape.
- Gate external I/O and live-data service startup until `SettingsService.loading === false`.
- Add a small normalization re-entrancy guard in `SettingsService.qml`.
- Fix bottom bar date truncation with full/short adaptive text and hover detail.
- Audit and fix dynamic text containers that should remain readable.

## Acceptance Criteria

- [x] `modules/hud/AgentExpansionPanel.qml` uses clearer staged-contract language.
- [x] `docs/settings.md` renders a valid, consistently indented JSON example.
- [x] No new provider backend logic is added.
- [x] `services/PollingSchedule.qml` uses the standard `Singleton` skeleton with `pragma ComponentBehavior: Bound`.
- [x] External I/O/live-data services wait for settings loading to settle before startup polling.
- [x] `SettingsService.qml` normalization is guarded against re-entrant handler ambiguity.
- [x] Bottom bar date expands when possible, falls back to short date under pressure, and exposes full date through the HUD tooltip.
- [x] Fixed dynamic text audit keeps deliberate elision but removes avoidable fixed-width truncation in shared labels/tooltips.

## Technical Notes

- This is a frontend/doc cleanup slice only.
- Keep the changes minimal and aligned with the existing tactical shell language.

## Prioritized Plan

1. Fix low-risk but real consistency issues first, starting with `services/PollingSchedule.qml` by giving it a standard `Singleton` skeleton plus `pragma ComponentBehavior: Bound`.
2. Harden startup/polling initialization so services do not begin work before settings loading settles.
3. Tighten `SettingsService.qml` normalization flow only as needed to remove re-entrant ambiguity.
4. Fix the bottom bar left date readout so it can extend toward the center first, then switch to a short date format only when it would collide with neighboring content.
5. Audit and fix dynamic text containers with fixed widths or fixed maximum widths so visible labels do not truncate unexpectedly; keep pure icon/control primitives unchanged.
6. Revisit polling duplication and service decomposition only after the behavior is stable.
7. Defer performance tuning and broader service architecture cleanup until the above are verified.

## Resolved Design Decisions

- Repair real runtime and consistency risks before broad refactors.
- Convert `PollingSchedule.qml` to the standard service `Singleton` skeleton instead of only adding a pragma.
- Gate service startup polling on `SettingsService.loading === false` using `Connections`; do not introduce a shared polling framework yet.
- The settings gate exists so custom settings loaded through the Zig helper (`void-shell-settings`) are applied before external I/O or live-data services start polling.
- Apply the startup gate to services that run external I/O, network, compositor, media, or live-data reads; do not delay pure local time/calendar services.
- `SettingsService.loading === false` means the settings phase has settled, not that the helper succeeded; if the helper is unavailable or read fails, services should continue with safe defaults and respect `liveDataEnabled`.
- Each gated service should use a small service-local helper such as `startPollingIfReady()` instead of introducing a shared `PollingService` in this phase.
- When `liveDataEnabled` switches from false to true after settings have settled, services should refresh immediately and then start or restart their poller.
- Starting or restarting an external I/O poller must always require both `!SettingsService.loading` and `SettingsService.liveDataEnabled`.
- `SettingsService` normalization should receive a small re-entrancy guard in this phase; do not split settings state, validators, or persistence yet.
- Bottom bar date behavior should prefer the full format expanding toward the center, then fall back to a short format when adjacent content would be touched.
- The short fallback date format should reuse the existing compact calendar date style (`yyyy-MM-dd`) instead of introducing a new format.
- The date switch should be based on comparing the `implicitWidth` of the full and short text variants, not on runtime collision heuristics.
- Audit rules: only fix fixed-width text containers whose content should remain fully readable; keep deliberate tactical elision in status chips, icon blocks, and other dense labels.
- When the date is shortened, the full date should still be available on hover through the existing HUD tooltip system.
- Date hover should reuse the existing `TooltipService`/`HudTooltipBox` semantics rather than creating a separate tooltip component.

## Verification

- `git diff --check`: passed
- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed
- `zig build`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`
