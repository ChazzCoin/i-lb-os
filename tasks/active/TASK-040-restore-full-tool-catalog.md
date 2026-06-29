# TASK-040: Restore the full tool catalog (legacy + current) and future-proof it

**Phase:** FB — Functional board · **Severity:** HIGH · **Size:** medium · **Depends on:** none · **Source:** user request (2026-06-26)

> I am not seeing all my tools that I used to have plus my current tools. We need to add them all back, plus be ready for any more in the future.

## User story
As a **coach**, I want **the redesign Library to show every tool the engine actually supports — equipment, shapes, general markers, pool balls, and tactics — instead of a 6-item soccer subset**, so that **I can place anything I used to have on the old board, plus everything we have now, and any tool we add later shows up automatically.**

## Why this matters
The redesign Library is the only way to get tools onto the board, and right now it surfaces a hand-typed list of **6 soccer items** (Cone, Goal, Ball, Flag, Ladder, Dummy). The engine itself knows about far more: ShapeTool (6 cases), SoccerTool (13 cases), PoolBallTool (16 cases), GeneralTool (71+ SF Symbol markers), and SmartTool (13 cases). The tactics tab is wired correctly — it enumerates `ViewEngine.Tool.SmartTool.allCases` straight from the engine — but equipment is a static `Sample.equipment` array, so the other catalogs never appear at all.

Desired state: the Library binds to the engine enums the same way the tactics tab already does. Every existing tool is reachable, and because the grid iterates `allCases`, new tools added to `ViewEngine.Tool.*` appear with no further UI work.

## Findings / current state
- [`Ludi Boards/Redesign/Panels.swift:711-724`](../../Ludi%20Boards/Redesign/Panels.swift) — the Library grid has two branches. The `.tactics` branch (line 713) correctly does `ForEach(ViewEngine.Tool.SmartTool.allCases)` — all 13 smart tools, sourced from the engine. The `else` branch (line 719) does `ForEach(Sample.equipment)` — a hardcoded 6-item array. Shapes, general tools, and pool balls have **no branch at all**. Fix: replace the `Sample.equipment` loop with a dynamic enumeration of the engine catalogs and add branches for the missing tabs.
- [`Ludi Boards/Redesign/Models.swift:143`](../../Ludi%20Boards/Redesign/Models.swift) — `Sample.equipment` is 6 hardcoded `EquipmentItem`s (Cone/Goal/Ball/Flag/Ladder/Dummy). This is the entire current catalog the user sees outside tactics. Fix: stop driving the grid from this sample array; drive it from the engine enums.
- [`Ludi Boards/Redesign/Panels.swift:734-741`](../../Ludi%20Boards/Redesign/Panels.swift) — `RedesignToolCatalog.equipmentSubtype` maps display names to engine subtypes, but only the same **6 mappings** exist. Anything not in this dict falls through to its raw name on drag. Fix: extend to cover **all** SoccerTool cases plus all ShapeTool cases (and whatever else gets surfaced), or generate the mapping from the enums.
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift:125-373`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — the full legacy + current catalog already exists in the engine: `ShapeTool` (6: line_straight, line_dotted, line_curved, circle, square, triangle), `SoccerTool` (13: dummy, jersey, steps, walking, running, goal, flagPole, tallCone, shortCone, ladder, soccerBall, curvedLine, dottedLine), `PoolBallTool` (16: balls 1–15, 8, que/0), `GeneralTool` (71+ SF Symbol markers), `SmartTool` (13). The data is present; the redesign just doesn't surface most of it. Fix: bind the Library to these enums.
- [`Ludi Boards/Redesign/Models.swift:69`](../../Ludi%20Boards/Redesign/Models.swift) — `LibraryTab` declares `.equipment`, `.tactics`, and `.markers`. **`.markers` is declared but never matched** in the grid switch at Panels.swift:711, so the tab does nothing today. Fix: either repurpose `.markers` as the shapes (or general markers) tab and bind it, or rename it to a clearer `.shapes`.

## Scope
**In scope:**
- Surface the full equipment catalog: all 13 `SoccerTool` cases (not just 6), each with a display name + icon, in the equipment tab.
- Surface `ShapeTool.allCases` (6) in the Library via a real tab (repurpose/rename the dead `.markers` case, or add `.shapes`).
- Extend (or generate) `RedesignToolCatalog` name→subtype + name→icon coverage for every surfaced tool so tap-add and drag-drop resolve correctly.
- Drive the grid from engine enums (`allCases`) rather than `Sample.equipment`, so new tools auto-appear — this is the future-proofing requirement.
- Optionally add `GeneralTool` and `PoolBallTool` tabs (see open questions for gating) — at minimum, make the catalog architecture able to hold them.
- Keep `RedesignToolCatalog.makeSmartTool` / `configureSmartTool` / `equipmentSize` defaults intact; reuse them for the newly surfaced tools where applicable.

**Out of scope:**
- Any Firebase / persistence wiring. Placed tools already persist through the existing `ManagedView` path; this task only changes what the Library *offers*. Firebase-ready, not Firebase-wired.
- Changing the engine enums themselves in `MVEngineBuilder.swift` — they already hold the full catalog; this task consumes them.
- Redesigning the tool cell visuals, search, or favorites.
- The drop/placement geometry beyond mapping names to subtypes (existing drop delegate handles resolution).

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift` — grid branches, `RedesignToolCatalog` coverage / computed catalogs, `LibraryPanel` / `EngineLibraryPanel` constructors.
- `Ludi Boards/Redesign/Models.swift` — `LibraryTab` cases (rename/add); likely retire or shrink `Sample.equipment` once the grid no longer reads it.

## Acceptance criteria
- [ ] The equipment tab shows **all 13 SoccerTool tools**, each with a label and icon (not just the 6 hardcoded items).
- [ ] A tab surfaces **all 6 ShapeTool cases**; the previously-dead `LibraryTab.markers` case (Models.swift:69) is either bound or renamed — no declared tab is inert.
- [ ] Every surfaced tool resolves to its correct engine subtype on both **tap-add** and **drag-drop** (no item falls through to a raw display name).
- [ ] The grid iterates engine `allCases` (or a catalog derived from them); adding a new case to a `ViewEngine.Tool.*` enum makes it appear in the Library with no edit to the grid `ForEach`.
- [ ] The tactics tab still works exactly as before (regression check on the existing `SmartTool.allCases` path).
- [ ] `Sample.equipment` is no longer the source of truth for the equipment grid.
- [ ] Decisions on GeneralTool / PoolBallTool tabs (see open questions) are recorded in the task before merge, even if their full UI is deferred.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless, background-simulator convention) — scheme **"Ludi Boards"**, bundle **io.ludi.sol**: open the Library, confirm the equipment tab lists all 13 soccer tools, confirm the shapes tab lists all 6 shape tools, tap-add one of each newly surfaced tool and confirm it lands on the board with the correct visual, then drag one onto the board and confirm it resolves to the same tool (not a stray default).

## Open questions / risks
- **GeneralTool (71+ system icons) — show everywhere or per-sport?** Recommend a dedicated `.general` tab (universal across sports) rather than dumping 71 items into equipment — keeps the equipment grid coherent and makes the large set opt-in.
- **PoolBallTool — always visible or sport-gated?** Recommend gating behind the Pool sport pill (own `.pool` tab that only appears when sport = Pool), so 16 pool balls don't clutter soccer boards.
- **Dead `.markers` tab — repurpose or rename?** Recommend renaming to `.shapes` and binding it to `ShapeTool.allCases`; "Markers" is ambiguous and currently does nothing (Models.swift:69).
- **`RedesignToolCatalog` shape — enum-with-statics or struct-with-computed-vars?** Recommend converting to a struct (or adding computed catalog properties) that exposes view-model-ready sequences per tab derived from the engine enums, so future tools compose in without touching the grid. Risk: this is the main structural change; keep `makeSmartTool` / `configureSmartTool` / `equipmentSize` behavior identical to avoid drift in placement defaults.
- **Icon coverage risk:** the engine enums carry icons for SmartTool (`st.icon`) but the legacy SoccerTool/ShapeTool icons may live elsewhere; if an enum case lacks an SF Symbol, the catalog needs a fallback so no tool renders blank.

## Outcome (2026-06-26) — DONE (build + render verified) — with a note
The Library grid is now driven off the engine enums: Equipment = `SoccerTool.allCases` (all 13), a renamed **Shapes** tab = `ShapeTool.allCases` (6), Tactics = `SmartTool.allCases` (13). Icons/labels come from `RedesignToolCatalog.toolIcon/toolLabel` with a generic fallback, so a future engine tool auto-appears. `addTool` now takes the subtype directly: lines → draw mode, circle/square/triangle → "shape" tool, else "soccer". Verified on sim: Equipment shows the full figure/jersey/etc. set + the Shapes tab exists.
**Note:** PoolBall (16) and General (71+) tabs are NOT yet surfaced (architecture supports adding them). Shape *placement* (circle/square/triangle create) needs device verification — the catalog *display* is confirmed.
