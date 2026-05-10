# Update README Screenshot Demo Placeholders

## Goal

Update `README.md` so it reflects the current shell implementation and includes a screenshot/demo section with descriptive text plus empty image placeholders for the user to fill later.

## What I Already Know

* User wants to stop continuing the development plan and update docs such as `README.md`.
* User plans to add several screenshots to the demo section later, so README should include text and placeholder image references without requiring actual images now.
* Current `README.md` still references older progress screenshots and does not mention recent features like the Natural Earth Earth panel, shell self-performance readout, or top-bar launcher input.
* `docs/development-plan.md` is current enough to identify completed features and future slices.
* Existing assets are mostly nixie digit images; there is no obvious screenshot asset directory yet.

## Assumptions

* Do not create binary screenshot files in this task.
* Use Markdown image placeholders that point to future files under a clear path such as `docs/screenshots/*.png`.
* Keep README concise and project-facing rather than turning it into a full manual.
* Verification for this docs-only slice is `git diff --check`.

## Requirements

* Update README overview/features to match the current project state.
* Add a screenshot/demo section with multiple named placeholders and short descriptions.
* Leave image paths empty of actual files but clear enough for the user to add screenshots later.
* Mention key current surfaces: top bar launcher, command center, left/right telemetry, Earth panel, shell self-performance readout, settings/background controls, tray/media/network/system monitoring.
* Keep existing setup/run/troubleshooting guidance accurate.
* Do not change QML code or add assets.

## Acceptance Criteria

* [ ] README no longer undersells current implemented features.
* [ ] README includes a screenshot/demo section with several future image placeholders and descriptive text.
* [ ] Placeholder image paths are stable and obvious for later screenshot insertion.
* [ ] README controls mention `Ctrl+Space` top-bar launcher and existing `Ctrl+Alt+S` command center.
* [ ] No binary image files are added.
* [ ] `git diff --check` passes.

## Definition Of Done

* README is updated and whitespace-checked.
* Task is checked before commit.
* Commit/push can happen after review.

## Technical Approach

Revise `README.md` in place. Add a `## Screenshot Demo` or similar section near visual progress, with placeholders such as:

* `docs/screenshots/01-main-hud.png`
* `docs/screenshots/02-command-center.png`
* `docs/screenshots/03-earth-panel.png`
* `docs/screenshots/04-launcher-bar.png`
* `docs/screenshots/05-settings-backgrounds.png`

Use descriptive captions so missing files are easy to fill later. Avoid adding the actual image files or directories unless necessary.

## Out Of Scope

* Capturing screenshots.
* Adding binary assets.
* Changing QML code.
* Reworking docs beyond README alignment.
* Continuing feature development from `docs/development-plan.md`.

## Technical Notes

* README source: `README.md`.
* Feature source of truth: `docs/development-plan.md`.
* Placeholder screenshots should be intentionally missing for now so the user can fill them later.
