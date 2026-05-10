# Shell

A Quickshell tactical desktop shell for Hyprland and Wayland.

## Overview

This project is a high-contrast tactical HUD shell built with Quickshell/QML. It combines launcher, command-center, telemetry, tray, media, network, settings, and visual background controls into a keyboard-friendly desktop surface.

## Screenshot Demo

Screenshots are intentionally left as future placeholders. Add the image files under `docs/screenshots/` when captures are ready.

### Main HUD
![Main HUD placeholder](docs/screenshots/01-main-hud.png)

Full shell view with the top bar, left/right telemetry panels, central safe area, bottom HUD frame, tray/media/network indicators, and tactical scanline styling.

### Command Center
![Command center placeholder](docs/screenshots/02-command-center.png)

The `Ctrl+Alt+S` command center with system overview, settings/background controls, launcher/search, service status/logs, tray drawer, clipboard, calendar, notifications, keybinds, emoji, media, and power/session actions.

### Earth Panel
![Earth panel placeholder](docs/screenshots/03-earth-panel.png)

Left-panel Natural Earth globe with offline coastline vectors, procedural ocean/terrain hints, atmospheric rim glow, and drag-to-rotate longitude control.

![Orbital panel](docs/screenshots/04-panel.png)

![Nixie vacuum-tube backdrop](docs/screenshots/05-nixie.png)

Optional Nixie/vacuum-tube background with image-based digit glow, kept default-off behind the background mode setting.

## Features

- **Techwear HUD Aesthetic:** Pure-black surfaces, sharp tactical frames, scanlines, gray default accent, and high-density instrument styling.
- **Top-Bar Launcher:** `Ctrl+Space` focuses a compact launcher for apps, actions, calculator expressions via `=<expr>`, and shell commands via `$ <command>`.
- **Command Center:** `Ctrl+Alt+S` opens a unified panel for system overview, settings, launcher/search, service status/logs, tray drawer, clipboard history, calendar, notifications, keybinds, emoji, media, and power/session controls.
- **Left/Right Telemetry:** Adaptive edge panels show live CPU, memory, swap, network, filesystem, power, battery, weather, environment/night-light, service fallback, and shell self-performance telemetry.
- **Earth And Orbital Panels:** The left analog/orbital area opens graphical orbital and Natural Earth globe views with offline coastlines, procedural terrain hints, trails, reticles, and tactical labels.
- **Shell Self-Performance:** Tracks the running Quickshell process with CPU, RSS memory, child helper count, uptime, and recent service health.
- **Settings And Background Controls:** Runtime controls for accent color, theme profile, scanlines, tactical background mode, optional Nixie/vacuum-tube backdrop, font scale, panel visibility, intensity, live data polling, and wallpaper scan/apply/color sampling.
- **Tray, Media, Network, And System Monitoring:** Quickshell tray menu bridging, `wpctl` audio/microphone controls, `playerctl` MPRIS media controls, local spectrum/lyrics fallbacks, `nmcli` network/Wi-Fi actions, VPN-like connection telemetry, and Bluetooth status.
- **Persistence:** Settings are normalized and persisted by the Zig helper `void-shell-settings`.
- **Hyprland & QML:** Built on Quickshell/QML for Hyprland with documented layer-shell/blur integration.
- **Modular Design:** Reusable primitives in `components/`, product surfaces in `modules/hud/`, and external integrations in `services/`.

## Usage

### Install Dependencies

Required:

- Quickshell v0.3.0 or newer
- Hyprland / Wayland session
- Qt/QML modules required by Quickshell
- Zig, for building the settings helper

Recommended runtime tools for full functionality:

- `hyprctl` for workspace, window, keyboard, and keybind telemetry
- `wpctl` for audio and microphone controls
- `playerctl` for MPRIS media controls
- `nmcli` for network, Wi-Fi, and VPN-like connection telemetry/actions
- `bluetoothctl` for Bluetooth power/status telemetry
- `wl-copy` and `wl-paste` for clipboard, emoji, calculator, and keybind template actions
- `curl` for weather telemetry
- `powerprofilesctl` for power profile controls
- `systemd-inhibit` for idle inhibitor control
- `gtk-launch` for desktop app launching
- `dbus-send` for notification server probing
- `swww` or `hyprpaper` for wallpaper application
- `magick` or `convert` for wallpaper color sampling
- `hyprsunset`, `gammastep`, or `redshift` for night-light/environment status detection

Missing optional tools should degrade to fallback status text instead of breaking the shell.

### Build Helper

Build the Zig settings helper from the repository root:

```bash
zig build
```

This creates:

```text
zig-out/bin/void-shell-settings
```

Quick smoke checks:

```bash
./zig-out/bin/void-shell-settings defaults
./zig-out/bin/void-shell-settings read
```

Settings are stored at:

```text
$XDG_CONFIG_HOME/void-shell/settings.json
```

If `XDG_CONFIG_HOME` is unset, the fallback path is:

```text
~/.config/void-shell/settings.json
```

### Run Shell

Run from the repository root:

```bash
quickshell -p .
```

The root QML file uses QApplication mode so tray platform/menu behavior can work with Quickshell:

```qml
//@ pragma UseQApplication
```

Keep this pragma at the top of `shell.qml`.

### Hyprland Setup

The HUD uses the `void-hud` layer-shell namespace. Optional blur rules:

```ini
layerrule = blur, void-hud
layerrule = ignorezero, void-hud
```

Blur is optional. The shell is designed to remain usable without compositor blur.

See [docs/hyprland.md](docs/hyprland.md) for details.

### Controls

Open the command center from the visible top-bar `SETTINGS` control or with `Ctrl+Alt+S`. Focus the compact top-bar launcher with `Ctrl+Space`.

Common interactions:

- `Escape`: close the active central panel or command center
- `Ctrl+Space`: focus/dismiss the top-bar launcher
- `Ctrl+Alt+S`: open the command center
- Top workspace cells: switch Hyprland workspace
- Left analog orbital clock: open graphical orbital sensor
- Right CPU/network/filesystem/log sections: open central drill-down panels
- Tray left click: activate item
- Tray right click: secondary activate/menu fallback
- Command center launcher: type app/action names to search
- Launcher calculator: type `=<expression>`, for example `=1+2*3`, then click result to copy
- Launcher shell command: type `$ <command>`, then click to dispatch
- Emoji cells: copy emoji to clipboard
- Clipboard entries: restore/copy clipboard history item
- Power/session actions: click once to arm, click same action again to execute

### Settings

Open the command center and use the settings column to adjust:

- accent color, defaulting to gray `#8A8A8A`
- theme profile
- tactical background mode
- font scale
- scanline overlay
- live data polling
- microphone controls
- left/right panel visibility
- intensity
- polling interval
- wallpaper scan/apply/color sampling

Settings are persisted through `void-shell-settings`.

### Troubleshooting

Run the shell from a terminal to inspect logs:

```bash
quickshell -p .
```

Expected startup output includes:

```text
Configuration Loaded
```

Useful checks:

- If tray menu/platform errors appear, confirm `//@ pragma UseQApplication` is still the first line of `shell.qml`.
- If metrics show fallback values, check the optional tools listed above.
- If panels feel clipped, use mouse wheel inside side panels or command-center columns; dense panels scroll internally.
- If settings do not persist, run `zig build` and confirm `zig-out/bin/void-shell-settings` exists.
- If Hyprland workspace or window telemetry is missing, confirm the shell is running inside a Hyprland session.

## Documentation

Refer to [target.md](target.md) for a detailed breakdown of the interface elements.

See [docs/hyprland.md](docs/hyprland.md) for Hyprland layer-shell, blur, and workspace integration notes.

See [docs/settings.md](docs/settings.md) for the settings persistence contract and Zig helper plan.

See [docs/development-plan.md](docs/development-plan.md) for current implementation slice granularity, Agent provider next steps, and backlog guardrails.

## License

GPLv3
