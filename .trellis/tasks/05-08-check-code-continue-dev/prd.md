# brainstorm: check code and continue dev

## Goal

Inspect the current shell codebase after the HUD/background work, fix the new runtime warning, and continue polishing the nixie wallpaper and bottom active-window layout.

## What I already know

* The previous HUD layout, Agent visual panel, Earth globe, nixie background, and sparse-panel density work has been implemented, verified, committed, pushed, and archived.
* Trellis currently has no active task after archiving completed work.
* The user wants to check code and continue development rather than stop at task cleanup.
* Current git status is clean except for this brainstorm task directory.
* Recent work added `NixieWallpaper`, `AgentExpansionPanel`, `NeuralMeshSphere`, `backgroundMode: "nixie"`, and the persistent background mode code-spec.
* Placeholder/deferred areas remain in Agent provider integration, network connection flows/Wi-Fi auth, log tail/persistent journal, and filesystem mount actions.
* `docs/settings.md` has an existing JSON indentation/readability issue in the example shape.
* User reports `NeuralMeshSphere.qml` warns: `TypeError: Cannot read property 'requestPaint' of undefined` at hover/position handlers.
* User reports the nixie wallpaper looks too far from the DivergenceMeter reference and asks whether interactive wallpaper motion effects are possible.
* User reports the bottom active-window module still should be centered.

## Assumptions (temporary)

* The next work should build on the current shell direction rather than start unrelated infrastructure.
* Because no concrete next feature was specified, this is a requirements discovery task.

## Open Questions

* None blocking this slice.

## Requirements (evolving)

* Inspect current code and project state before asking for user decisions.
* Identify concrete next-step options grounded in existing files and recent work.
* Prefer small, independently verifiable development slices.
* Fix the `NeuralMeshSphere` `requestPaint` runtime warning.
* Rework the bottom active-window dock so it is visually centered in the bottom panel row.
* Improve `NixieWallpaper` to look closer to the DivergenceMeter-style tube display: separate tube bodies, stronger amber glow, glass outlines, and darker enclosure.
* Add local interaction/motion effects for the nixie wallpaper where feasible without external commands/assets.

## Acceptance Criteria (evolving)

* [x] Current code/task/git state is inspected.
* [x] 2-3 feasible next development options are proposed with trade-offs.
* [x] MVP scope is selected before implementation.
* [x] If implementation proceeds, checks pass and changes are committed/pushed per project workflow.
* [x] `timeout 8s quickshell -p .` no longer shows `NeuralMeshSphere.qml` requestPaint warnings.
* [x] Nixie background has more tube-like visual structure and visible interaction/motion affordance.
* [x] Bottom active-window dock is centered rather than visually left-weighted.

## Definition of Done (team quality bar)

* Tests added/updated where appropriate.
* Lint / typecheck / smoke checks green.
* Docs/notes updated if behavior changes.
* Rollout/rollback considered if risky.

## Out of Scope (explicit)

* Large rewrites without a selected MVP.
* Real Agent backend integration unless explicitly selected and contracted.
* Copying external assets without licensing/fit review.
* Adding a true `WlrLayer.Background` wallpaper window in this slice.

## Technical Notes

* Inspected: `components/NixieWallpaper.qml`, `components/NeuralMeshSphere.qml`, `modules/hud/AgentExpansionPanel.qml`, `modules/hud/NetworkExpansionPanel.qml`, `modules/hud/LogExpansionPanel.qml`, `docs/settings.md`, recent commits, TODO/deferred markers.
* No obvious broken code path was found from static inspection; next work should be a chosen feature/cleanup slice.
* Selected slice from user: Nixie wallpaper polish + bottom dock centering + NeuralMeshSphere warning fix.
* True mouse interaction for the full-screen wallpaper is not included in this slice because `HudWindow` uses an input `mask` to keep background areas click-through; adding a full-screen `MouseArea` would either be ineffective outside input regions or risk blocking desktop clicks.
* Implemented safe passive motion instead: tube glow breathing, animated backdrop, and subtle parallax drift without changing input regions.

## Verification

* `git diff --check`: passed
* `zig build`: passed
* `qmllint shell.qml components/*.qml modules/hud/*.qml services/*.qml theme/Theme.qml`: passed
* `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded` and no `NeuralMeshSphere.qml requestPaint` warnings were observed

## Research Notes

### What similar shell/UI workflows imply

* New visual features should be hardened with settings docs, runtime smoke checks, and rollback/default-off behavior.
* Placeholder UI should not grow into fake functionality; either keep it clearly staged or define a real contract.
* Background/wallpaper effects should stay opt-in and avoid external assets/commands unless explicitly contracted.

### Constraints from this repo/project

* Persistent settings changes must update QML state, Zig helper normalization/tests, and `docs/settings.md` together.
* Visual components in `components/` should remain presentation-only.
* Real Agent integration would be cross-layer and requires provider command/API signatures before implementation.
* Network actions are already serialized in service code, but Wi-Fi auth/connection flows remain explicitly out of scope in UI.

### Feasible approaches here

**Approach A: Nixie Wallpaper Polish** (Recommended)

* How it works: improve `NixieWallpaper.qml` with a more tube-like frame, segment depth/glow, optional date/worldline-style text, and maybe a settings docs cleanup.
* Pros: builds directly on the newest feature, low cross-layer risk, highly visible improvement.
* Cons: mostly visual; does not unlock backend/agent capability.

**Approach B: Agent Provider Contract Brainstorm**

* How it works: define real Hermes/OpenClaw/custom provider contracts, settings schema, and MVP interaction flow before implementation.
* Pros: turns placeholder Agent UI into a real feature path.
* Cons: higher ambiguity and cross-layer risk; should not implement until provider command/API details are clear.

**Approach C: Documentation/Settings Contract Cleanup**

* How it works: clean `docs/settings.md` JSON shape, add missing examples for `nixie`, and tighten helper contract docs/tests.
* Pros: small, safe, improves future maintainability.
* Cons: low user-visible impact.

## Expansion Sweep

### Future evolution

* Nixie background could later become a true `WlrLayer.Background` window or support multiple styles/intensity presets.
* Agent panel could evolve from visual-only into a provider-backed interaction surface with command/WebSocket contracts.

### Related scenarios

* Any new persistent visual setting must stay consistent across settings panel, `SettingsService`, Zig helper, docs, and code-spec.
* Any external reference project should remain inspiration-only unless license and asset fit are checked.

### Failure & edge cases

* Visual effects must remain default-off or safely degradable to avoid startup/readability regressions.
* Provider integrations must avoid hidden command execution until command/API and error behavior are explicit.
