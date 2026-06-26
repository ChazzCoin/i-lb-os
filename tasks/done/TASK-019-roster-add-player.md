# TASK-019: Wire the roster "Add player" + roster write-back

**Phase:** Tool System Hardening · **Severity:** HIGH · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-tool-system.md)

## User story
As a **coach**, I want **to add players to my squad and have edits flow through to discs already on the board** so that **the roster is usable outside debug builds and placed players never show stale numbers**.

## Why this matters
Today the only code that creates a `RosterPlayer` lives behind `#if DEBUG`, so in a release build the squad is permanently empty and nothing is placeable. The "Add player" button is a bare label with no action, so there is no way to populate the roster at all. Separately, the disc's identity (number/side) is copied once at placement with no link back, so editing a player in the roster leaves already-placed discs showing the old data.

## Findings covered
- [`Ludi Boards/Redesign/Panels.swift:104`](../../Ludi%20Boards/Redesign/Panels.swift) — "Add player" is a bare `FooterButton` with no action; the only `RosterPlayer` creator is the `#if DEBUG` seed, so the roster is permanently empty in release. Fix: wrap it in a `Button` that creates a `RosterPlayer` (boardId = currentActivityId, next orderIndex) and move seeding out of `#if DEBUG` (or add a real add flow).
- [`Ludi Boards/Redesign/Panels.swift:116`](../../Ludi%20Boards/Redesign/Panels.swift) + [`CoreEngine/.../ManagedView.swift:56`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift) — the denormalised roster link (`playerId`/`jerseyNumber`/`teamSide`) is copied once at placement with no write-back; editing a player leaves placed discs stale. Fix: pick an authority — resolve the disc number live via `playerId` at render, or sync placed views when the roster entry is edited.

## Scope
**In scope:**
- Make "Add player" a working `Button` that inserts a `RosterPlayer` (boardId = `currentActivityId`, next `orderIndex` for the chosen side).
- Ensure the roster is populated in non-DEBUG builds (real add flow and/or seed moved out of `#if DEBUG`).
- Decide and implement the disc-number authority so placed discs stay consistent with roster edits.

**Out of scope:**
- The roster data model / schema (owned by TASK-011, already shipped — reuse `RosterPlayer` and the denormalised `ManagedView` fields).
- Any squad UI beyond the add affordance (formation editing, drag-reorder, delete) unless trivially required.
- Editing a player's name/position UI itself — only the write-back path needs to exist.

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift`

## Acceptance criteria
- [ ] In a non-DEBUG build, the squad panel is populated (not empty) on a fresh board.
- [ ] Tapping "Add player" creates a `RosterPlayer` with `boardId == currentActivityId` and the next `orderIndex` for its side, and the new row appears in the panel.
- [ ] The newly added player is placeable on the board via the existing tap-to-place path.
- [ ] Editing a roster player's number/side updates already-placed discs (or discs resolve their number/side live via `playerId` at render).
- [ ] No `#if DEBUG`-only path remains as the sole source of roster entries.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless ok): on a fresh board in a Release config, the squad panel shows players; tap "Add player" and confirm a new row appears and can be placed; change that player's number and confirm the placed disc reflects the new number.

## Open questions / risks
- Authority fork: resolve disc identity live via `playerId` at render (always correct, small per-render lookup) vs. write-back to placed `ManagedView`s on roster edit (no render cost, but must catch every edit site). Pick one before implementing — they imply different change surfaces.
- "Add player" with no input UI needs a default identity (name/number/position). Decide whether to auto-generate (next free number) or open a minimal entry sheet.

## Outcome (2026-06-26) — DONE (add) / latent (write-back)
"Add player" is wired to create a `RosterPlayer` (next home number) — the roster is no longer DEBUG-only. **Latent:** roster write-back (placed discs going stale when a player is edited) — there is still no player-edit UI, and the disc reads the denormalised `jerseyNumber`; resolve when an edit flow lands.
