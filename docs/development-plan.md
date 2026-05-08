# Development Plan

This document keeps the active development plan aligned with the codebase's current slice size.

## Slice Granularity

Use one independently verifiable vertical slice per task.

Each slice should include:

- a single user-visible or architecture-visible outcome
- explicit files or boundaries likely to change
- fallback/error behavior if external commands or optional services are involved
- verification commands before commit

Avoid mixing these in the same task:

- broad refactors plus feature behavior
- settings persistence plus first UI prototype
- provider command execution plus provider settings persistence
- visual polish plus external integration unless one directly validates the other

## Current Agent Track

### Completed

- Provider contract plan: defined the local command MVP, failure matrix, and service/module boundaries.
- Agent service scaffold: added importable `AgentService` state and wired the Agent panel to shaped service state without command execution.
- Agent prompt surface: added a staged prompt input that routes submit intent to `AgentService.submit()` while command execution remains blocked.
- Agent local command execution MVP: added a non-persistent argv provider command path in `AgentService.qml`, disabled by default, with shaped unavailable/busy/failed/timeout/ok states.
- Agent provider session config: added session-local provider presets for disabled, Hermes, and OpenClaw without settings persistence.
- Agent provider persistence contract: persists only `agent.providerId` (`disabled`, `hermes`, `openclaw`) while keeping commands and custom providers out of persisted settings.
- Hermes/OpenClaw adapter mapping: probes local command availability and maps available adapters onto the generic argv `--prompt` contract without provider-specific UI.
- Agent adapter polish and race fixes: gates persisted provider application on probe completion, updates stale Agent panel copy, and replaces duplicate planned rows with live availability rows.
- Agent Hermes CLI contract mapping: replaces `hermes agent` with the real `hermes --oneshot` contract and switches prompt delivery to positional argv.
- Earth globe optimization: extracted the transitional 110m-style offline coastline vectors into a static JS module and added horizontal drag-to-rotate longitude control; future Natural Earth 110m preprocessing can replace the dataset without runtime fetching.

### Next Slices

1. OpenClaw CLI contract discovery (deferred until a local validation environment exists)
   - Find the real OpenClaw CLI entry point and map it to the generic contract.
   - Keep missing-command and unvalidated-adapter fallback language until the contract is confirmed.

## Review Findings

### Agent adapter mapping review 2026-05-08

- P1: `AgentService` applies the persisted provider before probe results are known; fix with probe completion gating or by applying only after probe completion.
- P2: Agent panel footer and submit tooltip still describe provider execution as disabled/staged; update copy to reflect persisted provider selection and conditional command execution.
- P3: Agent panel provider metric rows still include static `HERMES`/`OPENCLAW` planned rows even though live preset rows now exist; remove duplication or show live availability.
- P4: Hermes CLI uses `hermes chat`/`hermes -z`, not `hermes agent --prompt`; runtime validation must map the actual CLI contract before the adapter is considered correct.
- Deferred: provider preset factory extraction is unnecessary while only three presets exist.
- Deferred: refresh/debounced re-probing can wait until runtime provider installation is an explicit workflow.

## Backlog Guardrails

- Polling framework extraction is deferred until at least one more service needs non-trivial polling lifecycle changes.
- SettingsService decomposition is deferred until a behavior-preserving split has tests around persistence and normalization.
- Canvas performance optimization should be driven by visible warnings, profiling, or user-reported performance issues.
- Multi-monitor, plugin, and lazy-loading work require explicit product requirements before implementation.
