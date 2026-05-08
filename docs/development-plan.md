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
- Nixie background settings polish: made the optional/default-off Nixie backdrop easier to discover in command-center settings while keeping it separate from wallpaper scan/apply actions and preserving the existing `visual.backgroundMode` values.
- Earth coastline preprocessing scaffold: added a dependency-free offline GeoJSON-to-QML/JS converter plus a tiny fixture and docs while keeping the active runtime coastline module unchanged.
- Earth procedural terrain prototype: added Canvas2D ocean depth texture, clipped land terrain hints, and atmospheric rim glow while preserving the existing offline coastline data and tactical HUD interactions.
- Earth generated coastline evaluation support: added a dependency-free inspector for generated coastline modules and a Natural Earth review checklist covering source/version/license, generation commands, stats, thresholds, and smoke checks before runtime data replacement.

### Next Slices

1. OpenClaw CLI contract discovery (deferred until a local validation environment exists)
   - Find the real OpenClaw CLI entry point and map it to the generic contract.
   - Keep missing-command and unvalidated-adapter fallback language until the contract is confirmed.
2. Earth globe high-precision coastline and procedural terrain upgrade
   - Run the documented preprocessing and inspection pipeline against reviewed Natural Earth 10m coastline GeoJSON, then replace the current hand-authored/transitional coastline polylines with generated data targeting 10K+ coordinate points while keeping all data offline.
   - Record source URL/version/license notes, generation command, inspector output, and size/performance review before checking in the generated QML/JS coordinate arrays.
   - Refine the new procedural Canvas2D layers around generated data: tune ocean depth hash density, clipped terrain hints, high-precision coastline strokes, atmospheric rim glow, and the existing tactical grid, signal nodes, and location markers.
   - Reference Natural Earth data, D3 geo projection math, and `world-map-gen` for projection/data-pipeline ideas without introducing runtime network dependencies.
   - Expected trade-off: medium difficulty, mainly data preprocessing and render-pipeline splitting; larger embedded data around 200KB compressed; procedural noise approximates terrain instead of using real land textures.

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
