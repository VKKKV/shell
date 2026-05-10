# Nixie Background Image-Based Glow

## Goal

Replace the current drawn/rectangle-heavy Nixie background approach with a more realistic image-based vacuum tube presentation inspired by DivergenceMeter's digit-image switching model. The background should remain optional/default-off behind `SettingsService.backgroundMode === "nixie"`, but when enabled it should look like a photographic or pre-rendered nixie/vacuum tube display instead of hand-drawn QML line art.

## What I Already Know

* User wants OpenClaw CLI work deferred to the end of the sequence, then development should proceed in order.
* User specifically called out `../DivergenceMeter/` as the reference for how to implement the glow-tube effect.
* `../DivergenceMeter/Website/divergence_meter.js` implements the display by creating one image element per character and switching image sources: `0.png` through `9.png`, `p.png` for the dot, and `11.gif`/`12.gif` for animation.
* Existing shell code already has `components/NixieWallpaper.qml`, `modules/hud/NixieBackgroundWindow.qml`, `assets/nixie/0.png` through `9.png`, and `assets/nixie/p.png`.
* Current `NixieWallpaper.qml` still draws much of the tube casing/glow with QML rectangles and a Canvas backdrop, which is the part that looks unrealistic.
* `DivergenceMeter` is GPLv3 and credits `LuqueDaniel/Divergence-Meter` for images/GIFs, so asset reuse needs explicit license/provenance checking before copying anything.
* The current shell repository is also GPLv3, but visual fit and upstream asset provenance still matter.

## Assumptions

* The implementation should learn the image-switching architecture from DivergenceMeter, not blindly copy assets unless their license and visual fit are acceptable.
* The first implementation can reuse the existing `assets/nixie/*.png` if they are already suitable, but should stop constructing fake tubes from QML rectangles.
* If existing assets only contain digit glyphs without a tube/glass body, the better plan is to add a small, documented image asset set rather than drawing tubes manually.
* The Nixie layer remains default-off and controlled from the existing settings panel.

## Requirements

* Defer OpenClaw CLI contract discovery to the end of the development plan sequence.
* Replace the Nixie background visual strategy with an image-first architecture.
* Keep time/value display as per-character image switching, matching the DivergenceMeter model conceptually.
* Avoid hand-drawn tube bodies, wire lines, fake casing rectangles, and QML line-art pretending to be glass/tubes.
* Preserve the existing settings contract: `visual.backgroundMode` values remain `void`, `grid`, `radar`, and `nixie`.
* Add a new background settings option named `tianji`; its concrete visual implementation is intentionally deferred.
* Ensure `tianji` is a safe selectable/persistable mode with no runtime breakage even before its dedicated background implementation exists.
* Preserve the background layer behavior in `NixieBackgroundWindow.qml` and keep the layer non-interactive.
* Keep the implementation offline and local; no runtime fetching of digit assets.
* Document asset provenance if any new image/GIF assets are added.

## Acceptance Criteria

* [ ] Development plan order is updated so OpenClaw is last.
* [ ] Background settings include a selectable `tianji` option whose implementation is marked/deferred safely.
* [ ] `NixieWallpaper.qml` no longer relies on QML rectangle/line art for the visible tube/glass body.
* [ ] Nixie digits/dots are rendered as switched image assets per character.
* [ ] The optional Nixie background still toggles via existing `backgroundMode === "nixie"` settings.
* [ ] No runtime network dependency is introduced.
* [ ] Any added assets have clear provenance/licensing notes.
* [ ] QML verification runs for changed QML files where available.
* [ ] `git diff --check` passes.

## Technical Approach

Recommended direction: implement an image-first `NixieWallpaper` that treats each visible character as an `Image` slot. Use QML only for layout, opacity, subtle global glow/noise, and optional background falloff; do not synthesize the tube body with rectangles. If a full tube image set is available, each digit image should include the tube/glass/glow composition. If only glyph images are available, add or generate a proper tube-backed asset set before changing the QML.

Likely implementation slices:

1. Update `docs/development-plan.md` so OpenClaw CLI discovery is last, then list the Nixie image-based background before subsequent visual/data follow-ups.
2. Extend background mode normalization/settings UI to include `tianji`, with copy indicating implementation is pending/deferred.
3. Audit current `assets/nixie` dimensions/content and decide whether they are full tube assets or glyph-only assets.
4. Refactor `components/NixieWallpaper.qml` into an image-slot layout inspired by DivergenceMeter: per-character `Image`, dot image, optional loading/flicker frame if assets exist.
5. Remove fake tube rectangles/wires/casing from `NixieWallpaper.qml`, keeping only a minimal dark photographic-style background/glow layer if needed.
6. Add asset provenance notes if new assets are introduced.

## Decision (ADR-lite)

**Context**: The hand-drawn QML tube background is not realistic enough. DivergenceMeter demonstrates that a convincing divergence/nixie display comes primarily from pre-rendered PNG/GIF digit assets switched per slot.

**Decision**: Prefer image switching over QML-drawn tube geometry. QML should orchestrate slots, state, sizing, and subtle global ambience; realism should come from image assets.

**Consequences**: Visual quality depends on asset quality and provenance. The QML becomes simpler and more faithful, but a good implementation may require adding or replacing image assets rather than drawing more shapes.

## Out Of Scope

* OpenClaw implementation in this task.
* Implementing the actual `tianji` visual background beyond safe settings availability.
* Runtime downloading of images.
* Wallpaper scan/apply changes.
* Reworking settings persistence values.
* Building a full animation system unless suitable GIF/frame assets are available.

## Technical Notes

* Existing Nixie component: `components/NixieWallpaper.qml`.
* Existing layer window: `modules/hud/NixieBackgroundWindow.qml`.
* Existing settings UI: `modules/hud/CommandCenterSettingsColumn.qml`.
* Existing assets: `assets/nixie/0.png` through `9.png`, `assets/nixie/p.png`.
* DivergenceMeter reference: `../DivergenceMeter/Website/divergence_meter.js`.
* DivergenceMeter images: `../DivergenceMeter/Website/images/0.png` through `9.png`, `p.png`, `11.gif`, `12.gif`.
* DivergenceMeter license: `../DivergenceMeter/LICENSE` is GPLv3; README credits another upstream for images/GIFs.

## Implementation Note

* Current `assets/nixie/*.png` files are 130x384 tube-backed images, so this slice can use the existing local assets without adding new binary assets or provenance documents.
* Keep the backdrop behind PNG tube assets pure black (`#000000`); avoid red/orange/gray glow, gradients, or ambient color that exposes image borders.
