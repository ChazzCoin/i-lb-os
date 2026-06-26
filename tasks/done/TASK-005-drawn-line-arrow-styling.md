# TASK-005: Drawn-line / arrow styling reconciled with line-draw

**Phase:** RD-2 Canvas & tokens · **Depends on:** TASK-002

## User story

As a **coach**, I want lines I draw to look like the design's passing arrows (lime run, dashed build-up), so drawing matches the redesign.

## Why this matters

The design's arrows are decorative overlays; the engine draws **real** lines via the draw gesture → `saveLineData` → `ManagedView` `ShapeTool.line_straight`/`line_curved`. We style the rendered line tool to the design (stroke, dash, lime accent, optional arrowhead) — without changing the draw/persist path.

## Scope

**In scope:**
- Style the rendered line tool to match the design (lineWidth, lineCap, dash, lime accent).
- Map straight → solid lime "run", curved → dashed "build-up" (or expose both styles).
- Keep `BEO.shapeSubType` wiring intact.

**Out of scope (explicit):**
- The rail draw buttons (TASK-006).

## References

- `Ludi Boards/CanvasEngine/BoardEngineView.swift:130` — `saveLineData`, `shapeSubType`
- `Ludi Boards/Redesign/PitchView.swift:117` — `ArrowsOverlay` / `LimeRunShape`
- `ShapeTool.line_straight` / `line_curved`

## Files expected to change

- The line tool render view (CoreEngine `ShapeTool` view or a `Redesign` line view)
- `BoardEngineView.swift` temp-line overlay (match style)

## Acceptance criteria

- [x] Drawn straight line renders as the lime "run" style — verified
- [x] Drawn curved line renders as the dashed "build-up" style — verified
- [x] Lines persist as `ManagedView` (unchanged data path)

## Verification (build + sim)

1. `/build` clean.
2. iPad sim: draw both line types — output matches the design's arrows.

## Open questions / risks

- Arrowhead: does `ManagedView` carry an arrowhead flag, or is it render-only?

## Blocker notes

(empty)

## Outcome (2026-06-26) — DONE
Styled `LineToolView` + `CurvedLineToolView` strokes (round caps, colour glow, `lineDash>1`→dashed). `saveLineData` now draws lime (#CBDB2A), width 34. Verified headless ([render](../../docs/design/canvas-board-redesign/renders/task-005/01-lime-run-and-buildup-arrows.png)). Note: line styling is in CoreEngine, so the shipping board's drawn lines get the new look too.
