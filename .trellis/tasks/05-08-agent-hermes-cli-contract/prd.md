# agent hermes cli contract

## Goal

Map the Hermes provider preset to the real Hermes CLI contract discovered during runtime validation, replacing the incorrect `hermes agent` subcommand.

## Requirements

- Replace Hermes preset command from `["hermes", "agent"]` to `["hermes", "--oneshot"]`.
- Hermes `--oneshot` takes the prompt as a positional argument, not via `--prompt`.
- Keep OpenClaw preset unchanged until its CLI contract is confirmed.
- Update Hermes preset detail text to reflect oneshot mode.
- Keep custom providers out of scope.

## Acceptance Criteria

- [x] Hermes preset command is `["hermes", "--oneshot"]`.
- [x] `AgentService.submit()` passes prompt text as the final positional argument after `--oneshot`.
- [x] Preset detail text describes the oneshot mode.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass.

## Verification

- `git diff --check`: passed
- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`

## Technical Notes

- Hermes CLI docs at https://hermes-agent.nousresearch.com/docs
- `hermes --oneshot <prompt>` prints only the final response text to stdout; no banner, spinner, or tool previews.
- This implements P4 from `docs/development-plan.md` review findings.
