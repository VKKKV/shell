# agent service scaffold

## Goal

Add the first `AgentService` scaffold so the Agent panel can read real shaped service state while provider command execution remains disabled by default.

## Requirements

- Add `services/AgentService.qml` as a singleton service.
- Register `AgentService` in `services/qmldir`.
- Expose provider status fields for the Agent panel: provider name, state, status line, response text, and error detail.
- Keep command execution disabled by default; no provider process should start in this slice.
- Update `AgentExpansionPanel.qml` to read service state instead of hard-coded provider status where appropriate.

## Acceptance Criteria

- [x] `AgentService` is importable as a singleton.
- [x] Agent panel status reflects `AgentService` state.
- [x] Default state clearly says provider execution is disabled/unconfigured.
- [x] No command execution or settings persistence is introduced.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass.

## Technical Notes

- Follow the contract from `.trellis/tasks/05-08-agent-provider-contract-plan/prd.md`.
- Keep all provider/process logic in `services/`.
- `components/NeuralMeshSphere.qml` stays presentation-only.

## Verification

- `git diff --check`: passed
- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`
