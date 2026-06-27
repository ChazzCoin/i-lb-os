# TASK-030: Squad empty state + production population path

**Phase:** SQ — Squad / Roster · **Severity:** HIGH · **Depends on:** TASK-028 (live-panel `@ObservedResults` fix) · **Source:** [audit](../../docs/audits/2026-06-26-squad-add-player-drawer.md)

## User story
As a **coach**, I want **the squad panel to tell me it's empty and give me a way to start a roster on a fresh board** so that **a new activity doesn't look broken — two zero-count headers with no rows and no guidance — and I can actually populate a squad in a release build**.

## Why this matters
The only path that creates `RosterPlayer` rows on a fresh board is `seedRosterIfNeeded()`, and it is wrapped in `#if DEBUG` and gated on `REDESIGN_SEED=1`. Production ships an empty squad. With no players and no empty state, `EngineSquadPanel` renders two header rows — "HOME · 4-3-3" count 0 and "AWAY · 4-4-2" count 0 — followed by nothing. To anyone opening the panel that reads as a bug, not as "empty by design." There is no copy telling the user what to do and no first-run route to a populated roster outside the debug seed.

## Findings covered
- [`Ludi Boards/CanvasEngine/BoardEngineView.swift:160`](../../Ludi%20Boards/CanvasEngine/BoardEngineView.swift) — `seedRosterIfNeeded()` is `#if DEBUG` (line 158) and gated on `REDESIGN_SEED=1`, so it is the *only* roster-population path and never runs in production. The fresh-board squad is permanently empty. Fix: provide a real non-DEBUG population path — either keep the seed but make it reachable in release (e.g. an explicit "Load sample squad" affordance), or rely on a working `addPlayer()` (TASK-029) as the production route. The DEBUG seed must stop being the sole source of rows.
- [`Ludi Boards/Redesign/Panels.swift:92`](../../Ludi%20Boards/Redesign/Panels.swift) — `EngineSquadPanel.body` always renders `RosterHeader(... count: home.count)` and `RosterHeader(... count: away.count)` with the row `ForEach`s below; when both rosters are empty the user sees two headers reading count 0 and zero rows, with no guidance. Fix: add an empty-state — when `home.isEmpty && away.isEmpty`, show "No players yet — Add player to start" (or equivalent) in place of (or beneath) the bare zero-count headers, pointing at the existing footer "Add player" button.

## Scope
**In scope:**
- Add an empty-state to `EngineSquadPanel` shown when the board has no `RosterPlayer` rows: copy "No players yet — Add player to start" plus a clear pointer to the "Add player" affordance.
- Ensure a real, non-DEBUG population path exists so a release build can go from empty squad to populated squad without relying on `REDESIGN_SEED=1`.
- Keep the empty-state and the populated state mutually exclusive (no zero-count headers sitting above the empty-state text).

**Out of scope:**
- The live-panel redraw fix (`@ObservedResults` vs `refreshBoard()`) — that is TASK-028 and this task depends on it landing first.
- Wiring/repairing `addPlayer()` itself (away-side, edit, dedup) — TASK-029.
- Any change to the `RosterPlayer` schema or introducing a reusable team/squad entity — keep the model **board-scoped** as it is today (`RosterPlayer.boardId`). The team-entity decision is carried in TASK-033.
- The hardcoded "U-12 Squad" breadcrumb (TASK-033) and formation strings "4-3-3"/"4-4-2" (separate finding).

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift` — empty-state in `EngineSquadPanel`.
- `Ludi Boards/CanvasEngine/BoardEngineView.swift` — non-DEBUG population path (or removal of `#if DEBUG`-as-sole-source).

## Acceptance criteria
- [ ] On a fresh board in a Release config (no `REDESIGN_SEED`), opening the squad panel shows an empty-state with copy "No players yet — Add player to start" (or agreed equivalent), not two bare zero-count headers with no rows.
- [ ] The empty-state visibly points the user at the "Add player" footer button.
- [ ] Once at least one `RosterPlayer` exists for the board, the empty-state is gone and the normal home/away headers + rows render.
- [ ] A release build has a working route from empty squad to populated squad that does not depend on `#if DEBUG` / `REDESIGN_SEED=1`.
- [ ] No `#if DEBUG`-only path remains the sole source of roster rows in production.
- [ ] The DEBUG seed (if kept) still works under `REDESIGN_SEED=1` and is not duplicated by the production path.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim — scheme **"Ludi Boards"**, bundle **io.ludi.sol**: launch a Release config with `REDESIGN_SEED` unset, open a fresh board, confirm the squad panel shows the empty-state copy (not zero-count headers with no rows). Then exercise the production population path (e.g. tap "Add player") and confirm the empty-state is replaced by the normal headers + the new row. Relaunch with `REDESIGN_SEED=1` and confirm the debug seed still populates and the empty-state does not show.

## Open questions / risks
- Production population route fork: (a) keep `seedRosterIfNeeded()` and expose it in release behind an explicit user action ("Load sample squad"), or (b) drop the sample entirely and treat `addPlayer()` (TASK-029) as the only production path, leaving fresh boards genuinely empty until the user adds. Pick one — (a) needs the seed moved/guarded out of `#if DEBUG`; (b) leans entirely on TASK-029 being solid.
- Depends on TASK-028: if the panel still reads the roster as a snapshot `Array` in `body` without `@ObservedResults`, the empty-state-to-populated transition won't redraw on add. Land TASK-028 first or the empty-state will look stuck.
- Empty-state placement: replace the headers entirely vs. show below them. Showing it below the two zero-count headers half-defeats the point; prefer replacing them while the squad is empty.

## Outcome (2026-06-26) — DONE (render verified)
Per-section empty state ("No {home,away} players yet — tap +") replaces the bare count-0 headers. Population path = the empty-state + per-side `+` / `+ Add player` (no release seed — the DEBUG `REDESIGN_SEED` seed stays a convenience). Verified on a cleared realm: both sections render the empty state with counts 0. Note confirmed during verification — the DEBUG seed does not populate the redesign canvas at all, so the empty state is the de-facto production experience, which is exactly why this fix matters.
