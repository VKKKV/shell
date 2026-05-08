# agent provider contract plan

## Goal

Define the first real Agent provider contract before turning the staged Agent UI into an executable provider surface.

## Requirements

- Keep the current Agent UI visual-only until a provider contract is explicit.
- Define the minimum command/API shape for a local provider-backed agent interaction.
- Identify what belongs in QML services versus settings persistence versus provider process execution.
- Define fallback/error behavior so failed providers do not render blank panels or raw stderr.
- Avoid adding hidden command execution, persisted provider settings, or IPC in this planning slice.

## Proposed MVP Contract

- Provider type: generic local command provider only for the first implementation slice.
- Hermes/OpenClaw status: planned adapters, not implemented in MVP unless they can be expressed through the same local command contract.
- Custom provider status: out of scope until an allowlist and validation contract exists.
- Input: a single text prompt plus optional context lines assembled by a future `AgentService.qml`.
- Output: final response text on stdout; stderr is diagnostic-only and must never render raw as normal UI.
- Streaming: out of scope for MVP; future work may add incremental line capture after one-shot behavior is stable.
- Timeout: provider process should fail safe after a bounded timeout; proposed first value is 30 seconds.
- Invocation boundary: provider commands must live in a service, not in `components/` or `modules/hud/`.
- Persistence boundary: no provider config is persisted until the command allowlist, fields, and validation behavior are documented.

## Command Signature

First implementation should support exactly one configured command shape:

```text
<provider-command> --prompt <prompt-text>
```

Rules:

- `prompt-text` is passed as one argument, not shell-interpolated.
- Commands are represented as an argv array in QML `Process.command`, never as user-controlled shell text.
- The service owns process state: `idle`, `running`, `ok`, `failed`, `timeout`, `unavailable`.
- The service owns display shaping: `providerName`, `statusLine`, `responseText`, `errorDetail`.
- UI modules can request submission through a service method, but cannot mutate `Process.command` directly.

## Failure Matrix

- Provider command missing -> state `unavailable`, response remains previous or empty, status line shows command missing.
- Non-zero exit -> state `failed`, response remains previous or empty, stderr summarized into `errorDetail` only.
- Timeout -> state `timeout`, process stopped if supported, status line shows timeout.
- Empty stdout with zero exit -> state `failed`, status line shows empty response.
- New request while running -> reject with status `agent: busy` for MVP; queueing is out of scope.

## Files For First Implementation Slice

- Add `services/AgentService.qml` for provider state, command invocation, timeout, and fallback text.
- Update `modules/hud/AgentExpansionPanel.qml` to read `AgentService` state and expose a prompt entry only after the service exists.
- Keep `components/NeuralMeshSphere.qml` visual-only; it should receive label/status props only.
- Do not update `SettingsService.qml` until provider persistence fields are accepted.

## Acceptance Criteria

- [x] The contract states whether Hermes/OpenClaw/custom providers are implemented, planned, or out of scope.
- [x] The contract defines command signature, input fields, output expectations, timeout, and failure behavior.
- [x] The plan identifies the QML service/module files likely needed for implementation.
- [x] The plan explicitly preserves the existing staged Agent UI until implementation begins.
- [x] No QML code starts provider commands in this slice.

## Technical Notes

- Relevant current files: `modules/hud/AgentExpansionPanel.qml`, `components/NeuralMeshSphere.qml`, `services/SettingsService.qml`.
- Existing guidelines require external command execution to stay in `services/`, with modules composing shaped state.
- This is intentionally a planning/spec slice; implementation should follow as a separate task after the contract is accepted.

## Open Questions

- Resolved: first real provider should be a generic local command contract.
- Resolved: provider selection should not be persisted until the command contract is proven.
- Resolved: first interaction should be one-shot request/response; streaming is out of scope for MVP.

## Verification

- `git diff --check`: pending
- Documentation-only planning slice; QML runtime checks are not required unless code changes are added.
