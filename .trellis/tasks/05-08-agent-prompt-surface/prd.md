# agent prompt surface

## Goal

Add a small prompt surface to the Agent panel and route submit intent to `AgentService.submit()` while provider command execution remains blocked.

## Requirements

- Add a compact prompt input to `modules/hud/AgentExpansionPanel.qml`.
- Route Enter/click submit to `AgentService.submit(prompt)`.
- Keep empty prompts ignored.
- Keep provider execution disabled; this slice must not add `Process` usage or settings persistence.
- Display the blocked-provider response through existing `AgentService` state.

## Acceptance Criteria

- [x] Agent panel includes a prompt input and submit affordance.
- [x] Submit calls `AgentService.submit()` with non-empty prompt text.
- [x] `AgentService.submit()` updates shaped status/response state without executing commands.
- [x] No provider command, shell interpolation, or settings persistence is introduced.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass.

## Technical Notes

- This implements slice 1 from `docs/development-plan.md`.
- Keep `components/NeuralMeshSphere.qml` presentation-only.

## Verification

- `git diff --check`: passed
- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`
