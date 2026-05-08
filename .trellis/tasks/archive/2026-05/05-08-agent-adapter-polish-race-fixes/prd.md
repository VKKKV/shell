# agent adapter polish race fixes

## Goal

Fix review-identified polish and timing issues in the Agent adapter mapping before continuing provider runtime validation.

## Requirements

- Gate persisted provider application until Hermes/OpenClaw probe results are known.
- Update outdated Agent panel footer and submit tooltip copy.
- Remove duplicate static Hermes/OpenClaw `PLANNED` metric rows or replace them with live availability state.
- Do not add provider-specific UI branches.
- Keep provider preset helper extraction and periodic re-probing out of scope.

## Acceptance Criteria

- [x] Persisted provider selection is applied after probe completion, avoiding initial unavailable flicker.
- [x] Agent panel copy reflects persisted provider selection and conditional command execution.
- [x] Provider metric rows no longer duplicate stale `PLANNED` rows.
- [x] `qmllint`, `git diff --check`, and `quickshell -p .` pass.

## Technical Notes

- Follow `docs/development-plan.md` review findings from 2026-05-08.

## Verification

- `git diff --check`: passed
- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`
