# runtime medium cleanup

## Goal

Resolve the medium-severity findings from review report #3 after the severe runtime stability sweep.

## Requirements

- Re-check whether `SettingsService` write queue races are already fixed and document current status.
- Reduce unnecessary `ServiceLogService.push()` allocation churn if it causes avoidable redraw pressure.
- Verify `AudioService.refreshSink()` / `refreshMic()` do not double-start read processes after the severe sweep.
- Harden `SystemStats` filesystem command handling for mount paths containing spaces or shell metacharacters.
- Prevent `HudLayout` expansion backdrop from intercepting clicks when no expansion panel is actually active.

## Acceptance Criteria

- [x] Each medium finding #8-#12 is either fixed or documented as already fixed/not reproducible against current code.
- [x] Any code changes are minimal and localized.
- [x] QML lint and project smoke checks pass.

## Findings Status

- #8 `SettingsService` write queue: already fixed by `activeWritePayload`, `queuedWritePayload`, and `writeQueued`.
- #9 `ServiceLogService.push()` allocation churn: reduced by dropping consecutive duplicate events before allocating a new array.
- #10 `AudioService.refreshSink()` / `refreshMic()` duplicate starts: already fixed by pending flags set before running checks.
- #11 `SystemStats.filesystemProcess` shell quoting risk: fixed by replacing the shell/eval command with direct `df -B1` arguments.
- #12 `HudLayout` expansion backdrop click interception: fixed by requiring a valid expansion surface before the layer becomes visible.

## Verification

- `git diff --check`: passed
- `zig build`: passed
- `qmllint shell.qml components/*.qml modules/hud/*.qml services/*.qml theme/Theme.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`

## Scope Notes

- Low-severity findings remain out of scope unless a medium fix naturally touches the same line.
- Do not change settings persistence behavior unless a current race is reproduced.
