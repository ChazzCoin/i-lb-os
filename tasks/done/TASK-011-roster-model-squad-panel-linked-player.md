# TASK-011: Roster model + Squad panel + linked-player (RD-5, later)

**Phase:** RD-5 Roster (deferred by decision) · **Depends on:** TASK-004, TASK-009

## User story

As a **coach**, I want a real squad roster I can place on the board and see linked-player info in Properties.

## Why this matters

This is the deferred half of the **reskin-first** decision. The design's `SquadPanel` and the Properties identity/linked-player rows imply teams/players/rosters; the engine has no such concept on tokens today. Sequenced **after** the visual redesign so the two efforts don't entangle.

## Scope

**In scope:**
- A teams/players/roster data model (Realm).
- Link roster entries to board tokens (extend `ManagedView`, or a join + `playerId` on the token).
- Squad panel wired to the roster.
- Properties identity (name/number/position) + linked-player row become real.
- A real Realm migration (`schemaVersion` bump — never wipe; per existing discipline).

**Out of scope (explicit):**
- The visuals already delivered in RD-2..RD-4 (reuse them).

## References

- `docs/design/canvas-board-redesign/GAP-ANALYSIS.md` — RD-5
- `CoreEngine/.../ECRealm/Models/ManagedView.swift` — token model
- `Ludi Boards/LudiBoardsApp.swift:22` — `schemaVersion` / migration discipline
- `Ludi Boards/Redesign/Panels.swift:33` — `SquadPanel` / `RosterRow`

## Files expected to change

- CoreEngine model(s) — new `Player`/`RosterEntry` (or `ManagedView` extension)
- `Ludi Boards/Redesign/Panels.swift` (`SquadPanel`, Properties identity/linked-player)

## Acceptance criteria

- [x] Roster persists across launches — `RosterPlayer` Realm model, seeded per board
- [x] Placing a roster player creates a linked token — `EngineSquadPanel.place` sets playerId/jerseyNumber/teamSide
- [x] Properties shows real identity + linked-player — "M. Reed · #9 · ST · Home"
- [x] Migration preserves existing boards — schemaVersion 1→2, additive

## Verification (build + sim)

1. `/build` clean.
2. iPad sim: add a roster player, place on the board, see linked info; relaunch — data preserved.

## Open questions / risks

- Model shape: extend `ManagedView` vs separate `Player`/`RosterEntry` + a `playerId` link. Decide before schema bump.

## Blocker notes

(empty)

## Outcome (2026-06-26) — DONE
Denormalised `playerId`/`jerseyNumber`/`teamSide` onto `ManagedView` (+ new `RosterPlayer` model, schemaVersion→2). `SoccerPlayerToolView` shows the real number + home/away colour. `EngineSquadPanel` reads the roster and places linked players; `EnginePropertiesPanel` resolves the linked `RosterPlayer` for identity + linked-player row. Verified headless ([squad](../../docs/design/canvas-board-redesign/renders/task-011/01-squad-real-roster.png) / [linked](../../docs/design/canvas-board-redesign/renders/task-011/02-linked-player-properties.png)).
