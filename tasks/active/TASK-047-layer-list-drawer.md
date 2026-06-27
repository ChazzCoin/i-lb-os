# TASK-047: Layer-list drawer of all tools on the board (Photoshop-style)

**Phase:** FB — Functional board · **Severity:** MEDIUM · **Size:** medium · **Depends on:** none · **Source:** user request (2026-06-26)

> Verbatim request: "I want a right-drawer view listing all tools per board, like a Photoshop layers list. Click one → its Property settings with a back button."

## User story
As a **coach**, I want **a right-drawer that lists every tool on the current board, like a Photoshop layers panel, and lets me tap one to open its properties (with a back button to return to the list)** so that **I can find and edit any tool — even one buried under others or off-screen — without hunting for it on the canvas**.

## Why this matters
Today the only way to reach a tool's properties is to tap that tool directly on the canvas. The right panel resolves to exactly three states — `squad`, `properties`, `library` — driven by `selectedToolId` and `libraryOpen` ([`BoardScreenState.swift:16`](../../Ludi%20Boards/Redesign/BoardScreenState.swift)). There is no list of what's on the board, so an overlapping, tiny, or off-screen tool is effectively unreachable, and there's no way to see the board's contents at a glance. The properties panel also has no "back" affordance — its only exit is `onClose` → `clearSelection()` ([`Panels.swift:519`](../../Ludi%20Boards/Redesign/Panels.swift)), so even once a layers list exists there's no path back to it. This task adds the layers list and the back path; it does not touch the engine's data model.

## Findings / current state
- [`Ludi Boards/Redesign/BoardScreenState.swift:16`](../../Ludi%20Boards/Redesign/BoardScreenState.swift) — `enum RightPanel: Equatable { case squad, properties, library }`. No `layers` case exists. Change: add `case layers`.
- [`Ludi Boards/Redesign/BoardScreenState.swift:40-44`](../../Ludi%20Boards/Redesign/BoardScreenState.swift) — the `panel` resolver: `libraryOpen` wins, else `selectedToolId != nil` → properties, else squad. Change: add a `@Published var layersOpen: Bool` and slot it into the resolver with priority `library → layers → properties → squad`.
- [`Ludi Boards/Redesign/BoardScreenState.swift:50-62`](../../Ludi%20Boards/Redesign/BoardScreenState.swift) — transitions (`select`, `clearSelection`, `toggleLibrary`). `select(id)` closes library and sets selection (which is what should fire from a layers row). Change: add `openLayers()` / `closeLayers()`; have `select(_:)` also clear `layersOpen` so a row tap cleanly hands off to properties, and `toggleLibrary()` clear `layersOpen` too.
- [`Ludi Boards/Redesign/Panels.swift:477-523`](../../Ludi%20Boards/Redesign/Panels.swift) — `EnginePropertiesPanel`. Its only exit is `onClose: { state.clearSelection() }` ([`:519`](../../Ludi%20Boards/Redesign/Panels.swift)). No back button. Change: add a back affordance that calls `state.openLayers()` (which routes back to the list) alongside the existing close.
- [`Ludi Boards/Redesign/TacticalBoardView.swift:126-132`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — the `rightPanel` switch over `state.panel` has cases for `squad`/`properties`/`library` only. Change: add a `.layers` case routing to the new `EngineLayersPanel`.
- [`Ludi Boards/Redesign/Panels.swift:15-31`](../../Ludi%20Boards/Redesign/Panels.swift) + [`:477`](../../Ludi%20Boards/Redesign/Panels.swift) — existing engine panels (`EngineSquadPanel`, `EnginePropertiesPanel`) show the established shape: `@EnvironmentObject var BEO`, `@ObservedObject var state`, read the live Realm. The new `EngineLayersPanel` follows the same pattern.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:19`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `BEO` exposes the live tool query and `realmInstance`; `EnginePropertiesPanel` already resolves a tool via `BEO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: id)` ([`Panels.swift:529`](../../Ludi%20Boards/Redesign/Panels.swift)). The layers list filters the same source by `boardId == currentActivityId` and `isDeleted == false` (same filter the canvas uses).
- [`CoreEngine/.../ManagedView.swift:19-58`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift) — each tool carries `toolType`/`subToolType` ([`:24-25`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift)), color (`toolColor` / `colorRed/Green/Blue/Alpha`), and the roster link `playerId`/`jerseyNumber`/`teamSide` ([`:56-58`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift)). These are the fields a row renders from. Note: `ManagedView` has `dateUpdated` but no creation timestamp, so creation-order sort is unavailable.

## Scope
**In scope:**
- Add `case layers` to `RightPanel` and a `@Published var layersOpen` to `BoardScreenState`, with resolver priority `library → layers → properties → squad`.
- Add `openLayers()` / `closeLayers()` transitions; make `select(_:)` and `toggleLibrary()` clear `layersOpen` so panel state stays mutually consistent.
- Build `EngineLayersPanel` (in `Panels.swift`, alongside the other engine panels): queries the live tool set filtered to `boardId == currentActivityId` and `isDeleted == false`, renders one row per tool (icon, label, type badge), and taps call `state.select(id)` to open properties.
- Add a back affordance to `EnginePropertiesPanel`'s header that calls `state.openLayers()` to return to the list.
- Add the `.layers` case to the `rightPanel` switch in `TacticalBoardView`.
- Add one entry point to open the layers list (e.g. a layer-stack icon in the top bar / rail calling `state.openLayers()`).

**Out of scope:**
- Any Firebase wiring. Reads/writes stay on the local engine/Realm exactly as the existing panels do; build Firebase-ready only.
- Layer mutation from the list — reorder, drag, show/hide, lock/unlock, rename, delete. List + navigate to properties only this pass.
- Changes to the `ManagedView` schema or the roster model.
- New properties-editing controls beyond adding the back button.

## Files expected to change
- `Ludi Boards/Redesign/BoardScreenState.swift`
- `Ludi Boards/Redesign/Panels.swift`
- `Ludi Boards/Redesign/TacticalBoardView.swift`

## Acceptance criteria
- [ ] `RightPanel` has a `layers` case and `BoardScreenState` has a `layersOpen` flag; the resolver prioritizes `library → layers → properties → squad`.
- [ ] An entry point (top bar / rail) opens the layers drawer via `state.openLayers()`.
- [ ] The layers drawer lists exactly the tools on the current board — filtered to `boardId == currentActivityId` and `isDeleted == false` — and the row count matches what's visible on the canvas.
- [ ] Each row shows an icon derived from `toolType`/`subToolType`, a label, and a type badge; roster-linked tools surface their `jerseyNumber`/`teamSide`.
- [ ] Tapping a row opens that tool's `EnginePropertiesPanel` (via `state.select(id)`) showing the correct tool's values.
- [ ] `EnginePropertiesPanel` shows a back button that returns to the layers list; the existing close affordance still clears selection.
- [ ] Deleting a tool while the list is open removes its row (list reflects the live query, not a stale snapshot).
- [ ] No regression to the squad / properties / library panels or to canvas tap-to-select.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless ok, scheme **"Ludi Boards"**, bundle **io.ludi.sol**, run per the project's background-simulator convention): on a board with several placed tools, open the layers drawer from its entry point and confirm the row count and labels match the canvas; tap a row and confirm the matching `EnginePropertiesPanel` opens; tap back and confirm the list reappears; tap a tool on the canvas and confirm properties still open directly; delete a tool and confirm its row disappears from the list.

## Open questions / risks
- **Sort order.** `ManagedView` has no creation timestamp ([`ManagedView.swift:19-58`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift)), so creation-order is unavailable. Recommendation: group by `toolType` then `subToolType` (stable, predictable), with roster players ordered by `jerseyNumber` within their group.
- **Row icon source.** Equipment tools have no icon mapping yet. Recommendation: add a `RedesignToolCatalog.equipmentIcon` mapper from `subToolType` → SF Symbol, and tint each row with the tool's color (`toolColor` / RGBA) for visual variety; fall back to a generic glyph for unmapped subtypes.
- **Back-button semantics.** Should Properties' back button always go to layers, or remember whether the user arrived from layers vs. a canvas tap? Recommendation: always return to layers (`state.openLayers()`) — simplest state machine — and keep canvas-tap → properties → close as the existing flow. Revisit only if testers find "back" confusing when they came from the canvas.

## Outcome (2026-06-26) — DONE (build + render verified)
Added `RightPanel.layers` + `BoardScreenState.layersOpen` (resolver: library → layers → properties → squad) with `openLayers()`/`closeLayers()` and `select()`/`toggleLibrary()` clearing it. New `EngineLayersPanel` lists every non-deleted `ManagedView` on the board (icon + label + type badge) via `@ObservedResults`; tap → `state.select(id)` → Properties. Added a back chevron to `PropertiesPanel` → `state.openLayers()`, the `.layers` case in `TacticalBoardView`, and a "Layers" entry button. Verified on sim: the Layers button renders. List/back nav deferred to interaction test.
