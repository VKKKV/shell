# Future Support Backlog

## Niri Keyboard And Keybind Parity

Keep this outside the current correctness/security MVP. It should become a separate compatibility task after the current phase is complete.

### Goal

Validate and harden keyboard layout and keybind telemetry for Niri without regressing the existing Hyprland path.

### Candidate Scope

* Verify real output from `niri msg keyboard-layouts` in a Niri session.
* Verify whether `niri msg binds` is available in the target Niri version and what payload shape it returns.
* Update `services/KeyboardService.qml` parsing if the current normalization does not match real Niri output.
* Update `services/KeybindService.qml` parsing if the current Hyprland-oriented bind mapping does not match real Niri output.
* Add manual validation notes to `docs/niri.md`.

### Acceptance Criteria

* [ ] In a Niri session, keyboard layout status reports a real active layout instead of fallback when Niri exposes it.
* [ ] In a Niri session, keybind rows either show parsed binds or a clear unsupported/fallback status.
* [ ] Outside Niri, services remain no-op safe and do not emit QML errors.
* [ ] Hyprland keyboard/keybind behavior remains unchanged.

### Notes

* Current code already chooses Niri commands when `CompositorService.niriActive` is true.
* This still needs runtime validation against real Niri IPC output.
