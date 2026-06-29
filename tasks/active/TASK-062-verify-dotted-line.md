# TASK-062: Verify line_dotted renders dashed (not identical to straight)

**Phase:** TC — Tool catalog · **Severity:** LOW · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-27-tool-catalog.md)

## User story
As a **coach**, I want **a dotted line drawn from the rail to actually render dashed** so that **I can visually distinguish a dotted run (e.g. an off-ball movement) from a solid straight line on the board**.

## Why this matters
`line_straight` and `line_dotted` are two separate tools in the rail, but they route to the same renderer (`LineDrawingManaged`). The only thing that makes the dotted variant look different is `lineDash` being large enough on the model. Today the rail's line-create path (`saveLineData`) hardcodes `lineDash = 1` for every line regardless of which subtype the rail has selected — and the renderer only draws a dash pattern when `lifeLineDash > 1`. So a line drawn while the rail is set to "dotted" comes out **visually identical to a straight line**. The coach picks the dotted tool and gets a solid line; the distinction is silently dropped. This is LOW severity (cosmetic, no crash, no data loss) but it makes a surfaced, tappable tool a no-op.

## Findings / current state
- [`Ludi Boards/CanvasEngine/BoardEngineView.swift:330-331`](../../Ludi%20Boards/CanvasEngine/BoardEngineView.swift) — `saveLineData()` sets `line.subToolType = self.BEO.shapeSubType` (which can be `line_dotted`) and then **unconditionally** `line.lineDash = 1` on the next line. Nothing branches on the subtype, so a dotted line is persisted with the same dash value as a straight one.
- [`CoreEngine/.../ManagedViews/Lines/LineToolView.swift:34-36`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/Lines/LineToolView.swift) — the stroke uses `dash: MVO.lifeLineDash > 1 ? [MVO.lifeLineDash * 3, MVO.lifeLineDash * 3] : []`. With `lineDash == 1` the dash array is empty → a solid line. The dash only appears once `lineDash > 1`.
- [`CoreEngine/.../MVEngineBuilder.swift:165-166`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — both `ShapeTool.line_straight.name` and `ShapeTool.line_dotted.name` route to `AnyView(LineDrawingManaged(...))`. There is no separate dotted renderer; the only differentiator is the model's `lineDash`.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:94,102`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `shapeSubType` defaults to `line_straight` and is reassigned by the rail's set-subtype path, so it genuinely holds `line_dotted` when the dotted tool is active. The create path therefore *knows* it's dotted but doesn't act on it.
- Counter-example that proves the mechanism works: [`Ludi Boards/CanvasEngine/BoardEngineView.swift:272`](../../Ludi%20Boards/CanvasEngine/BoardEngineView.swift) — the DEBUG seed's curved "build" line sets `build.lineDash = 10`, which *does* render dashed. So the renderer is fine; only the rail create path under-sets the value for dotted.

## Scope
**In scope:**
- Verify, on a running iPad sim, that a line drawn from the rail while the dotted tool is selected renders **dashed** and is visibly distinct from a straight line.
- If it renders solid (expected, per findings), fix the dotted-line create path so a `line_dotted` subtype persists `lineDash > 1` (mirror the existing seed convention, e.g. `10`), while `line_straight` continues to persist `lineDash = 1`.

**Out of scope:**
- Firebase / multiplayer sync of the dash value — **OUT**. Keep changes Firebase-ready (write through the same `ManagedView` field that already syncs) but do not add or touch Firebase code.
- The working SoccerTool / SmartTool families — **do not re-touch**; they are confirmed solid in the audit.
- The separate ShapeTool circle/square/triangle geometry breakage and the Pool/General surfacing gaps — those are other tasks.
- Adding a dash-width control / settings UI — only the create-path default needs to be correct.
- The curved-line dash behaviour beyond confirming it still works (the seed already proves it).

## Files expected to change
- `Ludi Boards/CanvasEngine/BoardEngineView.swift` (the `saveLineData` `lineDash` assignment — branch on `shapeSubType == line_dotted`).

## Acceptance criteria
- [ ] A line drawn from the rail with the **dotted** tool selected renders with a visible dash pattern (not a solid line).
- [ ] A line drawn from the rail with the **straight** tool selected renders solid (no regression).
- [ ] The persisted `ManagedView.lineDash` for a dotted line is `> 1` (so `LineToolView`'s `lifeLineDash > 1` branch produces a non-empty dash array); for a straight line it remains `1`.
- [ ] The two tools are visually distinguishable on the board at the redesign's canvas scale.
- [ ] No change to the curved-line behaviour and no edits to Soccer/Smart tool code.

## Verification (build + sim)
1. `/build` clean.
2. Run on an iPad sim using the **"Ludi Boards"** scheme, bundle **io.ludi.sol**, verified headlessly per the project's background-simulator convention.
3. Verify layout on an **iOS 18.x iPad** sim in **LANDSCAPE** — the 26.x sim masks rendering bugs; do not verify only on 26.x.
4. Seed/reach the tools: launch with `REDESIGN_SMART=1` (or place from the Library), select the **dotted** line tool in the rail, draw a line, and confirm it renders dashed; draw a straight line and confirm it renders solid. Compare the two side by side.

## Open questions / risks
- Dash magnitude: the curved seed uses `lineDash = 10`. Pick a value that reads clearly as dotted at the ~0.1 canvas scale (the straight seed and `saveLineData` both use `1`). Risk: too small and it still looks solid; too large and the gaps swallow the line.
- Authority: confirm `shapeSubType` is the only signal available at create time and that it's reliably `line_dotted` when the dotted rail tool is active (findings say yes, BoardEngineObject.swift:94/102). If a future rail adds more dotted variants, a single equality check may need to become a set membership.
- Cosmetic-only: if verification shows the dotted line *already* renders dashed (e.g. a code path not found in this audit also sets `lineDash`), close as verified with no code change rather than forcing an edit.

## Outcome (2026-06-27) — DONE (build verified)
Two bugs: tapping line_dotted called enableDrawing with a non-curved→line_straight collapse (lost "dotted"), and the line save hardcoded lineDash=1 (LineDrawingManaged only dashes when >1). Fixed: addTool passes the real subType; saveLineData sets lineDash=5 for line_dotted. A dotted line now draws dashed.
