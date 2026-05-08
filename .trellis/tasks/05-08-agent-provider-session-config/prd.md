# agent provider session config

## Goal

Add a session-local Agent provider configuration surface so users can choose a safe preset command for the current shell session without persisting provider settings yet.

## Requirements

- Add in-memory provider presets to `AgentService.qml`.
- Allow the Agent panel to select a preset for the current session.
- Do not write provider configuration through `SettingsService` or the Zig helper.
- Keep custom free-form commands out of scope.
- Preserve argv-array command execution only.
- Keep Hermes/OpenClaw as planned presets only if commands are discoverable or represented as missing-command fallbacks.

## Acceptance Criteria

- [x] `AgentService` exposes provider preset rows for UI display.
- [x] Selecting a preset updates `providerName`, `providerCommand`, and shaped status.
- [x] Selecting an unavailable preset does not start a command and reports unavailable state.
- [x] Provider choice resets on shell reload because it is session-local.
- [x] No `SettingsService`, Zig helper, or `docs/settings.md` persistence changes are made.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass.

## Technical Notes

- This implements the provider configuration contract as session-local UI state first.
- Persistent provider settings remain a future slice requiring Zig schema and tests.

## Verification

- `git diff --check`: passed
- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`
