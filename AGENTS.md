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

Use the `/trellis:start` command when starting a new session to:
- Initialize your developer identity
- Understand current project context
- Read relevant guidelines

Use `@/.trellis/` to learn:
- Development workflow (`workflow.md`)
- Project structure guidelines (`spec/`)
- Developer workspace (`workspace/`)

If you're using Codex, project-scoped helpers may also live in:
- `.agents/skills/` for reusable Trellis skills
- `.codex/agents/` for optional custom subagents

Keep this managed block so 'trellis update' can refresh the instructions.

<!-- TRELLIS:END -->
