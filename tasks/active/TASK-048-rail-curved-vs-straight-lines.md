# TASK-048: Rail squiggly icon draws curved lines; straight icon draws straight lines

**Phase:** FB — Functional board · **Severity:** MEDIUM · **Size:** small · **Depends on:** none · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **the squiggly-line rail icon to draw a curved line and the straight-line icon to draw a straight line** so that **the preview I drag matches the line I actually get, instead of always seeing a straight rubber-band even when I picked the curved tool**.

## Why this matters
The rail already routes the two icons correctly: tapping the curved icon sets `BEO.shapeSubType = "line_curved"` and the straight icon sets `"line_straight"` ([`Components.swift:228-234`](../../Ludi%20Boards/Redesign/Components.swift)), and the **saved** line is correct — it persists with the chosen `subToolType` ([`BoardEngineView.swift:320`](../../Ludi%20Boards/CanvasEngine/BoardEngineView.swift)) and renders through the right view (`LineDrawingManaged` vs `CurvedLineDrawingManaged`, [`MVEngineBuilder.swift:163-172`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift)).

The gap is purely the **live preview** drawn while dragging. That preview is hardcoded to `path.addLine` ([`BoardEngineView.swift:38-41`](../../Ludi%20Boards/CanvasEngine/BoardEngineView.swift)) and ignores `BEO.shapeSubType`, so a coach who picks the curved tool drags a straight red rubber-band and only sees the curve after release. The fix is cosmetic but real: make the preview reflect the tool that's active.

## Findings / current state
- [`Ludi Boards/CanvasEngine/BoardEngineView.swift:38-41`](../../Ludi%20Boards/CanvasEngine/BoardEngineView.swift) — the temporary "line being drawn" `Path` always calls `path.move(to: drawingStartPoint)` + `path.addLine(to: drawingEndPoint)`, with no reference to `BEO.shapeSubType`. **This is the bug.** Change: branch on `BEO.shapeSubType` — keep `addLine` for `line_straight`, use `addQuadCurve` for `line_curved`.
- [`Ludi Boards/Redesign/Components.swift:228-234`](../../Ludi%20Boards/Redesign/Components.swift) — `EngineToolRail.handleTap` already maps the two rail icons to `toggleDrawingMode(subType: "line_straight")` / `"line_curved")`. Tool routing is **wired**; no change needed here.
- [`Ludi Boards/CanvasEngine/BoardEngineView.swift:295-322`](../../Ludi%20Boards/CanvasEngine/BoardEngineView.swift) — the saved `ManagedView` carries `subToolType = self.BEO.shapeSubType` (line 320) and seeds `centerX/centerY` at the start/end **midpoint** (lines 303-306) so a fresh curve begins visually straight. Saving is **correct**; the preview just doesn't match it.
- [`CoreEngine/.../MVEngineBuilder.swift:163-172`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — genre routing dispatches `line_curved` to `CurvedLineDrawingManaged` and `line_straight` to the straight view. Final render is **correct**.
- [`CoreEngine/.../Lines/CurvedLineToolView.swift:46`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/Lines/CurvedLineToolView.swift) — `CurvedLineDrawingManaged` renders with `path.addQuadCurve(to:control:)`. The new preview should mirror this style so what the coach drags matches what lands.

## Scope
**In scope:**
- Update the temporary preview `Path` in `BoardEngineView.swift:38-41` to read `BEO.shapeSubType` and render a straight line (`addLine`) for `line_straight` and a quadratic Bezier (`addQuadCurve`) for `line_curved`, matching the saved curve's control-point convention.

**Out of scope:**
- Rail tool routing (already correct in `Components.swift`).
- The saved-line / persistence path and `subToolType` handling (already correct in `BoardEngineView.swift:295-322`).
- The final render views (`LineDrawingManaged`, `CurvedLineDrawingManaged`) — unchanged.
- Firebase wiring — not touched; this is local preview only and stays Firebase-ready.

## Files expected to change
- `Ludi Boards/CanvasEngine/BoardEngineView.swift`

## Acceptance criteria
- [ ] With the straight-line rail icon active, dragging on the board shows a straight preview (unchanged from today) and saves a `line_straight`.
- [ ] With the squiggly/curved rail icon active, dragging shows a curved preview (`addQuadCurve`), not a straight rubber-band.
- [ ] The curved preview uses a control point consistent with the saved line's convention (midpoint of start/end, per `BoardEngineView.swift:303-306`), so preview and final render agree.
- [ ] The final saved + rendered line is unchanged from current behavior for both tools (no regression to persistence or `subToolType`).
- [ ] No other rail/draw behavior changes.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (scheme **Ludi Boards**, bundle **io.ludi.sol**, verified headlessly per the project's background-simulator convention): on a board, tap the straight-line rail icon and drag — confirm a straight preview and a straight saved line. Tap the curved (squiggly) rail icon and drag — confirm the preview is now curved and the saved line renders curved.

## Open questions / risks
- **Curve shape of the preview.** With the control point at the start/end midpoint, a quadratic Bezier is geometrically identical to a straight segment, so the curved preview would still *look* straight until the control point is later dragged — matching the saved-line convention at `BoardEngineView.swift:303-306`. **Recommendation:** match the saved convention (midpoint control point) so preview === final result; do not fake an obviously-bowed preview, since that would diverge from what actually gets saved and mislead the coach. If user feedback later wants a clearer "this is the curved tool" signal, address it as a separate affordance (e.g. icon/cursor state) rather than distorting the preview geometry.

## Outcome (2026-06-26) — DONE (build verified) — with a follow-up note
Branched the temporary draw-preview Path in BoardEngineView on `BEO.shapeSubType`: `addQuadCurve(control: midpoint)` for `line_curved`, `addLine` for `line_straight`, matching the saved line's control convention. Build clean.
**Follow-up:** because the saved curve seeds its control point at the start/end midpoint, a freshly drawn curved line renders visually STRAIGHT until its control anchor is bent. If "curved icon should produce a visibly curved line on creation" is desired, seed an initial perpendicular bend in the save path (BoardEngineView ~303-306) — out of this task's scope; flag for the user.
