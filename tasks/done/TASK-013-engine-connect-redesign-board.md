# TASK-013: Engine-connect the redesign board (render live tools + tap-to-select)

**Phase:** RD-2 Canvas & tokens · **Depends on:** TASK-002, TASK-003 · **Blocks:** TASK-004, TASK-006, TASK-007, TASK-009, TASK-010

> **Inserted 2026-06-25.** Discovered while scoping TASK-004: the redesign
> board was a standalone static mockup (`PitchView` + `Sample` tokens), not
> wired to `BEO`/`MVEngine`. Every "wire X" task assumed live engine tools.
> This builds that spine first.

## User story

As a **coach**, I want the redesigned board to render my **real** tools and
let me **tap to select** them, so the chrome/panels wire to live data instead
of a mockup.

## Why this matters

The scaffold (`TacticalBoardView`) draws sample `PlayerDisc` tokens and never
touches the engine. Until the redesign board hosts the live engine canvas
(`MVEngine.Display` over the redesign pitch) and reflects engine selection
into `BoardScreenState`, TASK-004/006/007/009/010 have nothing real to wire to
or verify against.

## Scope

**In scope:**
- Inject `BoardEngineObject` (BEO) into the redesign board path (the redesign
  board shares one BEO).
- Host the live engine board canvas inside the redesign chrome — render real
  `ManagedView` tools via `MVEngine.Display` over the **redesign pitch**
  (`boardBgName = "Soccer Redesign Full View"`) on a dark board color; keep
  canvas pan/zoom.
- Reflect engine selection (`selectedManagedViewId`) ↔
  `BoardScreenState.selectedToolId` (selecting a tool opens Properties; clearing
  closes it).
- Stays behind the DEBUG/redesign entry (not shipping) until RD-6.
- A DEBUG seed hook to place a sample tool for verification (until rail/library
  create tools in TASK-006/010).

**Out of scope (explicit):**
- Token jersey-disc reskin + selection ring + context toolbar (TASK-004).
- Tool creation UI (rail TASK-006, library TASK-010).
- Roster/number (RD-5).

## References

- `Ludi Boards/CanvasEngine/CanvasEngine.swift` — how `BoardEngine` is hosted
  (GlobalPositioningZStack, canvas transform, gestures)
- `Ludi Boards/CanvasEngine/BoardEngineView.swift` — `MVEngine.Display`, board
  background, drop delegate
- `CoreEngine/.../MVObject.swift:73` — `@AppStorage("selectedManagedViewId")`
- `Ludi Boards/Redesign/TacticalBoardView.swift`, `Redesign/BoardScreenState.swift`

## Files expected to change

- `Ludi Boards/Redesign/TacticalBoardView.swift` (host engine canvas)
- `Ludi Boards/Redesign/BoardScreenState.swift` (selection bridge)
- `Ludi Boards/Redesign/RedesignPreviewEntry.swift` (inject BEO)
- possibly a small `Redesign/RedesignBoardCanvas.swift` bridge view

## Acceptance criteria

- [x] The redesign board renders real engine tools over the redesign pitch — [render](../../docs/design/canvas-board-redesign/renders/task-013/01-engine-board-with-chrome-and-tools.png)
- [x] A seeded/created tool appears as a live `ManagedView` (not sample data) — 6 seeded soccer jerseys via `MVEngine.Display`
- [x] Tapping a tool sets engine selection AND opens the Properties panel — bridge verified ([render](../../docs/design/canvas-board-redesign/renders/task-013/02-selection-opens-properties.png)); clear direction implemented (`onChange` nil → clears engine selection), interactive close pending TASK-004
- [x] Shipping `CanvasEngine` board unaffected — `boardBgOverride` nil + seed/select DEBUG+env-gated by default

## Verification (build + sim)

Headless: `REDESIGN_BOARD=1 REDESIGN_SEED=1` → engine tools render over the
redesign pitch inside the chrome; `+REDESIGN_SELECT=1` → first tool selected,
Properties panel opens automatically (bridge works).

## Outcome (2026-06-25)

**The redesign board is now a live engine board.** New `RedesignBoardCanvas`
hosts `BoardEngine` (→ `MVEngine.Display`) in the same 20000×20000
`GlobalPositioningZStack` + canvas transform + pan/zoom gestures as
`CanvasEngine`. Confirmed the entire CoreEngine tool-render subtree needs only
`BEO` (zero other `@EnvironmentObject`s), so the host is minimal.

**Two integration snags fixed:**
1. `GlobalPositioningZStack` hard-frames to 20000×20000 (and draws the
   `AIMYellow` border — the orange edge). As a ZStack sibling it occluded the
   chrome. Fixed by making canvas + background a `.background` layer behind the
   chrome (chrome is primary content).
2. Parent `onAppear` fires BEFORE the child engine's `loadBoardSettings`, so a
   direct `boardBgName` set was overwritten. Added `BEO.boardBgOverride`,
   applied after load.

**Selection bridge** (`RedesignRootView`): `@AppStorage("selectedManagedViewId")`
↔ `BoardScreenState`. Engine→state opens Properties; state→engine clears on
deselect (loop-guarded).

**Scope notes / follow-ups:** Properties shows panel sample data, not the real
tool's attributes yet (TASK-009). The board base colour still shows the green
`"Sol"` default behind the pitch — dark board colour is RD-6 polish. Tool
create/tap come from TASK-006/010.

**Files:** `Redesign/RedesignBoardCanvas.swift` (new),
`Redesign/TacticalBoardView.swift`, `Redesign/RedesignPreviewEntry.swift`,
`CanvasEngine/BoardEngineObject.swift` (`boardBgOverride`),
`CanvasEngine/BoardEngineView.swift` (override apply + DEBUG seed/select),
`…xcodeproj/project.pbxproj`.

## Open questions / risks

- Reuse `BoardEngine` directly vs. a trimmed redesign canvas — `BoardEngine`
  expects `CanvasEngine`'s windowing context; may need a lighter host.
- One shared BEO between the DEBUG `CanvasEngine` button path and the redesign.

## Blocker notes

(empty)
