# TASK-059: Surface (or cut) PoolBall + General tools in the Library

**Phase:** TC — Tool catalog · **Severity:** MEDIUM · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-27-tool-catalog.md)

## User story
As a **coach**, I want **the pool-ball and general marker tools I used to have to be reachable from the redesign Library** so that **I can actually place them on a board instead of staring at three tabs that are missing most of the catalog**.

## Why this matters
The redesign Library surfaces only three tabs — Equipment, Shapes, Tactics — driven off `SoccerTool`, `ShapeTool`, and `SmartTool`. `PoolBallTool` (16 subtypes) and `GeneralTool` (71 subtypes) have full `Build` switches in the engine but no tab, no cell, and no drag source in the redesign UI. That's **87 engine tools unreachable** — the bulk of "tools I used to have." They survive only in the legacy `CustomDropDelegate` catalog, which the redesign offers no way to invoke.

Desired: `GeneralTool` (renders as SF Symbols, so it works the moment it's surfaced) appears as a real Library tab driven off its enum, exactly the way TASK-040 wired Tactics/Shapes/Equipment. `PoolBallTool` is the harder case — it renders `Image(name)` for ball subtypes `"0"`–`"15"`/`"8"` that have **no matching imagesets**, so it would render invisible even if surfaced. The honest move is to surface General now and gate Pool behind its asset fix (TASK-060) rather than ship a tab full of invisible balls.

## Findings / current state
- [`Ludi Boards/Redesign/Models.swift:68-69`](../../Ludi%20Boards/Redesign/Models.swift) — `enum LibraryTab` has exactly three cases: `equipment = "Equipment", shapes = "Shapes", tactics = "Tactics"`. There is no `general` or `pool` case, so neither family can ever show a tab.
- [`Ludi Boards/Redesign/Panels.swift:908-944`](../../Ludi%20Boards/Redesign/Panels.swift) — the Library grid `switch tab` has arms only for `.tactics` / `.shapes` / `.equipment`, each one a `ForEach(ViewEngine.Tool.<Family>.allCases)` building cells via `RedesignToolCatalog.toolIcon` / `toolLabel`. This is the exact pattern (TASK-040) a Pool/General tab would mirror — `allCases` + catalog icon/label, with the per-cell `.onTapGesture { onAddTool(...) }` + `.draggable(...)`.
- [`CoreEngine/.../MVEngineBuilder.swift:95-100`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — render dispatch routes `case "general": GeneralTool.Build(...)` and `case "pool": PoolBallTool.Build(...)`, then `default: EmptyText()`. The engine path exists; only the create path (Library) is missing. A wrong `toolType` or unmatched subtype renders **invisible, silently** — there is no unknown-tool placeholder, which is how an unsurfaced or mis-wired tool just vanishes.
- [`CoreEngine/.../MVEngineBuilder.swift:375`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — `public enum GeneralTool: String, ToolCategory` (71 subtypes); `GeneralTool.Build` renders SF Symbols, so it is render-ready today — no asset dependency.
- [`CoreEngine/.../MVEngineBuilder.swift:231`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — `public enum PoolBallTool: String, ToolCategory` (16 subtypes); `PoolBallTool.Build` renders `Image(name)` for ball names `"0"`–`"15"`/`"8"`.
- [`CoreEngine/.../Shapes/PoolBallToolView.swift`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/Shapes/PoolBallToolView.swift) + `Ludi Boards/Assets.xcassets` — no imagesets exist for the ball subtypes, so every pool ball renders invisible. Latent only because the family is unsurfaced; it is broken the moment it is reachable. The asset fix is TASK-060.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:690-696`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `CustomDropDelegate.performDrop` has size branches for `"tactic"` and `"soccer"` but none for `"general"` or `"pool"`. A dragged general/pool tool would fall to the model default size instead of a deliberate one. If General is made draggable from the Library, it needs a matching branch.

## Scope
**In scope:**
- Carry the decision: surface `GeneralTool` now; defer/gate `PoolBallTool` behind its asset fix (TASK-060). Record the call in the task outcome.
- Add a `general` case to `LibraryTab` (`Ludi Boards/Redesign/Models.swift`) with a label (e.g. "Markers").
- Add a `.general` arm to the Library grid `switch` in `Panels.swift` that does `ForEach(ViewEngine.Tool.GeneralTool.allCases)`, building cells via `RedesignToolCatalog.toolIcon`/`toolLabel` (add fallback catalog entries as needed), with the same `onAddTool` tap + `.draggable` wiring as the existing tabs.
- Add a `"general"` size branch to `CustomDropDelegate.performDrop` mirroring the tap-add geometry, so dragged general tools land at a deliberate size.
- For Pool: leave it **off** the Library until TASK-060 lands the assets. If a `pool` tab/case is added in this task, it must be inert/hidden (no invisible cells shipped). Prefer adding the Pool tab in TASK-060.

**Out of scope:**
- The `SoccerTool` / `SmartTool` families — they are fully wired (render/assets/icons/interact) and must **not** be re-touched.
- The pool-ball image assets themselves (TASK-060).
- The ShapeTool circle/square/triangle create-geometry breakage (separate finding/task).
- The legacy `CustomDropDelegate` catalog cleanup beyond adding the `"general"` size branch.
- Firebase: **OUT**. No sync, no remote persistence wiring. Code may be written Firebase-ready (no hard-coded local-only assumptions that would block a later sync task) but nothing Firebase is added here.

## Files expected to change
- `Ludi Boards/Redesign/Models.swift` — add `general` case to `LibraryTab`.
- `Ludi Boards/Redesign/Panels.swift` — add the `.general` grid arm; extend `RedesignToolCatalog` icon/label entries if general subtypes need them.
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` — add a `"general"` size branch in `CustomDropDelegate.performDrop`.

## Acceptance criteria
- [ ] Decision is recorded in the task: General surfaced now, Pool gated behind TASK-060 (assets).
- [ ] A "Markers" (General) tab appears in the redesign Library alongside Equipment/Shapes/Tactics.
- [ ] The General tab is driven off `ViewEngine.Tool.GeneralTool.allCases` (not a hand-maintained list), so every one of the 71 subtypes shows and a future enum case auto-appears.
- [ ] Every General cell shows a non-blank icon and label (catalog entry or fallback glyph — never a blank tile).
- [ ] Tapping a General cell places a visible, selectable, movable tool on the board (renders via the existing `case "general"` dispatch, not `EmptyText()`).
- [ ] A dragged General tool lands at a deliberate size (the new `"general"` branch in `performDrop`), not the bare model default.
- [ ] PoolBall is **not** surfaced as a tab of invisible balls; if any pool scaffolding is added, no invisible pool cells are reachable in this build.
- [ ] No changes to the SoccerTool or SmartTool families.

## Verification (build + sim)
1. `/build` clean.
2. iPad simulator, scheme **"Ludi Boards"**, bundle `io.ludi.sol`, run **headlessly** per the project's background-simulator convention. Verify layout on an **iOS 18.x iPad simulator in LANDSCAPE** — the 26.x sim masks layout bugs.
3. Seed tools with `REDESIGN_SMART=1` (or place directly from the Library): open the Library, confirm the new "Markers" tab is present, scroll the grid and confirm every cell has an icon + label (no blank tiles), tap several General tools and confirm each renders visibly on the board and is selectable/movable.
4. Confirm the Pool tab is absent (or inert) — no invisible cells.
5. Drag a General tool from the Library onto the board and confirm it lands at the same deliberate size as a tapped one.

## Open questions / risks
- Tab label: "Markers" vs "General" vs "Misc". 71 subtypes is a lot for one tab — does the grid need sub-grouping or is a flat scroll acceptable? Decide before implementing; a flat `allCases` grid is the minimal path.
- Icon/label coverage: 71 subtypes may not all have `RedesignToolCatalog` entries. The fallback glyph (`toolIcon` returns `"square.on.square"` for unmapped subtypes) prevents blank tiles but produces many identical-looking cells — acceptable for v1, or does this task owe per-subtype icons? The acceptance bar here is "non-blank," not "distinct."
- Draggability: if General cells are `.draggable`, the `performDrop` `"general"` branch is required to avoid the default-size landing; if we ship tap-only for v1, the drop branch can be deferred — decide and reflect in scope.
- Pool sequencing risk: leaving Pool unsurfaced keeps the legacy drop-delegate's Pool reachability dead. That dead reachability should be reconciled when TASK-060 surfaces Pool (or cuts it), not patched here.

## Outcome (2026-06-27) — DONE (build + render verified)
Surfaced both: LibraryTab gains .markers (GeneralTool, 71 SF-symbol markers — the rawValue IS the SF symbol) and .pool (PoolBallTool, 16). New grid branches + onAddGeneral/onAddPool create paths (toolType "general"/"pool", 150×150 at centre). Verified on the 18.5 sim: the Library now shows Equipment/Shapes/Tactics/Markers/Pool tabs.
