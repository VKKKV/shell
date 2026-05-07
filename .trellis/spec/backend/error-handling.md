# Error Handling

> How errors are handled in this project.

---

## Overview

Backend error handling applies to focused Zig helpers. Helpers should fail explicitly for invalid command usage or unrecoverable filesystem errors, while QML treats helper failure as recoverable and keeps safe defaults active.

Core rules:

- stdout is reserved for valid machine-readable JSON.
- stderr is reserved for diagnostics and warnings.
- `read` should fall back to defaults for missing/invalid/unsupported settings files.
- `write` should return an error when normalization or file persistence fails.
- QML surfaces helper write/read failures as fallback status text, not startup failure.

---

## Error Types

Current helper-specific errors in `src/settings/main.zig` include:

- `error.MissingJsonPayload`: `write` was called without a JSON payload.
- `error.UnknownCommand`: CLI command is not `defaults`, `read`, or `write`.
- `error.EnvironmentVariableMissing`: no `XDG_CONFIG_HOME` or `HOME` exists for settings path fallback.
- `error.InvalidSettingsJson`: payload root is not a valid settings object.
- `error.UnsupportedSettingsVersion`: payload version is newer than the helper supports.

Filesystem errors from `std.Io.Dir` should propagate unless explicitly documented as recoverable.

---

## Error Handling Patterns

### Settings Read

```zig
const data = std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(1024 * 1024)) catch |err| switch (err) {
    error.FileNotFound => {
        try writeStdout(io, defaults_json ++ "\n");
        return;
    },
    else => return err,
};
```

Read is tolerant: missing files, invalid JSON, or unsupported future versions should leave the shell with defaults.

### Settings Write

```zig
try ensureSettingsDir(allocator, io, path);
var file = try std.Io.Dir.cwd().createFile(io, path, .{ .truncate = true });
```

Write is strict: if the helper cannot create the directory or write the normalized payload, return the error and let QML show `settings: helper write fallback`.

---

## CLI Error Responses

There is no HTTP API. CLI behavior is the contract:

- Success -> JSON on stdout, exit 0.
- Usage/validation/filesystem failure -> diagnostic on stderr where possible, non-zero exit.
- Do not print partial JSON to stdout on failure.

---

## Common Mistakes

- Swallowing directory creation errors and then failing later with a less clear `createFile` error.
- Printing warnings or debug text to stdout, which breaks QML JSON parsing.
- Making helper failure fatal to Quickshell startup instead of relying on QML fallback defaults.
- Treating unsupported future settings versions as valid input.

---

## Scenario: Settings Helper Filesystem Failure Contract

### 1. Scope / Trigger

- Trigger: changing settings helper path resolution, directory creation, read/write behavior, or QML helper invocation.
- Applies to: `src/settings/main.zig`, `services/SettingsService.qml`, and `docs/settings.md`.

### 2. Signatures

- CLI: `void-shell-settings defaults`
- CLI: `void-shell-settings read`
- CLI: `void-shell-settings write '<json-payload>'`
- Env: `XDG_CONFIG_HOME` optional; when set, path is `$XDG_CONFIG_HOME/void-shell/settings.json`.
- Env: `HOME` fallback; when `XDG_CONFIG_HOME` is unset, path is `$HOME/.config/void-shell/settings.json`.

### 3. Contracts

- `defaults` prints defaults JSON and does not touch the filesystem.
- `read` prints defaults JSON when the settings file is missing, invalid, or has an unsupported future version.
- `write` normalizes before writing, creates the containing directory if needed, writes normalized JSON with trailing newline, then prints normalized JSON.
- Directory creation failures are real write failures and must propagate to QML.
- QML keeps in-memory settings/defaults active when helper commands fail.

### 4. Validation & Error Matrix

- Missing settings file on `read` -> stdout defaults JSON, exit 0.
- Invalid JSON on `read` -> stdout defaults JSON, exit 0.
- Future version on `read` -> stdout defaults JSON, exit 0.
- Missing payload on `write` -> stderr usage/error, non-zero exit.
- Invalid payload root on `write` -> non-zero exit, no partial settings file contract guaranteed.
- Directory cannot be created on `write` -> stderr warning if possible, non-zero exit.
- `XDG_CONFIG_HOME` unset and `HOME` unset -> non-zero `EnvironmentVariableMissing`.

### 5. Good/Base/Bad Cases

- Good: `write` with temporary `XDG_CONFIG_HOME` creates `void-shell/settings.json`, writes normalized JSON, and prints the same JSON to stdout.
- Base: `read` with no file prints defaults, allowing QML startup to continue.
- Bad: helper prints `warning: ...` to stdout before JSON; QML parse fails despite a valid settings payload.
- Bad: helper ignores a failed directory creation and only fails later with an unclear file creation error.

### 6. Tests Required

- `zig build test` after helper changes.
- `zig build` after helper changes.
- CLI smoke with temporary `XDG_CONFIG_HOME` for `defaults`, `read`, and `write`.
- Assert `write` creates nested `void-shell/` settings directory when missing.
- Assert stdout remains JSON for successful commands.

### 7. Wrong vs Correct

#### Wrong

```zig
ensureSettingsDir(allocator, io, path);
var file = try std.Io.Dir.cwd().createFile(io, path, .{ .truncate = true });
```

This hides the original directory creation failure.

#### Correct

```zig
try ensureSettingsDir(allocator, io, path);
var file = try std.Io.Dir.cwd().createFile(io, path, .{ .truncate = true });
```

This preserves the real failure boundary and lets QML use its helper fallback path.
