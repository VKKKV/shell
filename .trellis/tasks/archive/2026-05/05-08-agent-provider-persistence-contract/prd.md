# agent provider persistence contract

## Goal

Persist the selected Agent provider preset safely by storing only a validated provider id, not provider command argv or custom commands.

## Requirements

- Add `agent.providerId` to the settings contract.
- Allowed values: `disabled`, `hermes`, `openclaw`.
- Default value: `disabled`.
- Update `SettingsService.qml`, `src/settings/main.zig`, and `docs/settings.md` together.
- Add Zig normalization tests for valid and invalid provider ids.
- Wire `AgentService` to initialize from and save to `SettingsService.agentProviderId`.
- Do not persist provider argv arrays or free-form command strings.

## Acceptance Criteria

- [x] `void-shell-settings defaults` includes `agent.providerId: "disabled"`.
- [x] Zig normalization preserves valid provider ids and falls back invalid ids to `disabled`.
- [x] QML settings payload includes normalized `agent.providerId`.
- [x] `AgentService.selectProvider()` updates the persisted provider id.
- [x] Startup applies the persisted provider id to `AgentService` without executing a command.
- [x] `zig build test`, `zig build`, `qmllint`, `git diff --check`, and `quickshell -p .` pass.

## Technical Notes

- This implements the persistence contract from `docs/development-plan.md`.
- Persisting command argv or custom providers remains out of scope until an allowlist exists.

## Verification

- `git diff --check`: passed
- `zig build test`: passed
- `zig build`: passed
- `./zig-out/bin/void-shell-settings defaults`: passed; output includes `agent.providerId: "disabled"`
- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`
