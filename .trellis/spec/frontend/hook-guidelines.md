# Hook Guidelines

> How hook-like stateful logic is handled in this project.

---

## Overview

This is a Quickshell/QML project, not a React project. There are no React hooks, no `use*` functions, and no hook library. The equivalent pattern is QML singletons in `services/` plus `Timer`, `Process`, and `Connections` blocks.

Rules:

- Put shared stateful logic in `services/*.qml`.
- Keep `modules/hud/*.qml` focused on composed surfaces and minimal glue.
- Keep `components/*.qml` presentation-only except local pointer/animation affordances.
- Use `SettingsService.liveDataEnabled` and `SettingsService.updateIntervalMs` where polling should be user-controlled.

---

## Stateful Logic Patterns

### Service Singleton

Use a singleton when data is shared, polled, parsed, backed by an external command, or consumed by multiple surfaces.

Examples:

- `services/SystemStats.qml`: CPU/memory/network/filesystem polling and shaped rows.
- `services/SettingsService.qml`: in-session settings state and helper read/write orchestration.
- `services/CompositorService.qml`: shared facade over Hyprland/Niri/fallback state.
- `services/CalendarService.qml`: local date/month/agenda state.

### Local Component State

Use local QML properties inside a component/module for visual-only interaction state.

Examples:

- hover state inside a `MouseArea`
- `dragActive`, `pendingYawDeg`, and `pendingPitchDeg` inside `OrbitalExpansionPanel.qml`
- transient animation phase when it only affects one surface

---

## Data Fetching

There is no HTTP data-fetching layer. External data sources are local system commands, system files, or Quickshell-provided services.

Patterns:

- `Process` command execution belongs in `services/`.
- Parse command output in the service and expose shaped properties to modules.
- Missing commands or parse failures should update fallback state instead of throwing through bindings.
- Pollers should stop when `SettingsService.liveDataEnabled` is false.

---

## Naming Conventions

- Services that represent external integrations or domain state use `*Service.qml`, such as `AudioService.qml`.
- Short domain singletons are allowed when already clear, such as `Time.qml`.
- Service properties should expose display-ready values like `statusLine`, `rows`, `available`, `progress`, or `displayText`.
- Functions exposed to modules should describe user intent, such as `refresh()`, `toggleMute()`, `switchWorkspace(id)`, or `focusWindow(windowKey)`.

---

## Common Mistakes

- Adding React-style `use*` abstractions in a QML codebase.
- Putting polling or command parsing directly in `modules/hud/`.
- Duplicating the same polling timers and fallback strings across modules instead of promoting shared state to a service.
- Letting a service poll while `SettingsService.liveDataEnabled` is false.

---

## Scenario: QML Polling Service Contract

### 1. Scope / Trigger

- Trigger: adding or changing a QML service that polls external commands/files or exposes live system state.
- Applies to: `services/*.qml` pollers, process commands, parser functions, and modules consuming shaped service state.

### 2. Signatures

- Service singleton: `pragma Singleton` QML file under `services/`.
- Poll toggle: `SettingsService.liveDataEnabled: bool`.
- Poll cadence: `SettingsService.updateIntervalMs: int` when user-adjustable cadence is appropriate.
- Common service fields: `available: bool`, `statusLine: string`, shaped row arrays such as `cpuRows` or `diagnosticRows`.

### 3. Contracts

- External commands run in services, not components.
- Services expose shaped, renderable state even on failure.
- Modules consume service fields and actions; they should not parse raw command output.
- Polling stops or remains disabled when live data is disabled.
- Startup polling may use a short delayed timer through `PollingSchedule` when many collectors start together.

### 4. Validation & Error Matrix

- Command missing -> `available = false`, readable fallback `statusLine`, no QML exception.
- Command exits non-zero -> fallback state, no raw stderr in normal UI.
- Parse fails -> empty/default shaped rows and parse fallback status.
- Live data disabled -> poll timers stop and no repeated external reads continue.
- Module imports backend-specific service directly when a facade exists -> fail review.

### 5. Good/Base/Bad Cases

- Good: `SystemStats.qml` parses `/proc`/command output and exposes `cpuRows`; HUD modules only render rows.
- Good: `CompositorService.qml` hides Hyprland/Niri differences behind a shared contract.
- Base: a local visual timer in one panel is acceptable when it does not fetch external state.
- Bad: a HUD component runs `Process { command: [...] }` and parses stdout inline.

### 6. Tests Required

- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`.
- Runtime smoke with `timeout 8s quickshell -p .` and `Configuration Loaded` in logs.
- Manual missing-command/no-hardware fallback check when feasible.
- Verify live-data toggle stops or avoids poll restarts for affected service.

### 7. Wrong vs Correct

#### Wrong

```qml
// Inside modules/hud/SomePanel.qml
Process {
    command: ["free", "-b"]
}
```

#### Correct

```qml
// Inside modules/hud/SomePanel.qml
Repeater {
    model: SystemStats.cpuRows
}
```

The service owns command execution and parsing; the module renders shaped state.
