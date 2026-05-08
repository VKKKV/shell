# runtime stability sweep

## Goal

Fix the verified runtime issues from review report #3 without changing unrelated behavior.

## Requirements

- Stop live-data timers when `SettingsService.liveDataEnabled` is false.
- Stop the orbital panel render timer when the panel is not active.
- Stop `RotatingGlobe` animations when the component is not visible.
- Remove the TOCTOU race in `AudioService.refresh()` and avoid duplicate process starts.
- Make backend-switch refresh logic in `KeyboardService` and `KeybindService` robust against stale running processes.
- Validate `ExpansionService.show()` surface names before opening the overlay.

## Acceptance Criteria

- [x] Disabled live data does not keep polling backend commands.
- [x] Hidden orbital/earth UI does not keep animating or repainting.
- [x] Rapid audio refresh calls do not lose pending updates or double-start processes.
- [x] Backend switches refresh with the correct process command/output path.
- [x] Invalid expansion surface names do not create a blank overlay state.

## Verification

- `git diff --check`: passed
- `zig build`: passed
- `zig build test`: passed
- `qmllint shell.qml components/*.qml modules/hud/*.qml services/*.qml theme/Theme.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`

## Scope Notes

- This task covers the seven severe findings from the review report.
- Medium and low findings are out of scope unless they block verification.
- Keep changes minimal and localized to the affected services/components.
