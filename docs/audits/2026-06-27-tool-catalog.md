**Target.** Every tool in the catalog (SoccerTool, ShapeTool, SmartTool, PoolBallTool, GeneralTool) — surfaced? wired? rendered? interactive?
**Scope.** `CoreEngine/.../MVEngineBuilder.swift` (5 tool enums + Build dispatch), `.../ManagedViews/{SmartTools,Shapes/ShapeView,Shapes/CircleShapeTool,Shapes/PoolBallToolView,SoccerPlayerToolView,Lines/*}.swift`, `Ludi Boards/Redesign/Panels.swift` (EngineLibraryPanel + RedesignToolCatalog), `Ludi Boards/CanvasEngine/BoardEngineObject.swift` (CustomDropDelegate), `Ludi Boards/Assets.xcassets`.
**Date.** 2026-06-27

# Audit — Full tool catalog

> **TL;DR.** SoccerTool (13) and SmartTool (13) are solid end-to-end. The breakage is concentrated: **ShapeTool's circle/square/triangle render wrong/at-origin** because the views read point/radius geometry the redesign's tap-add never sets; **PoolBall** is invisible (missing image assets) and **GeneralTool** is unreachable — both are unsurfaced in the redesign Library; and **dragged shapes** come in at the wrong size. Lines and all soccer/tactic tools work.

**Scope.** 5 tool families (59+ subtypes), the render dispatch, the redesign Library create paths, the drop delegate, the asset catalog.
**Lines audited.** ~1,600 across engine + redesign + assets

---

## Part 1 — Architectural breakdown

### Render dispatch — toolType → family Build, with an invisible default

A `ManagedView` renders by `toolType`, each family's `Build(name:)` switching on `subToolType`:

```swift
// MVEngineBuilder.swift:95-100  (ViewEngine.ToolBuilder)
case "general": GeneralTool.Build(name: subtype, …)
case "shape":   ShapeTool.Build(name: subtype, …)
case "soccer":  SoccerTool.Build(name: subtype, …)
case "pool":    PoolBallTool.Build(name: subtype, …)
case "tactic":  SmartTool.Build(name: subtype, …)
default:        EmptyText()
```

Every family's `Build` switch also ends in `default: EmptyText()`. So an unknown (or wrong-`toolType`) subtype renders **invisible, silently** — there's no "unknown tool" placeholder. This is the structural reason a mis-wired tool just vanishes.

### Soccer family — players as discs, equipment as assets

`SoccerTool.Build` (MVEngineBuilder.swift:216-250) splits on `playerSubtypes` (jersey/dummy/running/walking/steps → `SoccerPlayerToolView` disc) vs everything else → `Image(name)` from the asset catalog. All 13 imagesets exist in `Ludi Boards/Assets.xcassets` and are populated. The redesign creates these with `toolType:"soccer"` + x/y/width/height, which is exactly what the disc/image path consumes — so this family is consistent tap, drag, render, and interact.

### Shape family — geometry the redesign doesn't supply

`ShapeTool.Build` (MVEngineBuilder.swift:163-171) routes circle → `CircleShapeManagedView`, square/triangle → `ShapeToolManaged`, lines → `LineDrawingManaged`/`CurvedLineDrawingManaged`. The shape views read **point/radius** geometry, not x/y/width/height:

```swift
// ShapeView.swift:33-35  (ShapeToolManaged: square/triangle)
path.move(to: CGPoint(x: MVO.lifeX, y: MVO.lifeY))
path.addLine(to: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY))
if isQuad { path.addLine(to: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY)) }
```

```swift
// CircleShapeTool.swift:33-34  (CircleShapeManagedView)
.frame(width: MVO.radius, height: MVO.radius)
.position(x: MVO.x, y: MVO.y)
```

But the redesign's create path sets only x/y/width/height:

```swift
// Ludi Boards/Redesign/Panels.swift  (EngineLibraryPanel.addTool, isShape branch)
mv.toolType = "shape"; mv.subToolType = subType
mv.x = 2500; mv.y = 3000
mv.width = 200; mv.height = 200   // no startX/endX/centerX, no radius
```

So square/triangle draw a path between **unset (0,0) points** → a degenerate shape near the board origin, and circle renders at its **default `radius`** (not 200) with a **200pt stroke** (width) → a blob. These were built for the legacy draw/drag flow that sets the point/radius geometry via gestures; the redesign's tap-add never does.

### Smart (tactic) family — fully wired

`SmartTool.Build` (MVEngineBuilder.swift:369) routes **every** subtype to the unified `SmartToolManaged`, whose `shape` switch matches all 13 (SmartTools.swift:248-282) with no `EmptyView` fallthrough for valid subtypes. `RedesignToolCatalog.makeSmartTool` sets the start/end/center geometry these need, every icon is a valid SF Symbol, and the TASK-050 hittable handle makes the 5 single-point tools selectable/movable/deletable.

### Pool & General — present in the engine, absent from the redesign

`PoolBallTool` (16) and `GeneralTool` (71) have full `Build` switches in the engine, but the redesign Library only renders Equipment/Shapes/Tactics tabs (no Pool/General tab). They're reachable only through the legacy `CustomDropDelegate` catalog — which has no drag source in the redesign UI, so they're effectively unreachable. PoolBall additionally renders `Image(name)` for ball subtypes `0`–`15` that **have no asset images**, so it would be invisible even if surfaced.

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | 20.0.4 | `ManagedView` tool persistence + live render | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |
| `CoreEngine` | local SPM | the 5 tool enums, `Build` dispatch, all tool views | in-repo `CoreEngine/` |
| `SwiftUI` | iOS SDK | tool rendering (`Path`/`Image`/SF Symbols), gestures | https://developer.apple.com/documentation/swiftui |

---

## Part 2 — Honest assessment

### What's working

- **SoccerTool (all 13)** — players render as discs, equipment as assets; all imagesets present; tap/drag/render/interact consistent. `MVEngineBuilder.swift:216`.
- **SmartTool (all 13)** — unified `SmartToolManaged` renders every subtype, valid icons, correct geometry, and selectable/movable/deletable (incl. the TASK-050 handle for overlay tools). `SmartTools.swift:248`.
- **Lines (line_straight/dotted/curved)** — created via the rail draw mode (not tap-add), which sets the start/end geometry the line views need. `BoardEngineView` draw path.
- **The drop delegate knows the smart/soccer geometry** — dragged tactic + soccer tools land sized and placed correctly. `BoardEngineObject.swift`.

### Findings

```
▌ HIGH      ·  Ludi Boards/Redesign/Panels.swift (EngineLibraryPanel.addTool, isShape)
  circle / square / triangle are created with only x/y/width/height, but
  the shape views read point/radius geometry: ShapeToolManaged draws from
  lifeStartX/lifeEndX/lifeCenterX (ShapeView.swift:33-35) and circle sizes
  from MVO.radius (CircleShapeTool.swift:33). Result: square/triangle draw
  a degenerate path at the board origin (0,0) and circle renders a default-
  radius blob with a 200pt stroke. All three "Shapes" tools are surfaced
  and tappable but render broken.
  └─ on shape create, set startX/startY/centerX/centerY/endX/endY around the
     tap point (and radius for circle), or give the shape views an
     x/y/width/height render path

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:690-696
  CustomDropDelegate.performDrop() has size branches for "tactic" and
  "soccer" but none for "shape" — a DRAGGED circle/square/triangle falls to
  the model default (100×100) while a TAPPED one is 200×200. Inconsistent,
  and compounds the HIGH above for dragged shapes.
  └─ add a "shape" branch mirroring the tap-add geometry

▌ MEDIUM    ·  CoreEngine/.../ManagedViews/Shapes/PoolBallToolView.swift + Assets.xcassets
  PoolBallTool renders Image(name) for ball subtypes "0"–"15"/"8", but no
  matching imagesets exist in Ludi Boards/Assets.xcassets — every pool ball
  renders invisible. Latent because the family is unsurfaced (below), but
  it IS broken the moment it's reachable.
  └─ add the ball assets (or a drawn fallback) before surfacing pool

▌ MEDIUM    ·  Ludi Boards/Redesign/Panels.swift (LibraryPanel grid)
  PoolBallTool (16) and GeneralTool (71) are not surfaced in the redesign
  Library at all — only Equipment/Shapes/Tactics tabs exist. 87 engine tools
  are unreachable from the redesign (reachable only via a legacy drop-delegate
  catalog with no drag source). This is the bulk of "tools I used to have."
  └─ add Pool + General (markers) tabs driven off the enums (as TASK-040 did
     for the others), or consciously cut them

▌ LOW       ·  CoreEngine/.../MVEngineBuilder.swift:100 (and each family Build)
  Every dispatch switch ends in `default: EmptyText()`. A wrong toolType or
  an unknown subtype renders invisible with no signal — which is exactly how
  the shape breakage hides. A debug placeholder ("?" tile) would surface
  mis-wiring instead of swallowing it.
  └─ render a visible unknown-tool placeholder in DEBUG

▌ LOW       ·  CoreEngine/.../MVEngineBuilder.swift:165-166
  line_straight and line_dotted both route to LineDrawingManaged; the dotted
  variant depends on lineDash being set. Confirm a dotted line actually
  renders dashed (not identical to straight) when created from the rail.
  └─ verify lineDash on the dotted-line create path
```

### Tradeoffs worth naming

The catalog carries two eras. The **legacy tools** (Shape, Pool, General) were built for a draw/drag flow where the user's gesture defines the geometry (start→end drag, radius pinch). The **redesign Library** introduced a uniform tap-to-add at board-center with x/y/width/height — which matches Soccer/Smart (they consume x/y/width or have a factory that sets the rest) but **not** the point/radius shapes. So the breakage isn't random: it's exactly the tools whose geometry contract the new create path doesn't satisfy. Either the create path learns each family's geometry, or the shape views gain an x/y/width/height render mode.

---

## Bottom line

Don't treat this as "all tools are broken" — it's a precise, short list. Fix **ShapeTool create geometry** (HIGH — the only *surfaced* broken tools: circle/square/triangle) and the **drag-shape size** (MEDIUM) and the Shapes tab is whole. Then decide on **Pool + General**: either surface them properly (new tabs + pool assets, mirroring TASK-040) or cut them from the catalog so they stop reading as "missing." The `EmptyText()` default is the quiet enabler of all of this — a DEBUG placeholder would have caught the shape breakage on first placement. This is a focused fix batch, not a tool-system rewrite.

**Adjacent observations.** The drop-delegate's legacy catalog still references Pool/General even though the redesign UI offers no drag source for them — dead reachability that should be reconciled when Pool/General are surfaced or cut.
