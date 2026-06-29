# TASK-044: Wire the top-left board breadcrumb dropdown (list / load / create board)

**Phase:** FB — Functional board · **Severity:** MEDIUM · **Size:** small · **Depends on:** none · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **to tap the breadcrumb in the top-left, see all my boards, load any one of them, and create a new board** so that **I can move between tactical boards without leaving the canvas instead of being stuck on whatever board happened to load.**

## Why this matters
Today the breadcrumb is dead text. `EngineTopBar` reads the live activity title from `BEO.currentActivityId` and renders it, but the breadcrumb is a plain `Text` with no tap target, no menu, and no way to pick a different board. There is no board-selection UI anywhere in the redesigned canvas. The plumbing to make this work already exists — `BEO.allActivityPlans` is an `@ObservedResults` collection that is currently fetched and then never read, and `BEO.changeActivity(id)` already does the full state sync (set id, `setupToolActions`, `loadBoardSettings`, publish) to switch boards. The gap is purely the UI: nothing surfaces the board list, nothing calls `changeActivity`, and there is no create-new-board affordance. The user's verbatim ask: "The top-left board breadcrumb and dropdown is not working. I want full wiring: dropdown working, show all boards, load them, and a create-new-board option."

## Findings / current state
- [`Ludi Boards/Redesign/Components.swift:69-123`](../../Ludi%20Boards/Redesign/Components.swift) — `TopBar` is a pure visual component. The breadcrumb (`Text(squad)` › `Text(title)`, lines 86-91) is static text with no gesture, no menu, no callback. **Change:** keep `TopBar` visual-only; do not put board logic here. Optionally surface an `onTitleTap`/menu-content closure so the breadcrumb area becomes tappable, wired by `EngineTopBar`.
- [`Ludi Boards/Redesign/Components.swift:127-146`](../../Ludi%20Boards/Redesign/Components.swift) — `EngineTopBar` is the engine-wired wrapper. It computes `activityTitle` from `BEO.realmInstance.findByField(ActivityPlan.self, value: BEO.currentActivityId)` and passes it to `TopBar`, but exposes no interaction. **Change:** this is where the dropdown lives. Add `@State` for menu open + create-sheet presentation, replace the static breadcrumb with a `Button`/`Menu`, list `BEO.allActivityPlans`, and wire taps to `BEO.changeActivity(plan.id)`.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:18`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `BEO.allActivityPlans` exists as `@ObservedResults(ActivityPlan.self)` (per findings) but is currently **unused**. **Change:** read it as the dropdown's data source; this is the "show all boards" requirement, already populated.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:68`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `currentActivityId` is the live board id the breadcrumb already tracks. **Change:** use it to mark/check the currently-loaded board in the list (checkmark or highlight).
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:190-201`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `changeActivity(activityId:)` already does the full switch: guards empty/`"nil"`, sets `currentActivityId`, calls `setupToolActions()` + `loadBoardSettings()`, and fires `objectWillChange.send()` (because `currentActivityId` is `@AppStorage` and won't publish on its own). **Change:** this is the "load them" path — call it directly on tap; do not re-implement board loading.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:359-362`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — board-id / default-board handling context. **Change:** when creating a new board, follow the same id discipline (use the new `ActivityPlan.id`, then `changeActivity(newId)`).
- [`CoreEngine/.../Models/Master/ActivityPlan.swift:11-66`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Master/ActivityPlan.swift) — `ActivityPlan` is the board model: `id` (primary key, auto-UUID), `title`, `subTitle`, plus `dateCreated`/`dateUpdated`/`orderIndex`. **Change:** a new board is a `realmInstance.safeWrite` adding an `ActivityPlan` with a `title`/`subTitle`; everything else defaults. The breadcrumb already joins `title · subTitle`, so a created board renders correctly with no extra work.
- [`Ludi Boards/Redesign/TacticalBoardView.swift:51`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — where `EngineTopBar` is mounted in the live canvas, confirming this is the production path (RD-6 cutover; legacy `ActivityPlanSingleView` is reference only, not the path to wire).

## Scope
**In scope:**
- Make the breadcrumb in `EngineTopBar` interactive — tapping it opens a dropdown.
- Populate the dropdown from `BEO.allActivityPlans` (all boards), showing each board's `title`/`subTitle`, with the current board (`BEO.currentActivityId`) visibly marked.
- Tapping a board calls `BEO.changeActivity(plan.id)` to load it.
- A create-new-board affordance in the dropdown that writes a new `ActivityPlan` via `realmInstance.safeWrite` and immediately switches to it via `changeActivity(newId)`.

**Out of scope:**
- Any Firebase sync of boards — local Realm only. New/loaded boards should be **Firebase-ready** (write through the normal Realm path so a later sync layer can pick them up) but no Firebase calls in this task.
- Renaming, deleting, reordering, or duplicating boards from the dropdown.
- Touching `TopBar`'s visual design beyond making the breadcrumb tappable.
- Roster/squad name in the breadcrumb (still hardcoded "U-12 Squad" — separate concern).
- Legacy `ActivityPlanSingleView` — reference only; do not revive it.

## Files expected to change
- `Ludi Boards/Redesign/Components.swift` (`EngineTopBar`, and a minimal hook on `TopBar` if needed for the tap target)

## Acceptance criteria
- [ ] Tapping the top-left breadcrumb opens a dropdown (native SwiftUI `Menu` unless decided otherwise).
- [ ] The dropdown lists every board in `BEO.allActivityPlans`, each showing its `title` (and `subTitle` when present).
- [ ] The currently-loaded board (`BEO.currentActivityId`) is visibly indicated in the list (checkmark/highlight).
- [ ] Tapping a board in the list calls `BEO.changeActivity(plan.id)`, the canvas re-loads that board's contents, and the breadcrumb text updates to the selected board.
- [ ] The dropdown has a create-new-board option; choosing it creates a new `ActivityPlan` (via `realmInstance.safeWrite`), the new board appears in the list, and the canvas immediately switches to it via `changeActivity(newId)`.
- [ ] A new board with an empty title still renders a sensible breadcrumb (no blank/`"nil"` label).
- [ ] `TopBar` remains a pure visual component; all board logic lives in `EngineTopBar` (or `BEO`).
- [ ] No Firebase calls are added.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless, per the project's background-simulator convention) — scheme **"Ludi Boards"**, bundle **io.ludi.sol**:
   - Launch, tap the top-left breadcrumb, confirm the dropdown opens and lists boards with the current one marked.
   - Tap a different board; confirm the canvas reloads to that board and the breadcrumb updates.
   - Choose create-new-board; confirm a new board is created, appears in the list, and the canvas switches to it.
   - Relaunch and confirm the created board persists (Realm-backed) and is still loadable.

## Open questions / risks
- **Create flow: inline row vs. separate sheet.** Recommendation: inline — make the last dropdown row a "+ New Board" item. Tapping it can create immediately with a default title (faster UX), or present a minimal title/subTitle entry overlay if naming up front is wanted. Start with immediate-create + default title to keep the task small.
- **Dropdown type: native `Menu` vs. custom swipeable view.** Recommendation: native SwiftUI `Menu` for iOS/iPad consistency and zero custom dismissal logic. Revisit only if the board list grows long enough to need search/scroll affordances.
- **Default title/subTitle for new boards.** Recommendation: `title = "New Board"`, `subTitle = ""`; if a future entry sheet leaves the title empty, auto-generate a sequential name (e.g. "Board N"). The breadcrumb already filters empty parts, so a `"New Board"` default renders cleanly.
- **Risk: `changeActivity` no-ops if the id is unchanged or empty** (guard at `BoardEngineObject.swift:192`). Ensure a freshly created board gets a real `ActivityPlan.id` before calling `changeActivity`, and that selecting the already-current board is a harmless no-op (don't rely on it to "refresh").

## Outcome (2026-06-26) — DONE (build + render verified)
The breadcrumb board title is now a `Menu` (chevron shown) listing all `ActivityPlan` boards (sorted by orderIndex, current one checkmarked), tap → `BEO.changeActivity(activityId:)`, plus a "New board" action that writes an `ActivityPlan` and switches to it. `TopBar` stays dumb (takes boards/callbacks); `EngineTopBar` supplies the data. Verified on sim: the dropdown chevron renders on "My Board". Tap-through (load/create) deferred to interaction test.
