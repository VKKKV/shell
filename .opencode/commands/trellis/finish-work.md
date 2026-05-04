# Finish Work - Pre-Commit Checklist

Before submitting or committing, use this checklist to ensure work completeness.

**Timing**: After code is written and tested, before commit.

This repository is a **Quickshell/QML + Zig helper** project, not a `pnpm` web app. Use the checks below instead of generic frontend TypeScript commands.

---

## Checklist

### 1. Code Quality

```bash
# Use the real project checks
zig build
qmllint shell.qml components/*.qml modules/hud/*.qml services/*.qml theme/Theme.qml
timeout 8s quickshell -p .
```

- [ ] `zig build` passes?
- [ ] `qmllint ...` passes with 0 errors?
- [ ] `quickshell -p .` loads without runtime warnings/errors?
- [ ] If helper/backend behavior changed, did you exercise the relevant CLI contract manually?
  - Example: `./zig-out/bin/void-shell-settings defaults/read/write`

### 2. Code-Spec Sync

**Code-Spec Docs**:
- [ ] Does `.trellis/spec/backend/` need updates?
  - Zig helper conventions, logging rules, validation behavior
- [ ] Does `.trellis/spec/frontend/` need updates?
  - New QML service patterns, HUD modules, state ownership, component conventions
- [ ] Does `.trellis/spec/guides/` need updates?
  - New cross-layer lessons, fallback behavior, integration gotchas

**Key Question**:
> "If I fixed a bug or discovered something non-obvious, should I document it so future me (or others) won't hit the same issue?"

If YES -> Update the relevant code-spec doc.

### 2.5. Code-Spec Hard Block (Infra/Cross-Layer)

If the change touches helper contracts, service boundaries, or persistence rules, this is blocking:

- [ ] Spec content is executable, not principle-only text
- [ ] Includes file paths + command names + payload field names
- [ ] Includes fallback/validation behavior
- [ ] Includes Good/Base/Bad cases where appropriate
- [ ] Includes the actual verification commands used in this repo

### 3. QML / Shell Runtime Changes

If you modified QML modules or services:

- [ ] `quickshell -p .` still loads?
- [ ] No binding loop warnings?
- [ ] No layout/anchor undefined behavior warnings?
- [ ] No panel clipping or unreadable text on your monitor?

### 4. Zig Helper Changes

If you modified `src/` or `build.zig`:

- [ ] `zig build` succeeds?
- [ ] Helper output is valid JSON on stdout?
- [ ] Diagnostics stay on stderr?
- [ ] Config path / normalization / clamping behavior is documented?

### 5. Cross-Layer Verification

If the change spans QML + service + Zig helper:

- [ ] QML reads shaped state from services rather than parsing backend output inline?
- [ ] Helper failures leave safe defaults active?
- [ ] Settings/state contracts stay consistent across docs, QML, and Zig?

### 6. Manual Testing

- [ ] Feature works in the running shell?
- [ ] Edge cases tested?
- [ ] Error/fallback states tested?
- [ ] Restarting `quickshell -p .` preserves expected behavior?

---

## Quick Check Flow

```bash
# 1. Project checks
zig build
qmllint shell.qml components/*.qml modules/hud/*.qml services/*.qml theme/Theme.qml
timeout 8s quickshell -p .

# 2. Optional helper contract checks
./zig-out/bin/void-shell-settings defaults
./zig-out/bin/void-shell-settings read

# 3. View changes
git status
git diff --name-only
```

---

## Common Oversights

| Oversight | Consequence | Check |
|-----------|-------------|-------|
| QML service owns too much backend logic | Hard-to-debug state drift | Keep parsing/normalization in services or Zig helper |
| Spec docs not updated | Future changes break hidden conventions | Check `.trellis/spec/` |
| Runtime warnings ignored | Visual regressions accumulate | Run `quickshell -p .` |
| Zig artifacts committed | Dirty repo noise | Ignore `.zig-cache/`, `zig-out/` |
| Settings helper writes unnormalized JSON | Persistent config drift | Test `write` + `read` |

---

## Relationship to Other Commands

```text
Development Flow:
  Write code -> Validate -> /trellis:finish-work -> git commit -> /trellis:record-session

Debug Flow:
  Hit bug -> Fix -> /trellis:break-loop -> Knowledge capture
```

- `/trellis:finish-work` - Check work completeness
- `/trellis:record-session` - Record session and commits
- `/trellis:break-loop` - Deep analysis after debugging

---

## Core Principle

> **Delivery includes not just code, but also documentation, verification, and knowledge capture.**

Complete work = Code + Docs + Validation + Runtime Verification
