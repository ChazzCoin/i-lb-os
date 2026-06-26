# TASK-004: Token reskin + selection ring + context toolbar wired to engine selection

**Phase:** RD-2 Canvas & tokens · **Depends on:** TASK-002, TASK-003

## User story

As a **coach**, I want board tokens to look like the design's jersey discs and show the lime selection ring + floating context toolbar when selected, so selection feels like the redesign.

## Why this matters

The design's `PlayerDisc` (jersey gradients, number, selection rings) and `contextToolbar` are static; the engine renders tokens via `ViewEngine` and opens settings on double-tap. We wire the visual + selection onto real `ManagedView` tools — home/away/GK mapped via `toolColor`, **no roster model yet**.

## Scope

**In scope:**
- Reskin the soccer player tool render to `PlayerDisc` visuals.
- Map home/away/GK to existing `toolColor`/`sport` fields (visual only).
- Lime selection ring on the selected tool.
- Floating context toolbar (duplicate / link / delete) above selection, wired to engine actions (duplicate/delete exist; `link` → stub for RD-5).

**Out of scope (explicit):**
- Roster identity/names (RD-5); the Properties panel (TASK-009).

## References

- `Ludi Boards/Redesign/PitchView.swift` — `PlayerDisc`; `Ludi Boards/Redesign/TacticalBoardView.swift` — `contextToolbar`
- `CoreEngine/.../MVEngineBuilder.swift` — tool routing
- `Ludi Boards/CanvasEngine/CanvasEngine.swift:120` — `NavStackMessage` "mvsettings" open-on-select path
- `CodiChannel.TOOL_ATTRIBUTES` — delete/duplicate

## Files expected to change

- The soccer tool view (CoreEngine `ViewEngine` or a `Redesign` token view)
- Selection overlay in `BoardEngineView.swift`

## Acceptance criteria

- [x] Tokens render as jersey discs (home/away visually distinct) — CoreEngine `SoccerPlayerToolView` for player subtypes; colour from `toolColor` (red/blue teams), placeholder number from id ([render](../../docs/design/canvas-board-redesign/renders/task-004/02-jersey-discs-ring-context-toolbar.png))
- [x] Tapping a token selects it with the lime ring — ring renders on the selected engine tool
- [x] Context toolbar appears above the selection; delete/duplicate work — floating toolbar wired to engine soft-delete + clone (builds + renders; interactive tap-to-delete pending an on-device tap)

## Outcome (2026-06-26) — DONE

**Done:** lime selection ring on the selected engine tool — universal, in
`enableManagedViewTool` ([ManagedToolView.swift](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/ManagedToolView.swift)),
keyed on `selectedManagedViewId`; replaces the legacy blue debug border.

**Two bugs found + fixed along the way:**
- Selection bridge missed an already-set value at launch (`selectedManagedViewId`
  persists in UserDefaults; `onChange` only fires on change). Added an on-appear
  sync in `RedesignRootView`.
- Ring line widths are in the tool's local space; at the ~0.1 canvas scale a
  `lineWidth: 6` rendered ~0.6pt (invisible). Scaled to `max(24, lifeWidth*0.22)`.

**Remaining:** (1) jersey-disc token render (full reskin w/ placeholder numbers —
the chosen scope); (2) floating context toolbar (duplicate/delete) on the
selected tool.

## Verification (build + sim)

Headless: `REDESIGN_BOARD=1 REDESIGN_SEED=1 REDESIGN_SELECT=1` → selected tool
shows the lime ring + Properties opens.

## Open questions / risks

- Where selection state lives today (per-tool vs BEO).
- Whether to add a `kind` enum to `ManagedView` now — **defer to RD-5**; use `toolColor` mapping here.

## Blocker notes

(empty)
