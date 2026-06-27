# TASK-034: Schema migration discipline guard (RosterPlayer / ManagedView)

**Phase:** SQ — Squad / Roster · **Severity:** LOW · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-squad-add-player-drawer.md)

## User story
As a **coach**, I want **the app to keep opening my existing boards after an update** so that **a schema change in a future release never wipes or crashes my saved squads and tactical boards on launch**.

## Why this matters
The Realm config is at `schemaVersion: 2` with an empty `migrationBlock: { _, _ in }`. That is correct **only** while every schema change stays additive — adding a new `@Persisted` field or a new model migrates automatically with no mapping code. The moment anyone renames, removes, or retypes a field on `RosterPlayer` or `ManagedView` (e.g. `number` → `jerseyNumber`, dropping `teamSide`, changing `Int` to `String`), Realm throws at launch for every user with existing data, because the empty block provides no `oldObject`/`newObject` mapping. The code comment at `LudiBoardsApp.swift:25-27` already flags this and points at TASK-024. This task does not change code now — it is the explicit guard so the next person making a non-additive change knows the discipline and populates the block instead of shipping a launch crash.

## Findings covered
- [`Ludi Boards/LudiBoardsApp.swift:29`](../../Ludi%20Boards/LudiBoardsApp.swift) — empty `migrationBlock: { _, _ in }` at `schemaVersion: 2`. Fine while changes stay additive; any rename/remove/retype on `RosterPlayer` or `ManagedView` throws at launch for users with existing data (already flagged in-comment as TASK-024). Fix: **no code action now.** On the first non-additive change, bump `schemaVersion` and populate the block with explicit `oldObject`/`newObject` enumeration that maps old values to the new shape; never wipe user boards.

## Scope
**In scope:**
- Documenting the migration discipline: additive changes need only a `schemaVersion` bump; non-additive changes (rename/remove/retype) require explicit mapping in `migrationBlock`.
- Acting as the standing guard/checklist that gates the first non-additive change to `RosterPlayer` or `ManagedView`.

**Out of scope:**
- Writing any migration code now. The block stays empty while the schema is additive.
- Changing `RosterPlayer` or `ManagedView` fields (those changes land in their own tasks and trigger this guard).
- Any squad/roster feature work (lives in TASK-028..033).

## Files expected to change
- None now. When triggered: `Ludi Boards/LudiBoardsApp.swift` (bump `schemaVersion`, populate `migrationBlock`).

## Acceptance criteria
- [ ] The migration discipline is recorded so it survives past the inline comment: additive → bump version only; non-additive → bump version **and** map in `migrationBlock`.
- [ ] This task is referenced (or its rule is) at the point any change to `RosterPlayer` or `ManagedView` fields is planned, before that change ships.
- [ ] When a non-additive change lands: `schemaVersion` is incremented, `migrationBlock` enumerates old objects and maps renamed/removed/retyped fields, and no path wipes existing user data.
- [ ] A device/sim carrying data written under the prior `schemaVersion` launches cleanly after the migration (no Realm migration exception).

## Verification (build + sim)
1. `/build` clean.
2. iPad sim — scheme **"Ludi Boards"**, bundle **io.ludi.sol**: while this task is a no-op, confirm a build with a board saved under the current schema still launches and opens that board. When the guard is later triggered by a real migration, repeat with data written under the previous `schemaVersion` and confirm a clean launch with the data migrated, not lost.

## Open questions / risks
- This task fires reactively — it is easy to forget at the moment a field is renamed. The real mitigation is the inline comment at `LudiBoardsApp.swift:25-27` plus this task; consider a codified rule (`/codify`) so reviewers catch a missing `migrationBlock` on any `RosterPlayer`/`ManagedView` field change.
- A botched migration block is worse than none — it can corrupt or drop user boards. Whoever populates it must test against real pre-migration data, not a fresh install.
- TASK-033 carries the team-entity decision; if `RosterPlayer` is reshaped into a reusable squad/team model, that is a non-additive change and is exactly the trigger this guard exists for.
