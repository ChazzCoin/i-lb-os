# TASK-003: Vector pitch reconciled with FieldOverlayView + Sports registry

**Phase:** RD-2 Canvas & tokens · **Depends on:** TASK-002

## User story

As a **coach**, I want the crisp vector soccer pitch from the design rendered as a board background through the Sports registry, so the redesign's field replaces the current soccer background.

## Why this matters

The design ships `PitchMarkings`/`PitchTurf` (vector, normalized 724×464). The app renders backgrounds via `FieldOverlayView` + `boards.getAllBoards()[boardBgName]`, keyed off the `Sports` registry. The pitch must become a registered board background that shares the tools' coordinate space.

## Scope

**In scope:**
- Register `PitchView`/`PitchMarkings`/`PitchTurf` as a Sports-registry soccer board background (full).
- Half-pitch variant.
- Share the tools' coordinate space (per `BoardEngineView` note: background must share tools' coords or spawned tools miss the field).
- Honor `boardFeildRotation`.

**Out of scope (explicit):**
- Player tokens (TASK-004); non-soccer sports' fields.

## References

- `Ludi Boards/Redesign/PitchView.swift`
- `Ludi Boards/CanvasEngine/BoardEngineView.swift:47` — `FieldOverlayView` + `getAllBoards()` + `rotationEffect`
- `Ludi Boards/Providers/Sports.swift` — board-background registry

## Files expected to change

- `Ludi Boards/Redesign/PitchView.swift`
- `Ludi Boards/Providers/Sports.swift` (register pitch)
- `FieldOverlayView` bridge (if needed)

## Acceptance criteria

- [x] Soccer board shows the vector pitch — renders in the **live engine path** ([full](../../docs/design/canvas-board-redesign/renders/task-003/01-full-pitch-live-engine.png))
- [~] Dropped tools land on the field (shared coords) — **structural**: identical `boardHeight×boardWidth` frame convention as the working `SoccerFieldFullView`, so tools share the field's coordinate space. Live tool-on-pitch proof deferred to TASK-010 (drag-to-board) — a fresh board has no tools to show
- [x] Field rotation works; half-pitch selectable — rotation via `BoardEngineView`'s uniform overlay `.rotationEffect`; half registered + rendered ([half](../../docs/design/canvas-board-redesign/renders/task-003/02-half-pitch-live-engine.png))

## Verification (build + sim)

Verified **headless via simctl**: launched the LIVE `CanvasEngine` board
(no `REDESIGN_BOARD`) with `REDESIGN_BG="Soccer Redesign Full View"` /
`"…Half View"` and confirmed both render through `FieldOverlayView` →
`getAllBoards()` → `RedesignSoccerBoardView`.

## Outcome (2026-06-25)

**Decision — add, don't replace.** The live board's default `boardBgName`
is `"Sol"` (not a soccer field), so registering new soccer entries can't
disturb shipping (consistent with TASK-002). Added `"Soccer Redesign Full
View"` + `"Soccer Redesign Half View"` to `Soccer.boards`/`.minis`; the
RD-6 cutover makes the full pitch the redesign board's default.

**Open question resolved.** The 724×464 markings are resolution-independent
(scale to any frame), so there's no hard coordinate mapping — I mirrored
`SoccerFieldFullView`'s `frame(width: boardHeight, height: boardWidth)` so
tools land identically. Board is 5000×6000; design aspect (1.56) vs engine
field (1.54) → negligible stretch.

**Scope note.** Registered the field *surface only* (`RedesignPitchSurface`
= turf + markings) — the scaffold's `PitchView` keeps drawing tokens/ball/
arrows, which move to TASK-004 (tokens) / TASK-005 (arrows).

**Files:** `Redesign/RedesignPitchBackground.swift` (new),
`Providers/Sports.swift`, `CanvasEngine/BoardEngineView.swift` (DEBUG hook),
`…xcodeproj/project.pbxproj`.

## Blocker notes

(empty)
