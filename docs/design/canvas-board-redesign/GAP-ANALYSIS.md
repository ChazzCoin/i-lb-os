# Canvas/Board Redesign — Gap Analysis & Deliverables

**Date.** 2026-06-25
**Source design.** `docs/design/canvas-board-redesign/` (Claude Design SwiftUI handoff — three iPad screens: Board, Node selected, Library).
**Live target.** The shipping `CanvasEngine` board (`Ludi Boards/CanvasEngine/*`, `CoreEngine` MVEngine/ManagedView).

## Decisions locked (2026-06-25)

1. **Theme scope = board screen only.** Dark graphite design system applies to the tactical board. Home / nav / settings keep the current SOL-green look for now.
2. **Data = reskin first, roster later.** Map the design onto existing generic `ManagedView` tools now. Teams / rosters / linked-player become a later phase (RD-5) with their own schema work.
3. **Platform = iPad landscape first.** Build for the design's native form. iPhone/portrait is a separate later effort.

## What the design is vs. what ships today

| | Design handoff | Live engine |
|---|---|---|
| Nature | Static, **sample-data** SwiftUI mockup | Live, **Realm-driven** data engine |
| State | `Sample.*` constants | `BoardEngineObject` (BEO) + `@ObservedResults(ManagedView)` |
| Tokens | `BoardToken` (kind/number/x,y fractions) | `ManagedView` (toolType/subToolType/sport, absolute x,y) |
| Render | `PitchView` / `PlayerDisc` | `MVEngine.Display` → `ViewEngine.GenreBuilder` |
| Chrome | `TopBar` / `ToolRail` / `ControlPill` | `CanvasMenuView` (bottom) + `MvSettingsBar` |
| Settings | `PropertiesPanel` | `MvSettingsBar` via `CodiChannel.TOOL_ATTRIBUTES` |
| Add tools | `LibraryPanel` | drop delegate (`CustomDropDelegate.performDrop`) |
| Theme | `Brand` tokens, `GlassPanel`, dark | SOL green/white |
| Fonts | Archivo / Hanken Grotesk / JetBrains Mono | system |

## Design component → engine seam (what to reuse, what's new)

| Design piece | Wire to / replace | Reuse | New work |
|---|---|---|---|
| `Brand` / `GlassPanel` / `CanvasBackground` | board-screen theme | — | scope so it doesn't bleed into home/nav; reconcile `Color(hex:)` vs `CoreEngine ColorProvider.swift:60` |
| `AppFont` (3 fonts) | Info.plist `UIAppFonts` | — | source + bundle `.ttf`, register |
| `PitchView` / `PitchMarkings` / `PitchTurf` | `FieldOverlayView` + `Providers/Sports.swift` | Sports registry (`boards.getAllBoards()`) | vector soccer pitch as a Sports background; half-pitch variant |
| `PlayerDisc` | `ManagedView` tool render via `ViewEngine` | tool builder routing | home/away/GK visual mapping onto `toolColor`; no roster model yet |
| selection ring + `contextToolbar` | engine selection + `CodiChannel.NavStackMessage`/`TOOL_ATTRIBUTES` | double-tap → settings open | lime ring overlay; floating context bar (duplicate/link/delete) |
| arrows (`ArrowsOverlay`/`LimeRunShape`) | line-draw (`ShapeTool.line_straight/line_curved`, `BoardEngineView.saveLineData`) | draw gesture + line persistence | style drawn lines to match (lime run, dashed build-up) |
| `ToolRail` (left) | replaces `CanvasMenuView` draw buttons | `BEO.toggleDrawingMode`, drop/create | select/pan/draw/shape/marker/color → engine actions |
| `ControlPill` (bottom) | replaces `CanvasMenuView` zoom/lock/reset | `BEO.gesturesAreLocked`, `canvasScale`, undo/history, record engine | live zoom %, scope/recenter, Record |
| `TopBar` | new top chrome | `BEO.currentActivityId`/session, Sports registry, record engine | breadcrumb, SportChip switch, presence (gated/none on free), Share/export |
| `ModeSwitch` (Plan/Animate/Present) | record/playback engine in BEO | undo/record/playback (built, unreached) | Animate timeline, Present hides chrome |
| `PropertiesPanel` | replaces `MvSettingsBar` | `CodiChannel.TOOL_ATTRIBUTES` (rotation/size/color/delete exist) | new panel layout; linked-player deferred to RD-5 |
| `LibraryPanel` | replaces current tool picker | drop/create path, Sports registry | sport/board switch, equipment/markers grid → drag-to-board |
| `SquadPanel` / roster / linked-player | **RD-5 (later)** | — | teams/players/rosters model, link to tokens |

## Deliverables → phases

- **RD-1 Foundation** — TASK-001 design system (tokens, board-scoped theme, `Color(hex:)` reconciliation, fonts); TASK-002 iPad-landscape board scaffold (redesigned `TacticalBoardView` behind a flag, canvas bg + dot grid, floating-chrome layout, right-panel state machine).
- **RD-2 Canvas & tokens** — TASK-003 vector pitch + Sports reconciliation; TASK-004 token reskin + selection ring + context toolbar; TASK-005 drawn-line/arrow styling.
- **RD-3 Chrome** — TASK-006 left ToolRail wired; TASK-007 bottom ControlPill wired; TASK-008 TopBar + EditorMode wired.
- **RD-4 Panels** — TASK-009 Properties panel replaces `MvSettingsBar`; TASK-010 Library panel wired.
- **RD-5 Roster (later)** — TASK-011 roster model + Squad panel + linked-player.
- **RD-6 Cutover** — TASK-012 make redesign the live board, retire old chrome, remove harness.

## Current setup state (done 2026-06-25)

- Handoff imported to `docs/design/canvas-board-redesign/` + isolated build-target group `Ludi Boards/Redesign/` (7 files, compiles clean).
- `AppIcon-Board` asset added. `RedesignPreviewEntry.RedesignRootView` renders all three screens (env `REDESIGN_SCREEN`).
- Shipping `@main` unchanged (`CanvasEngine()`). Nothing live is wired yet — that's RD-1…RD-6.
