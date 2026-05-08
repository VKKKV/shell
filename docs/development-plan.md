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

### Next Slices

1. Hermes/OpenClaw adapter mapping
   - Map each adapter onto the generic local command contract.
   - Do not add provider-specific UI until the generic contract works.
   - Keep custom providers out of scope until an allowlist is defined.

## Backlog Guardrails

- Polling framework extraction is deferred until at least one more service needs non-trivial polling lifecycle changes.
- SettingsService decomposition is deferred until a behavior-preserving split has tests around persistence and normalization.
- Canvas performance optimization should be driven by visible warnings, profiling, or user-reported performance issues.
- Multi-monitor, plugin, and lazy-loading work require explicit product requirements before implementation.
