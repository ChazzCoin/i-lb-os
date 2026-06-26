# Smart Tools — tactical-tool catalogue

Imported from the **Smart Tool Catalogue** handoff (`_original-catalogue.html`,
a self-extracting bundled page). 24 SwiftUI coaching-board tools; the extracted
sources are in [`sources/`](sources/).

## Integration tiers

The 24 split by how they fit the engine's `ManagedView` contract:

| Tier | Tools | Status |
|---|---|---|
| **1 — Drawn geometric** (fit start/center/end, x/y, width) | PassArrow, RunArrow, DribbleArrow, CurveArrow, OverlapRun, ZoneRect, DistanceTool, OffsideLine, AngleTool, Spotlight, FocusRing, AgilityLadder, StatBadge | ✅ **Wired** (TASK-014) |
| **2 — Multi-point** (need a serialized points array) | RunPath, PolyShape/PressingTriangle, DefensiveBlock, TimedSequence | ⬜ deferred |
| **3 — Computed overlays** (read other tokens' live positions) | Heatmap, CoverageShadow | ⬜ deferred |
| **4 — Generators** (one tap → many tools) | Formation, ShapeGrid, ConeTrail | ⬜ deferred |
| **5 — Board-state feature** | FreezeFrame (keyframes) | ⬜ deferred |

(`PlayerToken` ≈ the soccer disc already shipped.)

## How Tier 1 is wired

- **Catalog** — `ViewEngine.Tool.SmartTool` enum (13 cases, `type = "tactic"`,
  subtypes `tactic_*`) in `MVEngineBuilder.swift`. `ToolBuilder(in: "tactic")`
  routes to it.
- **Render** — one dispatcher,
  `CoreEngine/.../ManagedViews/SmartTools.swift › SmartToolManaged`, reads
  geometry from the tool's `ManagedView` (start / center / end points, colour,
  width) and switches on `subToolType`. Everything draws in **absolute board
  space**; catalogue constants (screen-scale ~300pt) are scaled ~8× off the
  tool's stroke width `w` for the 5000–6000-unit board. Drag to move, double-tap
  to select, long-press to delete; start/end anchors edit 2-point tools.
- **Authoring** — Library **Tactics** tab (tap-to-add at board centre + drag
  onto the board). The drop delegate (`CustomDropDelegate`) recognises `tactic`
  subtypes and seeds default geometry. Tools come straight from
  `SmartTool.allCases` (icon + displayName).

## Translation

The 13 catalogue sources were translated to CoreEngine-safe SwiftUI (Brand
tokens → `Color(hex:)`, `AppFont` → system fonts, pure geometry params) by a
13-agent parallel workflow, then synthesised into `SmartTools.swift` with
board-scale tuning.

## Renders (gitignored)

`renders/01-all-13-on-board.png`, `renders/02-library-tactics-tab.png`.
