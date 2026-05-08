# agent adapter mapping

## Goal

Map Hermes and OpenClaw presets onto the generic Agent local command contract without adding provider-specific UI or custom command support.

## Requirements

- Probe whether `hermes` and `openclaw` commands are available.
- Mark Hermes/OpenClaw presets available only when their command exists.
- Keep both adapters on the same argv contract: `<provider-command> --prompt <prompt-text>`.
- Preserve persisted `agent.providerId` behavior.
- Do not add custom provider commands or free-form command UI.
- Do not add provider-specific panels or UI branches.

## Acceptance Criteria

- [x] `AgentService` probes Hermes/OpenClaw command availability.
- [x] Preset rows reflect availability from command probes.
- [x] Selecting an unavailable adapter reports unavailable state and does not execute commands.
- [x] Selecting an available adapter sets the generic argv command.
- [x] Existing `AgentExpansionPanel.qml` UI remains generic.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass.

## Technical Notes

- This implements the final current slice from `docs/development-plan.md`.
- Availability probing can use a service-owned shell probe, but prompt execution must remain argv-array only.

## Verification

- `git diff --check`: passed
- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`
