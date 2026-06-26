# TASK-022: Delete dead routes & duplicate views

**Phase:** Tool System Hardening · **Severity:** LOW · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-tool-system.md)

## User story
As a **developer**, I want **the dead enum-based routes, the orphan `ManagedView`, and the duplicate static toolbar removed (and the misleading builder signatures tightened)** so that **the only code paths that exist are the live ones, and a mismatched tool can't silently render nothing**.

## Why this matters
The render pipeline grew a second, never-exercised enum route and a parallel context toolbar alongside the wired ones, plus an orphan `ManagedView` in the Wrlds target that diverges from the real schema. None of this ships behaviour today, but each is a trap: the dead enum route would mis-render if ever adopted, the orphan model is a schema-collision waiting to happen, and the unvalidated `(type,subtype)` router fails silently (EmptyText) with no log when a pair drifts. Clearing it leaves one obvious path per concern.

## Findings covered
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift:85`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — the enum `buildToolView`/`GenreBuilder(for: Genre)` route is dead AND incomplete (only `.soccer`/`.pool`, no smart case); the live path is the string router. **Fix:** delete the enum trio (or complete + adopt it).
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift:31`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — the nav-genre branch is dead in the board path (`sport` is never "nav"). **Fix:** drop the `"nav"` string case + `NavBuilder` (or document why it stays).
- [`Ludi Boards/Redesign/TacticalBoardView.swift:137`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — a dead static `contextToolbar` (non-functional icons) sits beside the wired `RedesignContextToolbar`. **Fix:** delete the static one.
- [`Wrlds/Realm/models/ManagedView.swift:11`](../../Wrlds/Realm/models/ManagedView.swift) — an orphan divergent `ManagedView` (not compiled), schema-collision trap. **Fix:** delete it (or make Wrlds depend on CoreEngine's model).
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift:99`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — `SmartTool.Build` ignores its `name`/subtype arg (misleading signature). **Fix:** drop the unused param (or thread subtype through).
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift:93`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — `(type,subtype)` pairs are unvalidated; a mismatch silently renders the wrong builder or EmptyText. **Fix:** assert/log on the default EmptyText fallthroughs.

## Scope
**In scope:**
- Delete the enum `buildToolView`/`GenreBuilder(for: Genre)` route and the nav-genre stubs in `MVEngineBuilder.swift`.
- Delete the static `contextToolbar` in `TacticalBoardView.swift`.
- Delete the orphan `Wrlds/Realm/models/ManagedView.swift` (or repoint Wrlds at CoreEngine's model).
- Drop `SmartTool.Build`'s unused `name`/subtype argument (or wire it in).
- Assert/log on the default `EmptyText` fallthroughs in the string router.

**Out of scope:**
- Factoring duplicate/delete logic onto `BEO` (the other half of the `:137` finding) — owned by the Properties/selection hardening tasks.
- Any change to the live string-router behaviour for real tools (no behaviour change).
- Smart-tool selection, Properties family-awareness, roster wiring — separate tasks.

## Files expected to change
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift`
- `Ludi Boards/Redesign/TacticalBoardView.swift`
- `Wrlds/Realm/models/ManagedView.swift` (deleted)

## Acceptance criteria
- [ ] The enum `buildToolView`/`GenreBuilder(for: Genre)` route and the `Tool`/`Genre` enums it switches on are removed (or completed + adopted), with no remaining references.
- [ ] The nav-genre branch (`"nav"` string case + `NavBuilder`) is removed or has a one-line comment documenting why it stays.
- [ ] The static `contextToolbar` in `TacticalBoardView.swift` is deleted; only `RedesignContextToolbar` remains wired.
- [ ] The orphan `Wrlds/Realm/models/ManagedView.swift` is deleted (or Wrlds depends on CoreEngine's `ManagedView`).
- [ ] `SmartTool.Build`'s unused `name`/subtype param is dropped (or threaded through to `SmartToolManaged`); callers updated.
- [ ] A mismatched `(type,subtype)` pair logs (or asserts in DEBUG) instead of silently rendering nothing.
- [ ] Build is clean and live tools render unchanged (no behaviour change).

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless ok): place one tool from each live family (token, line, smart) — all render exactly as before; then confirm a deliberately mismatched `(type,subtype)` produces a log line (DEBUG) rather than a silent empty render.

## Open questions / risks
- Delete-vs-complete fork on the enum route and the nav branch: default is delete (live path is the string router); only complete + adopt if there's a near-term plan to use it. Recommend delete.
- Wrlds model: confirm it is genuinely absent from the Wrlds target's pbxproj Sources before deleting (audit says not compiled) so the delete is a no-op to the build.

## Outcome (2026-06-26) — DONE (safe parts)
Deleted the dead static `contextToolbar` (TacticalBoardView) and the orphan `Wrlds/Realm/models/ManagedView.swift`. **Not deleted:** the enum `buildToolView`/`GenreBuilder(for: Genre)` route — it is NOT dead, it's referenced by `TheFactory.swift:57`; deleting would break the build. The `ShapeTool.Build` bounds param is deferred (cosmetic without threading bounds into the line views).
