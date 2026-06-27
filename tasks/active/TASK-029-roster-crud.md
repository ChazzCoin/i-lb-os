# TASK-029: Roster CRUD: away-side add, edit (name/number/position), delete

**Phase:** SQ — Squad / Roster · **Severity:** HIGH · **Depends on:** TASK-028 (live-panel refresh / `@ObservedResults`) · **Source:** [audit](../../docs/audits/2026-06-26-squad-add-player-drawer.md)

## User story
As a **coach**, I want **to add players to both the home and away squads, edit a player's name, number, and position, and delete players** so that **I can build a real lineup for either side instead of being stuck with auto-named "Player N" home-only entries that can never be filled or corrected in a release build**.

## Why this matters
Today `addPlayer()` hardcodes `teamSide = "home"`, so the away squad can only ever be populated by the `#if DEBUG` seed — in production it is permanently empty. Every added player lands as `"Player N"` with position `"—"` and there is no UI to change name, number, or position, so the roster is uneditable. There is also no delete path. The result is a squad feature that, outside debug builds, cannot represent a real team. Separately, `orderIndex = home.count` is a latent bug: once delete lands, deleting a mid-list player and then adding produces a colliding `orderIndex`.

## Findings covered
- [`Ludi Boards/Redesign/Panels.swift:120`](../../Ludi%20Boards/Redesign/Panels.swift) — `addPlayer()` hardcodes `p.teamSide = "home"`; combined with auto-naming (`"Player \(nextNumber)"`, position `"—"`) and no edit UI, the away squad can never be filled in production and home players cannot be corrected. Fix: add a per-side add path (caller passes the side), and a minimal edit affordance that writes back `name`, `number`, and `position` on an existing `RosterPlayer`.
- [`Ludi Boards/Redesign/Panels.swift:123`](../../Ludi%20Boards/Redesign/Panels.swift) — `addPlayer()` sets `orderIndex = home.count`; after a mid-list delete this collides with an existing row's index on the next insert. Fix: compute `orderIndex` as `(roster(side).map(\.orderIndex).max() ?? -1) + 1` so it never reuses an index.

## Scope
**In scope:**
- Per-side add: `addPlayer(_ side:)` (or equivalent) so both `"home"` and `"away"` rows can be created. Each side computes its own next number and `orderIndex`.
- Minimal edit affordance: edit `name`, `number`, and `position` on an existing `RosterPlayer` and persist via `safeWrite`.
- Delete: remove a `RosterPlayer` from the roster.
- `orderIndex` computed from `max(orderIndex) + 1` per side, not from `count`.
- Keep the board-scoped `RosterPlayer` model unchanged (`boardId`-scoped; no team entity).

**Out of scope:**
- The live-panel redraw fix (`refreshBoard()` / `@ObservedResults`) — owned by TASK-028, which lands first; CRUD writes here rely on that refresh path.
- Empty-state UI, formation-label correctness, place/remove dedup — separate tasks (030/031/032).
- Any squad/team entity, team name, or cross-board persistence — the team-entity decision is carried in TASK-033.
- Migration-block work — TASK-034 notes **no code action now** (changes here stay additive to `RosterPlayer`).

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift`

## Acceptance criteria
- [ ] An add affordance exists for **both** the home and away sections; adding to away creates a `RosterPlayer` with `teamSide == "away"` and `boardId == currentActivityId`.
- [ ] Each side's next `number` and `orderIndex` are computed independently from that side's existing rows.
- [ ] A player's `name`, `number`, and `position` can be edited and the change persists (survives a panel re-fetch / app relaunch).
- [ ] A player can be deleted and disappears from its section.
- [ ] `orderIndex` is computed as `max(orderIndex) + 1` for the target side; deleting a mid-list player and then adding does not reuse the deleted row's `orderIndex` or collide with an existing one.
- [ ] The added/edited/deleted state is reflected in the panel without an unrelated refresh (relies on TASK-028).
- [ ] `RosterPlayer` is still the board-scoped model — no new schema fields, no team entity introduced.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim — scheme **"Ludi Boards"**, bundle **io.ludi.sol**: on a fresh board, add a player to the **away** section and confirm it appears with `teamSide == "away"`. Edit that player's name/number/position and confirm the change persists after re-opening the panel. Delete a mid-list player, add a new one, and confirm the new row's `orderIndex` does not collide with any existing row.

## Open questions / risks
- Edit UI shape: inline fields on the row vs. a minimal entry sheet. Keep it minimal — the audit asks only that the name/number/position write-back path exists, not a polished editor.
- Number collisions: editing a player's `number` to one already used on the same side is allowed by the model (no uniqueness). Decide whether to dedupe/validate or leave as-is for this task.
- Delete + placed discs: a deleted `RosterPlayer` may still have a placed jersey `ManagedView` referencing its `playerId`. Out of scope to reconcile here, but note it so TASK-031/032 picks it up.

## Outcome (2026-06-26) — DONE (build verified)
Per-side add via a `+` on each `RosterHeader` (`addPlayer(side:)`, `orderIndex = max+1`), edit + delete via a new `RosterPlayerEditor` sheet (opened from a row pencil) that re-fetches by primary key inside `safeWrite`. RosterPlayer is hard-deleted (no `isDeleted` field); its placed discs are soft-deleted to match the canvas convention. Editing a number cascades to placed discs' `jerseyNumber`, closing the write-back gap TASK-019 left latent. Side-switching deferred. Build clean; interaction-level check deferred to an XCUITest.
