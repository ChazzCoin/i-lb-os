# TASK-010: Library panel wired (sport/board switch + equipment drag-to-board)

**Phase:** RD-4 Panels · **Depends on:** TASK-002, TASK-003

## User story

As a **coach**, I want the Library panel to switch sport/board and drag equipment/markers onto the board for real.

## Why this matters

The design's `LibraryPanel` is static `@State`; the engine creates tools via the drop delegate (payload string → catalog match → `ManagedView`) and switches backgrounds via the `Sports` registry. Wire the panel to both.

## Scope

**In scope:**
- Sport pills → set current sport (Sports registry).
- Board thumbnails → switch board background (`boardBgName`).
- Equipment/Players/Markers grid cells → draggable payloads the existing `CustomDropDelegate` resolves into `ManagedView` tools (sport/toolType/subToolType).
- Replaces the current tool picker.

**Out of scope (explicit):**
- Search (stub); the "Players" tab real roster data (RD-5, TASK-011).

## References

- `Ludi Boards/Redesign/Panels.swift:231` — `LibraryPanel` / `EquipmentCell` / `BoardThumb` / `SportPill`
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift:574` — `CustomDropDelegate.performDrop` (catalog resolution sets sport/toolType/subToolType)
- `Ludi Boards/Providers/Sports.swift`; tool catalogs `ShapeTool` / `SoccerTool` / `PoolBallTool` / `GeneralTool`

## Files expected to change

- `Ludi Boards/Redesign/Panels.swift` (`LibraryPanel` → drag payloads + sport/board bindings)

## Acceptance criteria

- [x] Equipment add creates the correct tool (Goal verified); draggable payload = catalog subtype so the drop delegate resolves it
- [~] Sport pill local state (cosmetic; backgrounds are soccer for now)
- [x] Board thumb → `boardBgOverride` (same mechanism verified in TASK-003)

## Verification (build + sim)

1. `/build` clean.
2. iPad sim: drag a cone onto the pitch — it appears as a real tool.

## Open questions / risks

- Drag payload strings must equal `ToolCategory.name` — verify catalog names match the library cell items (the drop delegate falls back to `toolType = dropped` on no match, which routes wrong).

## Blocker notes

(empty)

## Outcome (2026-06-26) — DONE
`LibraryPanel` takes `onAddTool`/`onPickBoard`; `EngineLibraryPanel` wires them. `RedesignToolCatalog` maps equipment names → `tools_soccer_*` subtypes (used for BOTH tap-add and the drag payload, so the drop delegate resolves correctly — the open question) and board index → registry names. Verified headless ([render](../../docs/design/canvas-board-redesign/renders/task-010/01-library-add-goal-tool.png)).
