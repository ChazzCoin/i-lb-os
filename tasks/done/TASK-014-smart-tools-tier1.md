# TASK-014: Smart Tools — Tier 1 (13 tactical tools wired)

**Phase:** Smart Tools · **Status:** ✅ Done (2026-06-26)

## User story

As a **coach**, I want tactical drawing tools — passing/run arrows, zones,
distance/angle measures, spotlight/focus highlights, ladders, stat badges — in
the tool list so I can place them on the board.

## What landed

Imported the **Smart Tool Catalogue** (24 SwiftUI tools) to
[`docs/design/smart-tools/`](../../docs/design/smart-tools/); wired **Tier 1
(13 tools)** end-to-end. The other 4 tiers (multi-point, computed overlays,
generators, FreezeFrame) are deferred — see the README.

**Tools:** Pass Arrow, Run Arrow, Dribble, Curved Pass, Overlap Run, Zone,
Distance, Offside Line, Angle, Spotlight, Focus Ring, Ladder, Stat Badge.

## Acceptance criteria

- [x] Tools appear in a new Library **Tactics** tab ([render](../../docs/design/smart-tools/renders/02-library-tactics-tab.png))
- [x] Each renders correctly on the board at board scale ([render](../../docs/design/smart-tools/renders/01-all-13-on-board.png))
- [x] Placeable (tap-to-add + drag-to-board) with sensible default geometry
- [x] Movable / selectable / deletable; 2-point tools have draggable end anchors
- [x] Shipping render path unchanged for existing tools (additive `type:"tactic"`)

## How

- `SmartTool` catalog enum + `ToolBuilder(in:"tactic")` route in `MVEngineBuilder.swift`.
- `CoreEngine/.../ManagedViews/SmartTools.swift` — the 13 translated shapes/views
  + `SmartToolManaged` dispatcher (geometry from `ManagedView`, board-scale,
  drag/select/delete/anchors).
- Library: `LibraryTab.tactics` + tab-aware grid (`ToolCell` from
  `SmartTool.allCases`); `EngineLibraryPanel.addSmartTool`; `CustomDropDelegate`
  handles `tactic` drops with default geometry.
- Translation done by a 13-agent parallel workflow (`Brand`→hex, `AppFont`→system).

## Verification (build + sim)

Clean build (CoreEngine + app). Headless: `REDESIGN_BOARD=1 REDESIGN_SMART=1`
renders all 13 on the board; `REDESIGN_SCREEN=Library REDESIGN_LIBTAB=tactics`
shows the populated Tactics tab.

## Follow-ups (deferred, documented in README)

- Tier 2 multi-point tools need a serialized `points` field + multi-tap authoring.
- Tier 3 overlays (Heatmap, CoverageShadow) must read live board positions.
- Tier 4 generators (Formation/Grid/ConeTrail) as one-tap stamp actions.
- Tier 5 FreezeFrame ties into record/playback.
- Polish: ZoneRect fill is subtle; per-tool default colours (offside=red etc.);
  custom Properties (zone size, ladder rungs, badge stat) instead of defaults.
