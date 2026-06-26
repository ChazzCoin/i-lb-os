# TASK-002: iPad-landscape board scaffold (redesigned TacticalBoardView behind a flag)

**Phase:** RD-1 Foundation · **Depends on:** TASK-001 · **Blocks:** TASK-003..010

## User story

As a **coach on iPad**, I want the redesigned board reachable behind a debug flag in landscape — floating chrome laid out, right panel swapping by state — so later phases can wire real controls into a real frame.

## Why this matters

The handoff's `TacticalBoardView` is a static composition with a demo screen-switcher. We need a real, flagged entry that lays rail/panel/pill over the **live canvas** and swaps Squad/Properties/Library by selection + library state. This is the frame every later phase hangs on. The shipping `@main` stays `CanvasEngine()` until RD-6.

## Scope

**In scope:**
- A board container (adapt `TacticalBoardView`) reachable behind a debug flag from the running app — NOT `@main`.
- `CanvasBackground` + `DotGrid` over the canvas.
- Floating-chrome layout: rail left, panel right, pill bottom.
- Right-panel state machine: no selection → none/Squad placeholder; selection → Properties; library toggle → Library.
- iPad landscape (lock/confirm orientation for this screen).

**Out of scope (explicit):**
- Wiring any control to the engine (RD-3), real pitch (TASK-003), real panels (RD-4).

## References

- `Ludi Boards/Redesign/TacticalBoardView.swift`, `Ludi Boards/Redesign/RedesignPreviewEntry.swift`
- `Ludi Boards/CanvasEngine/CanvasEngine.swift` — current chrome composition over `GlobalPositioningZStack`
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` — BEO

## Files expected to change

- `Ludi Boards/Redesign/TacticalBoardView.swift`
- `Ludi Boards/Redesign/BoardScreenState.swift` (new — panel state machine)
- A debug entry hook (flag/hidden affordance in `CanvasEngine`) — not `@main`

## Acceptance criteria

- [x] A debug affordance opens the redesigned board in landscape from the running app — DEBUG button renders in live `CanvasEngine` ([render](../../docs/design/canvas-board-redesign/renders/task-002/00-debug-button-in-canvasengine.png)); landscape forced via `requestGeometryUpdate` on iPad
- [x] Right panel swaps with a state toggle (none → Properties → Library) — all three resolutions verified headless ([squad](../../docs/design/canvas-board-redesign/renders/task-002/01-squad-default.png) / [properties](../../docs/design/canvas-board-redesign/renders/task-002/02-properties-selected.png) / [library](../../docs/design/canvas-board-redesign/renders/task-002/03-library-open.png))
- [x] Old board remains the default launch experience — `@main` still `CanvasEngine()`; only the DEBUG button or DEBUG env var diverts

## Verification (build + sim)

Verified **headless via simctl** (no GUI control): clean build; booted the
scaffold with `SIMCTL_CHILD_REDESIGN_BOARD=1` + `REDESIGN_SCREEN={Board,
Selected,Library}` and captured all three panel states in landscape.

## Outcome (2026-06-25)

**State machine.** New `BoardScreenState` (ObservableObject) holds
`selectedToolId` / `libraryOpen` / `mode` and resolves `panel`
(library wins → selection → squad). `TacticalBoardView` is now driven by
it (was a static `screen` enum); kept a `screen:` convenience for
previews/renders. `RedesignRootView` owns the `@StateObject` and drives
it via a Clear/Select/Library switcher (replaces the static picker).

**In-app reachability — decision on the open question.** The redesigned
board is presented as a **separate full-screen surface**, NOT overlaid
into the live `GlobalPositioningZStack` windowing. Two DEBUG-only entry
points, default unchanged: (1) a floating button in `CanvasEngine`
(`#if DEBUG`) → `fullScreenCover(RedesignRootView)`; (2) a launch env var
`REDESIGN_BOARD=1` at `@main` for headless harness verification. This
keeps the redesign isolated from live windowing until the RD-6 cutover.

**Landscape.** `requestGeometryUpdate(.iOS(.landscape))` best-effort on
iPad `onAppear`; full orientation lock deferred to RD-6 polish.

**Files:** `Redesign/BoardScreenState.swift` (new),
`Redesign/TacticalBoardView.swift`, `Redesign/RedesignPreviewEntry.swift`,
`CanvasEngine/CanvasEngine.swift` (DEBUG button), `LudiBoardsApp.swift`
(DEBUG env-var branch), `…xcodeproj/project.pbxproj`.

## Blocker notes

(empty)
