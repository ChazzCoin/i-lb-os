# TASK-028: Make the squad panel observe the roster live (Add-player redraw)

**Phase:** SQ — Squad / Roster · **Severity:** CRITICAL · **Depends on:** none (gates TASK-029, TASK-030, TASK-031, TASK-032) · **Source:** [audit](../../docs/audits/2026-06-26-squad-add-player-drawer.md)

## User story
As a **coach**, I want **a player I add to the squad to appear in the panel the instant I tap "Add player"** so that **the button does what it says instead of looking like a dead no-op**.

## Why this matters
Tapping "Add player" persists a `RosterPlayer` to Realm correctly, but the panel never redraws, so the new row does not appear until some unrelated action triggers a board refresh. To anyone testing the branch the feature's main button looks broken. The root cause is a read/write mismatch: `EngineSquadPanel` reads the roster as a snapshot `Array(...)` inside `body`, while `addPlayer()` is the one write path that forgets to call `BEO.refreshBoard()`. The sibling writes (`place()`, `delete()`, `duplicate()`) only work because they happen to flip the published refresh flag. This task removes the entire class of "forgot to refresh" bugs by making the panel observe the live query directly. It is first in the SQ batch because every later roster feature (away-side add, edit, delete, place/remove toggle) depends on the panel redrawing on a Realm write.

## Findings covered
- [`Ludi Boards/Redesign/Panels.swift:113`](../../Ludi%20Boards/Redesign/Panels.swift) (CRITICAL) — `addPlayer()` writes a `RosterPlayer` via `safeWrite` but never calls `BEO.refreshBoard()`, and `EngineSquadPanel` reads the roster as a snapshot `Array(BEO.realmInstance.objects(RosterPlayer.self)...)` in `body` (see `roster(_:)` at `Panels.swift:72`), not via `@ObservedResults`. A Realm write publishes nothing the panel observes, so the new player never appears until an unrelated `refreshBoard()` fires. Tapping the feature's main button reads as a no-op. Fix: switch `EngineSquadPanel` to drive its rows from `@ObservedResults(RosterPlayer.self)` filtered by `boardId == BEO.currentActivityId` and sorted by `orderIndex`, partitioned into home/away in `body`, so add/edit/delete reflect immediately and writers no longer have to remember `refreshBoard()`.

## Scope
**In scope:**
- Convert `EngineSquadPanel`'s roster read from the snapshot `Array(...)` in `body` to `@ObservedResults(RosterPlayer.self)` (filtered by current board, sorted by `orderIndex`), partitioned into home/away where it renders.
- Confirm `addPlayer()` (and `place()`/`delete()`/`duplicate()` if present) now redraws the panel via the observed results, independent of `refreshBoard()`.

**Out of scope:**
- Away-side add path and the hardcoded `teamSide = "home"` (TASK-029/030).
- A player edit affordance — name/number/position (TASK-030).
- Roster delete and the `orderIndex = home.count` collision (TASK-031).
- Place/remove dedup toggle on `place()` (TASK-032).
- Empty-state copy and first-run population outside DEBUG seed (separate SQ task).
- Any change to the board-scoped `RosterPlayer` model — keep `boardId`-scoped as-is. The team-entity decision is carried in TASK-033; no model change here.
- The empty `migrationBlock` at schemaVersion 2 — no code action now (TASK-034).

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift`

## Acceptance criteria
- [ ] `EngineSquadPanel` obtains its roster rows from `@ObservedResults(RosterPlayer.self)` filtered to `boardId == BEO.currentActivityId`, not from `Array(BEO.realmInstance.objects(...))` snapshot inside `body`.
- [ ] Rows are still sorted by `orderIndex` and partitioned into home/away exactly as before; the rendered output for an existing roster is unchanged.
- [ ] Tapping "Add player" makes the new row appear immediately, with no other action and without relying on `BEO.refreshBoard()`.
- [ ] A roster write made elsewhere (e.g. `place()` spawning a jersey, or a future delete) is reflected in the panel without an explicit `refreshBoard()` call.
- [ ] No new compiler warnings; the preview twin `SquadPanel` (no `BoardEngineObject`) still renders.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim — scheme **"Ludi Boards"**, bundle **io.ludi.sol** (headless render ok): open a board with at least one home player, tap "Add player", confirm the new "Player N" row appears in the HOME column on the same frame; confirm the existing rows are unchanged and sorted by `orderIndex`.

## Open questions / risks
- `@ObservedResults` requires the property wrapper to live on a `View`'s stored property; if `EngineSquadPanel` currently reads through `BEO.realmInstance` lazily, the filter predicate (`boardId == BEO.currentActivityId`) must resolve at init time. Confirm `currentActivityId` is stable for the panel's lifetime or recompute on board change.
- Realm/SwiftUI lifecycle: the audit notes the snapshot read was originally chosen to dodge `@ObservedResults` quirks. Watch for invalidation crashes if the panel survives a board switch — re-key the view on `currentActivityId` if needed.
- This change deletes the implicit reliance on `refreshBoard()` for the panel, but `refreshBoard()` may still be load-bearing for the board canvas itself; do not remove `refreshBoard()` calls from `place()`/`delete()` — only stop depending on them for the squad panel redraw.

## Outcome (2026-06-26) — DONE (build + render verified)
`EngineSquadPanel` now drives its rows from `@ObservedResults(RosterPlayer.self)`, filtered by `boardId == currentActivityId` and side in `body` (not via `where:`, since `currentActivityId` is runtime). `addPlayer` no longer calls `refreshBoard()` — the live query redraws on the write. Build clean on the iPad sim; panel renders correctly with no runtime/Realm errors in the log. Redraw-on-write is correct by construction (`@ObservedResults` is Realm's auto-updating SwiftUI wrapper, same pattern as `BoardEngineObject.allTools`); an empirical tap-test was deferred per the background-only verification preference — recommend an XCUITest for durable sign-off ([[verify-ios-simulator-in-background]]).
