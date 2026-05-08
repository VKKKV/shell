使用quickshell开发一个具有如图效果的shell

![target](./target.png)

quickshell
https://quickshell.org/docs/v0.3.0/
https://github.com/quickshell-mirror/quickshell

zig docs
https://ziglang.org/documentation/master/

shell based on quickshell

https://github.com/caelestia-dots/shell
../caelestia/

https://github.com/noctalia-dev/noctalia-shell
../noctalia-shell/

https://github.com/AvengeMedia/DankMaterialShell
../DankMaterialShell/

nixie/vacuum tube wallpaper reference

https://github.com/FrancescoCaracciolo/DivergenceMeter
../DivergenceMeter/

Notes:
- Quickshell v0.3.0 supports `PanelWindow`; Wayland layer-shell can place windows on `WlrLayer.Background`, but the current implementation first uses the existing HUD background layer via `SettingsService.backgroundMode`.
- DivergenceMeter provides digit image/animation inspiration in `../DivergenceMeter/Website/images/` and update logic in `../DivergenceMeter/Website/divergence_meter.js`; do not copy assets blindly without checking licensing/fit.
- The first nixie/vacuum tube clock background should default off and be enabled from the settings panel.
<!-- TRELLIS:START -->
# Trellis Instructions

These instructions are for AI assistants working in this project.

This project is managed by Trellis. The working knowledge you need lives under `.trellis/`:

- `.trellis/workflow.md` — development phases, when to create tasks, skill routing
- `.trellis/spec/` — package- and layer-scoped coding guidelines (read before writing code in a given layer)
- `.trellis/workspace/` — per-developer journals and session traces
- `.trellis/tasks/` — active and archived tasks (PRDs, research, jsonl context)

If a Trellis command is available on your platform (e.g. `/trellis:finish-work`, `/trellis:continue`), prefer it over manual steps. Not every platform exposes every command.

If you're using Codex or another agent-capable tool, additional project-scoped helpers may live in:
- `.agents/skills/` — reusable Trellis skills
- `.codex/agents/` — optional custom subagents

Managed by Trellis. Edits outside this block are preserved; edits inside may be overwritten by a future `trellis update`.

<!-- TRELLIS:END -->
