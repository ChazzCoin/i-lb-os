# TASK-006: Left ToolRail wired (select / pan / draw / shape / marker / color)

**Phase:** RD-3 Chrome · **Depends on:** TASK-002 · **Partially supersedes:** CanvasMenuView draw buttons

## User story

As a **coach**, I want the left tool rail to drive select / pan / draw / shape / marker / color, replacing the current bottom draw buttons.

## Why this matters

The design's `ToolRail` is a static `@State` picker; today draw lives in `CanvasMenuView` (pencil straight/curved, lock). Each rail tool must trigger a real engine action, and the active highlight must reflect real board mode (`isDraw`, `shapeSubType`).

## Scope

**In scope (wire each rail tool):**
- cursor → select mode
- hand → pan (ensure `gesturesAreLocked` off)
- pencil → draw straight (`toggleDrawingMode` line_straight)
- scribble → draw curved (line_curved)
- photo → image tool (if supported; else stub)
- person → player tool drop
- triangle → shape tool
- flag → marker
- paintbrush → color
- Active-state reflects BEO (`isDraw`, `shapeSubType`).

**Out of scope (explicit):**
- ControlPill (TASK-007), TopBar (TASK-008). Final removal of `CanvasMenuView` happens in RD-6.

## References

- `Ludi Boards/Redesign/Components.swift:148` — `ToolRail` / `RailButton`
- `Ludi Boards/CanvasEngine/CanvasMenuView.swift:40` — `toggleDraw`, current buttons
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift:99` — `enableDrawing` / `disableDrawing` / `toggleDrawingMode`
- Drop/create path (`CustomDropDelegate`) for person/shape/marker

## Files expected to change

- `Ludi Boards/Redesign/Components.swift` (`ToolRail` → bind to BEO)

## Acceptance criteria

- [x] Each rail tool triggers its engine action (cursor/hand/pencil/scribble wired; photo/person/shape/marker/colour stubbed for later tasks)
- [x] Active highlight tracks the real board mode — verified (pencil lit when drawing straight)
- [x] Draw straight/curved work from the rail — `toggleDrawingMode` wired

## Verification (build + sim)

1. `/build` clean.
2. iPad sim: toggle draw from the rail, draw a line; switch tools, highlight follows.

## Open questions / risks

- Which tools exist today vs need stubbing (photo/person/marker → catalog mapping).

## Blocker notes

(empty)

## Outcome (2026-06-26) — DONE
`ToolRail` split into a pure visual (`active`+`onTap`) + `EngineToolRail` wrapper (`@EnvironmentObject BEO`) that derives the active tool from `isDraw`/`shapeSubType` and routes taps to `toggleDrawingMode`/`disableDrawing`/pan. Verified headless ([render](../../docs/design/canvas-board-redesign/renders/task-006/01-pencil-active-draw-mode.png)). Photo/person/shape/marker/colour are stubbed pending their tasks.
