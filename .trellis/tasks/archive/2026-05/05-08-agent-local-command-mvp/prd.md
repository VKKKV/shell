# agent local command mvp

## Goal

Implement the first local command execution path inside `AgentService.qml` while keeping it disabled by default and non-persistent.

## Requirements

- Add non-persistent provider command fields inside `AgentService.qml` only.
- Keep command execution disabled unless an in-memory argv array is explicitly configured in code/session state.
- Execute commands as argv arrays through QML `Process.command`; never shell-interpolate prompt text.
- Support one-shot request/response only.
- Implement states: `idle`, `running`, `ok`, `failed`, `timeout`, `unavailable`.
- Reject new prompts while a provider command is running.
- Preserve safe default behavior when no provider command is configured.
- Do not add settings persistence, provider UI configuration, Hermes/OpenClaw adapters, or custom command allowlists in this slice.

## Acceptance Criteria

- [x] Empty prompts are ignored.
- [x] Submit with no provider command yields `unavailable` without starting a process.
- [x] Submit while running yields `agent: busy` without queueing.
- [x] Configured command invocation passes prompt as one argv argument.
- [x] Non-zero exit, empty stdout, and timeout produce shaped fallback state without raw stderr as normal UI.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass.

## Technical Notes

- This implements slice 1 from `docs/development-plan.md`.
- Keep all provider execution in `services/AgentService.qml`.
- `AgentExpansionPanel.qml` should continue reading shaped service state only.

## Verification

- `git diff --check`: passed
- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`
