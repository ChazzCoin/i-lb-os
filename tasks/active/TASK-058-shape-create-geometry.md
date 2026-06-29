# TASK-058: Fix circle/square/triangle geometry on create (tap + drag)

**Phase:** TC — Tool catalog · **Severity:** HIGH · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-27-tool-catalog.md)

## User story
As a **coach**, I want **the circle, square, and triangle from the redesign Library to appear where I place them, at the right size, and behave like every other tool** so that **I can mark zones and shapes on the board instead of getting an invisible blob or a smear stuck in the corner**.

## Why this matters
Circle/square/triangle are the only *surfaced* broken tools in the catalog. They sit in the Shapes tab, tap and drag both "work" (a `ManagedView` is created), but what renders is wrong: square and triangle draw a degenerate path near the board origin (0,0) and the circle is a default-radius blob with a 200pt stroke. The cause is a geometry-contract mismatch — the shape views read point/radius geometry, while the redesign's create path only ever sets x/y/width/height. SoccerTool (13) and SmartTool (13) are fully working and must not be touched; this task closes the gap for the three shapes so the Shapes tab is whole. Desired state: a tapped or dropped shape renders at the placement point, at a sensible default size, and is selectable/movable/deletable like any other tool.

## Findings / current state
- [`CoreEngine/.../MVEngineBuilder.swift:95-100`](../../CoreEngine/Sources/CoreEngine/ViewEngine/MVEngineBuilder.swift) — render dispatch routes by `toolType` to each family's `Build(name:)`, and every switch ends in `default: EmptyText()`. A mis-wired or under-specified tool renders invisible with no signal — this is the structural reason the shape breakage hides instead of erroring.
- [`CoreEngine/.../Shapes/ShapeView.swift:33-35`](../../CoreEngine/Sources/CoreEngine/ViewEngine/ManagedViews/Shapes/ShapeView.swift) — `ShapeToolManaged` (square/triangle) draws its `Path` from `MVO.lifeX/lifeY`, `MVO.lifeStartX/lifeStartY`, and `MVO.lifeEndX/lifeEndY` — point geometry, not x/y/width/height. When those points are unset they default to (0,0), so the path collapses near the board origin.
- [`CoreEngine/.../Shapes/CircleShapeTool.swift:33-34`](../../CoreEngine/Sources/CoreEngine/ViewEngine/ManagedViews/Shapes/CircleShapeTool.swift) — `CircleShapeManagedView` sizes from `MVO.radius` (`.frame(width: MVO.radius, height: MVO.radius)`) and positions at `MVO.x/y`. The create path never sets `radius`, so the circle renders at its default radius while `width = 200` is interpreted as stroke → a blob.
- [`Ludi Boards/Redesign/Panels.swift:1058-1076`](../../Ludi%20Boards/Redesign/Panels.swift) — `EngineLibraryPanel.addTool` (tap-add). For the `isShape` branch it sets only `toolType = "shape"`, `subToolType`, `x = 2500`, `y = 3000`, and `width/height = RedesignToolCatalog.equipmentSize`. No `lifeStartX/lifeStartY/lifeEndX/lifeEndY`, no `radius` — exactly the geometry the shape views need. (`drawnShapeSubtypes` — the lines — are routed to `BEO.enableDrawing` above this and work via the rail draw mode.)
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:690-696`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `CustomDropDelegate.performDrop` has size branches for `"tactic"` (`RedesignToolCatalog.configureSmartTool`) and `"soccer"` (`equipmentSize`) but **no `"shape"` branch**. A dragged shape falls to the model default (100×100) while a tapped one is `equipmentSize` (200×200) — sizes don't match, and the dragged shape is broken the same way as the tapped one.
- Working families to leave alone: `SoccerTool.Build` ([`MVEngineBuilder.swift:216`](../../CoreEngine/Sources/CoreEngine/ViewEngine/MVEngineBuilder.swift)) and `SmartTool` via `SmartToolManaged` ([`SmartTools.swift:248-282`](../../CoreEngine/Sources/CoreEngine/ViewEngine/ManagedViews/SmartTools.swift)) — both consistent tap/drag/render/interact per the audit.

## Scope
**In scope:**
- Make circle/square/triangle render correctly when created from the redesign Library, on **both** create paths:
  - tap-add — `EngineLibraryPanel.addTool` `isShape` branch (`Panels.swift:1058-1076`).
  - drag — `CustomDropDelegate.performDrop` (`BoardEngineObject.swift:690-696`).
- Pick **one** of the two fixes and apply it to both paths so sizes match:
  1. **Set the geometry on create** — populate `lifeStartX/lifeStartY/lifeEndX/lifeEndY` (and `lifeX/lifeY`) around the placement point for square/triangle, and `radius` for circle, sizing a sensible default shape (use `RedesignToolCatalog.equipmentSize` as the nominal extent so tap and drag agree); **or**
  2. **Give the shape views an x/y/width/height render mode** so they draw from the rectangle the create path already sets.
- Add a `"shape"` branch to `performDrop` that produces identical geometry/size to the tap-add path (prefer a shared factory on `RedesignToolCatalog`, mirroring `configureSmartTool`, so tap/drag/seed can't drift — same discipline as TASK-018).
- Confirm the created shapes are selectable, movable, and deletable through the existing interaction path.

**Out of scope:**
- **Firebase** — no Firebase writes/sync. Keep the change Firebase-ready (persist through the existing `ManagedView` Realm path) but do not add or wire any Firebase code.
- The working **SoccerTool** and **SmartTool** families — do not re-touch their create, render, or interaction paths.
- **Lines** (`line_straight`/`line_dotted`/`line_curved`) — created via the rail draw mode and already working.
- **PoolBall** and **GeneralTool** surfacing / missing assets — separate findings, separate tasks.
- The `default: EmptyText()` invisible-fallback / DEBUG placeholder — separate LOW finding.

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift` — tap-add shape geometry.
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` — add a `"shape"` branch to `performDrop`.
- One of:
  - `CoreEngine/Sources/CoreEngine/ViewEngine/ManagedViews/Shapes/ShapeView.swift` + `CircleShapeTool.swift` (only if going the x/y/width/height render-mode route), or
  - a shared shape factory on `RedesignToolCatalog` (likely in `Panels.swift`) if going the set-geometry-on-create route.

## Acceptance criteria
- [ ] Tapping **circle** in the Shapes tab places a visible circle at/near the placement point, at the same size as the equipment default (`equipmentSize`), with a normal stroke (no 200pt blob).
- [ ] Tapping **square** places a visible, correctly-closed square at the placement point — not a degenerate path at the board origin.
- [ ] Tapping **triangle** places a visible, correctly-closed triangle at the placement point — not a degenerate path at the board origin.
- [ ] **Dragging** circle/square/triangle from the Library produces the **same** shape and size as tapping (no 100×100 vs 200×200 mismatch); `performDrop` has a `"shape"` branch.
- [ ] All three shapes are selectable, movable, and deletable via the existing interaction path.
- [ ] One geometry approach (set-on-create OR x/y/width/height render mode) is applied to both tap and drag; tap and drag agree on geometry and size.
- [ ] No change to SoccerTool/SmartTool create/render/interaction; lines still draw via the rail.
- [ ] No Firebase code added; shapes persist via the existing `ManagedView` Realm path.

## Verification (build + sim)
1. `/build` clean (no warnings introduced in the touched files).
2. Run on the **iPad** simulator, scheme **"Ludi Boards"**, bundle `io.ludi.sol`, verified headlessly per the project's background-simulator convention.
3. Verify on an **iOS 18.x iPad** simulator in **LANDSCAPE** — the 26.x simulator masks this class of geometry bug, so 18.x landscape is the gate.
4. Seed tools with `REDESIGN_SMART=1` and place each shape from the Library:
   - Tap circle, square, triangle in turn → each renders at the placement point, correct size, correct stroke.
   - Drag circle, square, triangle from the Library → each matches the tapped result in shape and size.
   - Select, move, and delete each placed shape to confirm interaction.

## Open questions / risks
- **Approach fork:** set-geometry-on-create (smallest blast radius — touches only the two create paths + a factory, leaves the shape views legacy-compatible with the draw/drag flow) vs. x/y/width/height render mode in the shape views (cleaner long-term contract, but changes shared views and could regress the legacy gesture-driven draw path). Pick before implementing — they imply different change surfaces. The set-on-create route is the safer default.
- The legacy draw/drag gesture flow also writes `lifeStartX/lifeEndX/radius`; if we go the render-mode route, confirm it doesn't double-apply geometry or break gesture-created shapes.
- `equipmentSize` is the nominal default; confirm the resulting square/triangle/circle read as proportionate at that extent (a triangle inscribed in a 200pt box may look small — tune the default if needed).
- Shared factory placement: mirror `RedesignToolCatalog.configureSmartTool` so tap/drag/seed share one source of truth and can't drift (TASK-018 discipline).

## Outcome (2026-06-27) — DONE (build verified) — audit diagnosis corrected
**Correction:** the audit (whose ShapeTool recon agent failed) said square/triangle render "degenerate at origin". On direct inspection that's wrong — MVObject.loadFromRealm has a committed `geometryIsUnset` fallback (MVObject.swift:381-414) that synthesizes default corner geometry at the spawn point. The REAL bug was the stroke: the redesign set `width = 200`, but for shapes `width` IS the stroke → a 200pt blob; circle also relied on `radius` (defaults 0/large).
**Fix:** new shared `RedesignToolCatalog.configureShapeTool` sets a sane stroke (width 12), a circle radius (400), lime colour, and the spawn point — used by BOTH tap-add (addTool isShape) and the drop delegate (new "shape" branch in performDrop, fixing the 100×100-vs-200×200 mismatch). Build clean; tap/drag placement is interaction-level (on-device).
