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
- Earth candidate review workflow: added a local-only candidate manifest convention plus validator so Natural Earth replacement candidates can be checked for provenance, inspection stats, and smoke-test evidence without committing large generated data.
- Earth Natural Earth coastline replacement: replaced the hand-authored transitional coastlines with reviewed Natural Earth 50m public-domain vectors generated through the local candidate workflow, yielding 1,425 polylines and 28,853 runtime points while keeping raw downloads out of the repo.
- Earth compact rendering optimization: tuned the Canvas2D globe frame/rim alignment, hid clip-edge seams with an inner rim, and added compact-mode coastline/texture budgets so the left panel no longer repaints every Natural Earth point at full expanded detail.
- Earth procedural fidelity budget: added expanded-only bathymetry/ridge scan passes and budgeted land relief strokes while preserving compact-mode sparse texture/detail sampling and the Natural Earth 50m runtime dataset.
- Earth procedural visual refinement: cleaned up expanded-only bathymetry budgets, renamed coastline-sampled land detail as coastal relief, added expanded coastline stroke hierarchy, tuned relief thresholds, and polished the atmospheric rim/terminator while keeping compact rendering lower-budget.
- Left-panel shell self-performance module: added a service-owned `/proc` sampler for the Quickshell process plus direct child helpers and surfaced compact CPU, RSS, child count, uptime, and recent service health rows in the left panel.
- Launcher input bar: added a compact top-bar launcher surface with `Ctrl+Space` focus, Escape dismissal, service-owned selection/activation helpers, and filtered actions/apps/calculator result rendering while preserving command-center search.
- Nixie image-based background glow: kept the backdrop default-off, switched the Nixie presentation to per-character local image assets, and added a safe selectable `tianji` background placeholder for future visual work.

### Next Slices

1. Earth globe high-precision coastline and procedural terrain upgrade
    - Optional next data slice: evaluate Natural Earth 10m under the same candidate workflow if 50m coastline detail is still insufficient; validate the manifest with `tools/validate-coastline-candidate.js --check-output` and replace runtime data only after inspector stats and smoke checks show acceptable Canvas repaint behavior.
    - Keep all map data offline at runtime and commit only approved compact JS modules rather than raw downloads or temporary generated artifacts.
    - Further refine the procedural Canvas2D layers only as profiling or visible artifacts justify it: compare the 50m coastline hierarchy against visible artifacts, consider true interior terrain sampling only as a bounded offline/runtime pass, and keep the existing tactical grid, signal nodes, and location markers stable; keep expanded mode rich while compact/left-panel mode uses a bounded polyline/point budget.
    - Reference Natural Earth data, D3 geo projection math, and `world-map-gen` for projection/data-pipeline ideas without introducing runtime network dependencies.
    - Expected trade-off: medium difficulty, mainly data preprocessing and render-pipeline splitting; larger embedded data around 200KB compressed; procedural noise approximates terrain instead of using real land textures.
2. Shell self-performance follow-up
   - Consider frame/render cadence or QML profiler-derived signals only after the `/proc` MVP has runtime evidence that they are needed.
   - Keep any deeper helper attribution behind `ShellPerformanceService`; recursive process-tree aggregation and per-child drilldowns remain out of scope until requested.
   - Validate idle CPU behavior after longer shell sessions and tune polling only from measured repaint/process cost.
3. Launcher follow-up polish
   - Consider result ranking/fuzzy matching, provider ordering, launcher history/favorites, and broader provider configuration only after the first top-bar launcher has runtime use evidence.
   - Keep follow-up work inside `LauncherService` contracts so the command center and compact bar continue to share query/result/activation behavior.
4. Screenshot bottom surface
    - Add a bottom-positioned screenshot capture surface as a separate vertical slice, with capture command probing/execution isolated in a service and the module limited to shaped status, actions, and preview/fallback presentation.
    - First slice should support a minimal capture action and readable unavailable/denied/failed states for missing tools, portals, or permissions; defer annotation tools, history/gallery persistence, upload/share flows, and configurable save destinations.
    - Verification should include QML lint, startup smoke, missing-command fallback smoke where feasible, and manual confirmation that the bottom surface stays within reserved HUD geometry and does not interfere with existing central expansion panels.
5. OpenClaw CLI contract discovery (deferred until the end of this sequence and until a local validation environment exists)
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
