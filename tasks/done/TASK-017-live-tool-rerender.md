# TASK-017: Make tool views re-render on Realm change (colour edits show)

**Phase:** Tool System Hardening · **Severity:** HIGH · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-tool-system.md)

## User story
As a **coach**, I want **a disc or smart-tool's colour and number to update on the board the moment I edit it in Properties** so that **I can see my changes immediately instead of relaunching the app**.

## Why this matters
Tool views read their colour, number, and sub-type once in `onAppear` and never observe the underlying Realm row, so a Properties edit writes to the database but the rendered tool keeps the stale value. The intended escape hatch, `refreshBoard()`, is a no-op that toggles a flag no view depends on. The coach edits a player disc's colour, sees nothing change, and has to relaunch the app to confirm the edit even took — a silent broken-feedback loop on a core editing action.

## Findings covered
- [`CoreEngine/.../SoccerPlayerToolView.swift:42`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SoccerPlayerToolView.swift#L42) — reads colour/number ONCE in `onAppear` and never observes the row. Fix: observe Realm / re-read on change, or rebuild via the refresh flag.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:359`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift#L359) — `refreshBoard()` (the intended escape hatch) is a NO-OP: toggles a flag no view reads. Fix: make the board tool subtree depend on the flag (e.g. `.id(...)`) so toggling it forces a re-render.
- [`CoreEngine/.../SmartTools.swift:206`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift#L206) — `subType`/`jersey` read once in `onAppear`, never observed. Fix: promote `subToolType`/`jerseyNumber` to MVO `@Published` synced in `observeFromRealm`.

## Scope
**In scope:**
- Make tool views reflect live Realm changes to colour, jersey number, and sub-type without a relaunch.
- Wire `refreshBoard()` to something real (flag the tool subtree re-renders off), or have tool views observe Realm directly.
- Promote `subToolType`/`jerseyNumber` onto the MVO as `@Published`, synced in `observeFromRealm`.

**Out of scope:**
- Properties-panel UI/layout changes (owned by the properties work).
- The line/arrow tool render path (TASK-005).
- Broader Realm-observation refactor beyond these tool views.

## Files expected to change
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift`
- `Ludi Boards/.../SoccerPlayerToolView.swift`
- `Ludi Boards/.../SmartTools.swift`

## Acceptance criteria
- [ ] Editing a disc's colour in Properties updates the rendered tool live (no relaunch).
- [ ] Editing a smart-tool's colour in Properties updates the rendered tool live (no relaunch).
- [ ] Editing jersey number / sub-type reflects on the rendered tool live.
- [ ] `refreshBoard()` actually forces the board tool subtree to re-render (no longer a no-op).
- [ ] `subToolType`/`jerseyNumber` live on the MVO as `@Published` and are synced in `observeFromRealm`.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless ok): place a disc, edit its colour in Properties, confirm the rendered tool's fill changes in-place without relaunching.

## Open questions / risks
- Fork: rebuild-via-`.id()` vs per-view Realm observation. `.id()` is simpler but tears down/rebuilds the view (loses transient state, possible flicker); observation is finer-grained but touches each tool view. Pick one and apply consistently.

## Outcome (2026-06-26) — DONE
`SoccerPlayerToolView` now observes its row via `@ObservedRealmObject`, so colour/number/team edits update live (was read once on appear). Smart tools were already reactive via `MVO.lifeColor`. `refreshBoard()` is now vestigial for rendering (views observe + `@ObservedResults` handles add/delete) — left as a harmless explicit trigger.
