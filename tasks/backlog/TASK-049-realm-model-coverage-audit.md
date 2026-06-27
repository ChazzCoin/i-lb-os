# TASK-049: Realm-model coverage audit (everything persisted, Firebase-ready)

**Phase:** DM — Data model & linking · **Severity:** HIGH · **Size:** medium · **Depends on:** TASK-037 (sharing/links — not in scope), TASK-005 (board selection — uses ActivityPlan.id), TASK-017 (Realm observation refactor), TASK-031 (roster placement — depends on RosterPlayer Realm model) · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **everything I set up on a board — the field colors, the line style, the background, my placed players and tools, my recordings — to actually be saved in the data model** so that **when sharing and multi-device sync land later, my work is already in a form that can round-trip to the cloud instead of evaporating with the view that drew it**.

> User request, verbatim: "Validate that all objects, tools, settings — everything that can and should be — is backed by Realm data models properly and ready for Firebase in the future. No Firebase wiring yet."

## Why this matters
Realm coverage is **partial today**, and the gaps are exactly the ones that bite when sync arrives. The strongest models — `ManagedView`, `RosterPlayer`, `Recording`/`RecordingAction`, `ManagedViewAction` — are fully persisted and codable, so placed objects and recordings are already cloud-shaped. But **board settings have a Realm home (`ActivityPlan`) that the UI never writes back to**: the color/line/background setters mutate only `@Published` BEO properties, so a coach can change the field color, and that change lives in memory until the next `loadBoardSettings` reads the *old* Realm row back over it. Canvas transform (zoom/pan/rotate) has **no persistence at all**, and user/session context lives in `@AppStorage`, disconnected from the `CoreUser` Realm singleton. This audit is the moment to draw the line — wire the round-trips that *should* persist (board settings is the critical one), confirm the models are ISO-normalized and ordering-indexed for multi-device consistency, and explicitly mark what is intentionally transient (UI mode/panel state). No Firebase wiring — Firebase-ready only.

## Findings / current state
- [`Wrlds/Realm/models/ActivityPlan.swift:11-48`](../../Wrlds/Realm/models/ActivityPlan.swift) — the board-settings Realm model exists and is complete: `width/height`, `backgroundRed/Green/Blue/Alpha`, `backgroundLineRed/Green/Blue/Alpha`, `backgroundLineStroke`, `backgroundRotation`, `backgroundView`, primary key `id`. **Wired as storage, but nothing writes the live settings to it.** Already Firebase-shaped (flat scalar fields, string `id` primary key).
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:335-355`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `setColor()`, `setFieldLineColor()`, `setBoardBgView()` mutate only `@Published` BEO properties (`boardBgRed`, `boardFieldLineRed`, `boardBgName`, …); **no Realm write to the `ActivityPlan` row.** This is the critical gap: the round-trip is one-directional. **Change:** wrap each setter's mutation in a Realm write that updates the backing `ActivityPlan` (matched by `currentActivityId`).
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:156-173`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — board-settings transients (`boardBg*`, `boardFieldLine*`, `boardBgName`, etc.) are declared as `@Published`. **Change:** these stay `@Published` for SwiftUI binding, but become a *view* of the Realm row — populated on load, flushed on mutation. `loadBoardSettings` ([line 232-250](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift)) already cascades from the Realm row, so this closes the loop.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:128-130`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) + [`RedesignBoardCanvas.swift:28-30`](../../Ludi%20Boards/Redesign/RedesignBoardCanvas.swift) — canvas transform (`canvasScale`, `canvasOffset`, `canvasRotation`) is **100% `@Published` in-memory, no Realm backing.** This is device-local viewport geometry, not shared board content. **Change:** persist as `@AppStorage` (device-local prefs) so it survives app restart; do *not* force it into Realm for sync this round (see open questions).
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:58-74`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — session context (`currentUserId`, `currentActivityId`, etc.) is `@AppStorage`, **never synced to Realm.** [`CoreUser.swift:14-52`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/CoreUser.swift) is a singleton (`id = "CORE"`). **Change for this audit:** document the gap and confirm `CoreUser` is Firebase-shaped; the actual `@AppStorage → CoreUser` write + per-board access (a `Participant` model) is **out of scope** (belongs with TASK-037 sharing).
- [`Ludi Boards/Redesign/Components.swift:69-146`](../../Ludi%20Boards/Redesign/Components.swift) (presence hardcoded in TopBar, lines 105-109), [`BoardScreenState.swift:18-45`](../../Ludi%20Boards/Redesign/BoardScreenState.swift), [`Panels.swift:68-194`](../../Ludi%20Boards/Redesign/Panels.swift), [`TacticalBoardView.swift:138-184`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — editor mode (Plan/Animate/Present), `selectedToolId`, `libraryOpen`, `isDraw`, `shapeSubType`, gesture lock are all `@Published`/`@State` UI-only. **Decision: keep transient** — these are ephemeral UI state, not board content; persisting them is anti-feature. Hardcoded presence is cosmetic stub, not a model gap.
- [`CoreEngine/.../Models/ManagedView.swift:19-70`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift) — placed objects/tools/discs fully persisted and codable; Firebase-ready as-is. **But** `ManagedViewAction.dateCreated` (line 76) is a `String`. **Change:** confirm it is ISO8601-normalized and add/confirm an ordering index (`orderIndex`) so Firebase can order actions deterministically for animation replay.
- [`CoreEngine/.../Models/Recording.swift:11-59`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift) — `Recording`/`RecordingAction` fully persisted and codable; Firebase-ready as-is. No change needed beyond timestamp-normalization audit.
- [`Ludi Boards/Redesign/RosterPlayer.swift:14-22`](../../Ludi%20Boards/Redesign/RosterPlayer.swift) — roster model persisted and codable (per TASK-031); Firebase-ready as-is.
- **Undo/redo:** there is no persisted undo index. **Change:** add an undo-index Realm field (or reuse `ManagedViewAction.orderIndex`) so redo can be implemented and so action ordering survives a reload.

## Scope
**In scope:**
- **Board-settings round-trip (critical):** wrap `setColor` / `setFieldLineColor` / `setBoardBgView` mutations in Realm writes to the backing `ActivityPlan` row, and confirm `loadBoardSettings` reads them back correctly (round-trip survives reload).
- **Canvas transform persistence:** migrate `canvasScale` / `canvasOffset` / `canvasRotation` from pure `@Published` to `@AppStorage` (device-local) so viewport survives restart.
- **Timestamp normalization:** confirm `ManagedView.dateUpdated`, `ManagedViewAction.dateCreated`, and `ActivityPlan.dateUpdated` are ISO8601 strings (normalize any that aren't) for cross-device ordering.
- **Ordering index for actions:** confirm/add `ManagedViewAction.orderIndex` so action sequence is deterministic and redo is implementable.
- **Audit + document:** produce a short coverage matrix (model · persisted? · codable? · Firebase-shaped?) for `ManagedView`, `RosterPlayer`, `Recording`/`RecordingAction`, `ManagedViewAction`, `ActivityPlan`, `CoreUser`, canvas transform, and UI/session state, with each marked wired / partial / intentionally-transient / out-of-scope.

**Out of scope (Firebase wiring is OUT everywhere — Firebase-ready only):**
- Any Firebase / RTDB / Firestore write, read, listener, or SDK call. **None.** This task only makes the models Firebase-*ready*.
- Session-context → `CoreUser` Realm sync (`currentUserId`/`currentActivityId`), and the per-board access / `Participant` model — belongs with TASK-037 (sharing/links).
- Multi-device canvas-transform *sync* (a `TransientBoardState` Realm model) — deferred; device-local `@AppStorage` only this round.
- Share / export implementation.
- Persisting UI/panel state (mode, `selectedToolId`, `libraryOpen`, draw mode, gesture lock) — decided transient by design.
- Real presence in TopBar (replacing the hardcoded stub).

## Files expected to change
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` — Realm writes in the three setters; `@AppStorage` for canvas transform.
- `Wrlds/Realm/models/ActivityPlan.swift` — only if a timestamp/field needs normalization (no structural change expected).
- `CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift` — confirm/add `ManagedViewAction.orderIndex`; normalize `dateCreated`/`dateUpdated` if needed.
- `Ludi Boards/Redesign/RedesignBoardCanvas.swift` — if canvas-transform bindings move to `@AppStorage`.
- Audit doc (coverage matrix) under `docs/audits/`.

## Acceptance criteria
- [ ] Changing the board background color via `setColor` writes the new RGBA to the backing `ActivityPlan` Realm row, and the change survives a board reload (`loadBoardSettings` reads it back — no revert to the old color).
- [ ] Changing the field-line color via `setFieldLineColor` and the background via `setBoardBgView` likewise persist to `ActivityPlan` and survive reload.
- [ ] After a board reload, the live BEO board-settings transients match the `ActivityPlan` row (no in-memory-only drift).
- [ ] `canvasScale` / `canvasOffset` / `canvasRotation` survive an app restart (device-local), and are explicitly documented as device-local, not synced.
- [ ] `ManagedViewAction.orderIndex` exists (added or confirmed) and is populated in sequence, so actions reload in deterministic order.
- [ ] `ManagedView.dateUpdated`, `ManagedViewAction.dateCreated`, and `ActivityPlan.dateUpdated` are ISO8601-normalized strings.
- [ ] A coverage matrix exists marking every model/state surface as wired / partial / intentionally-transient / out-of-scope, with file:line anchors.
- [ ] No Firebase SDK call, import, or path is introduced anywhere in the diff.
- [ ] UI/panel/session state (mode, `selectedToolId`, `libraryOpen`, draw mode, session `@AppStorage`) is unchanged — not forced into Realm.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless, per the project's background-simulator convention — scheme **"Ludi Boards"**, bundle **io.ludi.sol**): open a board, change the background color and the field-line color, then leave and re-open the board (or reload board settings) and confirm the colors **persist** (this is the core regression — today they revert). Confirm zoom/pan survives an app relaunch. Confirm placed tools and recordings still load in order.
3. Grep the diff for `Firebase`/`Firestore`/`Database` imports to confirm none were introduced.

## Open questions / risks
- **Should canvas transform (zoom/pan/rotate) persist across restarts, and should it sync?** Today: no persistence. **Recommendation:** persist device-local via `@AppStorage` so the viewport survives restart; defer multi-device *sync* (a `TransientBoardState` Realm model) to a future phase — viewport is per-device ergonomics, not shared board content, and syncing it would fight two users zooming independently.
- **Does board-settings color mutation need immediate persistence or eventual consistency?** Today: reads from Realm on load but UI mutations never write back, so the round-trip silently reverts. **Recommendation: immediate Realm write in the setters (CRITICAL for Firebase-ready).** Without it, every future Firebase listener would overwrite the user's unsaved change — the round-trip must close in Realm first.
- **Risk — write amplification on color drag:** if `setColor` is called on every slider tick, per-tick Realm writes could thrash. Mitigation: debounce the write to drag-end, or write on commit only. Decide during implementation.
- **Risk — `ActivityPlan` row identity:** the setters must resolve the *correct* `ActivityPlan` (by `currentActivityId`); writing to the wrong/absent row silently no-ops. Guard for the missing-row case (create vs. fail).
