# Logging Guidelines

> How logging is done in this project.

---

## Overview

There is no full structured logging stack yet. Current logging is lightweight and split by layer:

- QML services expose human-readable status through state like `statusLine` and `logLines`
- helper binaries print JSON results to stdout and human-readable diagnostics to stderr

---

## Log Levels

Current practical mapping:

- info: collector/helper online, successful fallback transitions
- warn: missing command, missing directory creation, fallback mode entered
- error: invalid command usage, invalid settings payload, unrecoverable file errors

---

## Structured Logging

For Zig helpers:

- stdout is reserved for machine-readable JSON output
- stderr is reserved for human-readable diagnostics

For QML services:

- expose short `statusLine`
- keep a small rolling `logLines` list for on-screen diagnostics

---

## What to Log

- collector availability/fallback transitions
- settings helper normalization/write failures
- missing optional mounts such as `/data`
- Hyprland service availability vs fallback mode

---

## What NOT to Log

- full arbitrary settings payloads if not needed
- secrets, tokens, credentials
- excessive per-frame/per-tick noisy logs that swamp the HUD
