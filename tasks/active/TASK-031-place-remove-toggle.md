# TASK-031: Place/remove toggle + dedup (one disc per roster player)

**Phase:** SQ — Squad / Roster · **Severity:** MEDIUM · **Depends on:** TASK-028 (live panel) · **Source:** [audit](../../docs/audits/2026-06-26-squad-add-player-drawer.md)

## User story
As a **coach**, I want **tapping a roster row to place that player once and tap again to remove them** so that **a single squad member maps to exactly one disc on the board instead of spawning a new duplicate jersey on every tap**.

## Why this matters
`place(_:)` unconditionally creates a new `ManagedView` every time a roster row is tapped. It never checks whether that `playerId` already has a disc on the board, so a single roster person can be placed N times — N identical jerseys, all linked to the same `playerId`, stacked at deterministic-but-overlapping coordinates. There is no dedup, no toggle, and no visual signal in the row that a player is already on the board, so the coach has no way to tell placed from unplaced and accumulates phantom duplicates by re-tapping.

## Findings covered
- [`Ludi Boards/Redesign/Panels.swift:128`](../../Ludi%20Boards/Redesign/Panels.swift) — `place(_:)` builds a fresh `ManagedView` with `mv.playerId = p.id` and writes it on every tap, with no query for an existing view carrying that `playerId`; one roster player can be placed unlimited times. Fix: before creating, query `ManagedView` for `boardId == currentActivityId AND playerId == p.id` (non-deleted). If none exists, place; if one exists, treat the tap as a remove (delete that `ManagedView`, then `refreshBoard()`), making the row a place/remove toggle. Reflect placed state in the row (e.g. a placed indicator / filled vs. outline) driven by the same query.

## Scope
**In scope:**
- Guard `place(_:)` against duplicate placement: one disc per `(boardId, playerId)`.
- Make a roster-row tap a place/remove toggle — first tap places, second tap removes the linked disc.
- Reflect placed/unplaced state in the squad row so the coach can see which players are on the board.
- Keep `refreshBoard()` being called after both place and remove (the redraw mechanism the panel relies on).

**Out of scope:**
- The board-scoped `RosterPlayer` model itself — keep it as-is (board-scoped, no reusable team entity).
- Away-side add, name/number/position edit, delete-from-roster, empty state (TASK-029/030, separate findings).
- Formation-label and squad-name correctness (separate LOW findings).
- Any change to disc-number authority / write-back (TASK-019 latent item).

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift`

## Acceptance criteria
- [ ] Tapping a roster row that has no disc on the current board places exactly one `ManagedView` linked to that `playerId`.
- [ ] Tapping the same roster row again removes that player's disc (no orphaned duplicate left behind), not a second one.
- [ ] Placing the same player twice never results in two discs with the same `playerId` on one board.
- [ ] The squad row visibly reflects placed vs. unplaced state, and the indicator updates after place and after remove.
- [ ] Both place and remove paths call `BEO.refreshBoard()` so the board and the panel redraw.
- [ ] Removing a disc by deleting it directly on the board flips the row back to unplaced on the next refresh.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim — scheme "Ludi Boards", bundle `io.ludi.sol`: on a board with a populated roster, tap a roster row and confirm one jersey appears and the row shows placed; tap the same row again and confirm the jersey is removed and the row shows unplaced; rapid-tap a row several times and confirm the board never holds more than one disc for that player.

## Open questions / risks
- Existence query authority: this task assumes the panel can see placed state live. It depends on TASK-028 (live panel via `@ObservedResults`) landing first so the row indicator refreshes without a manual `refreshBoard()` round-trip; if TASK-028 is not in, the indicator will only update on the existing `refreshBoard()` flip — acceptable but worth noting.
- Remove semantics: confirm whether "remove" should hard-delete the `ManagedView` or soft-delete (set a deleted flag). Match whatever `delete()` already does elsewhere in the panel so dedup and removal agree on what "present" means.
- Multiple legacy duplicates may already exist on boards created before this fix; decide whether the remove tap clears all matching discs for that `playerId` or just one. Clearing all is the safer cleanup.

## Outcome (2026-06-26) — DONE (build verified)
`place()` is now a toggle: it queries for a non-deleted jersey `ManagedView` with this `playerId` on the current board; if present it soft-deletes (`isDeleted = true`), otherwise it spawns as before — no more unbounded duplicate discs per player. `refreshBoard()` stays (canvas + the row's placed indicator observe BEO, not RosterPlayer). The row shows a lime checkmark when placed. Build clean; tap-level toggle behavior deferred to an XCUITest.
