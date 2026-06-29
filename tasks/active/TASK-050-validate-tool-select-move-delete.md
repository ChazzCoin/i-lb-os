# TASK-050: Validate every tool is selectable, movable, and deletable (spotlight is stuck)

**Phase:** FB — Functional board · **Severity:** HIGH · **Size:** medium · **Depends on:** none (helped by [TASK-047](TASK-047-layer-list-drawer.md) as an alternate selection path) · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **every tool I place — including the spotlight, focus ring, and other overlay tools — to be selectable, movable, and deletable** so that **I can't end up with a tool stuck on my board that I can't touch, move, or remove**.

## Why this matters
The spotlight tool is currently **unreachable**: you cannot select it, move it, or delete it. The root cause is concrete — the `Spotlight` view's only drawn content is a full-board dimming overlay rendered with `.allowsHitTesting(false)`, so every gesture on the smart-tool (tap-to-select, whole-tool move, long-press-to-delete) receives no hits. Because selection is also the only way to open Properties (and thus reach the panel/context-toolbar delete), the tool is a dead object on the board.

This is not just the spotlight. The smart-tool gesture model gives a grabbable target only to "two-point" tools (which show draggable anchors). The tools **excluded** from that set — `tactic_spotlight`, `tactic_focus_ring`, `tactic_offside_line`, `tactic_agility_ladder`, `tactic_stat_badge` — have no anchors and, depending on their shape, a thin/huge/non-hittable body. The user's ask is broader than one bug: **validate that every tool type can be selected, moved, and deleted**, and make that a standing guarantee.

## Findings / current state
- [`SmartTools.swift:114`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift) — `Spotlight` is `Rectangle().fill(.black.opacity(0.6)).mask(…).allowsHitTesting(false)`. The `.allowsHitTesting(false)` (line 124) means the spotlight's drawn content never receives touches. **Fix:** give the tool a hittable handle (see below); the dimming overlay itself can stay non-hittable, but the tool must expose a grabbable target at `focus`/`start`.
- [`SmartTools.swift:322`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift) — `twoPoint` excludes `tactic_spotlight`, `tactic_focus_ring`, `tactic_offside_line`, `tactic_agility_ladder`, `tactic_stat_badge`, so the `anchors` view (line 328) renders nothing for them — no drag handles, no visible selection affordance. **Fix:** for these single-anchor/overlay tools, render an invisible-but-hittable move/select handle at their primary point (`start`) when placed, and a visible anchor when selected.
- [`SmartTools.swift:219-224`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift) — the body wires `.gesture(moveGesture)`, single/double-tap → `MVO.selectTool()`, and long-press → `showDeleteAlert`. These are correct but fire only where the view is hittable; for the spotlight that area is empty. **Fix:** ensure a `contentShape`/hittable region exists around the tool's anchor so these gestures land.
- [`Panels.swift` `EnginePropertiesPanel.delete()`](../../Ludi%20Boards/Redesign/Panels.swift) and [`TacticalBoardView.swift` `RedesignContextToolbar.deleteSelected()`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — both delete a tool by soft-deleting the selected `ManagedView`. They work, but are only reachable once the tool is selected — which is exactly what's broken for the spotlight. Restoring selection restores delete for free.
- Token tools (soccer jersey discs) and equipment use a different view (`SoccerPlayerToolView`); they are not known-broken, but this task's validation must cover them too.

## Scope
**In scope:**
- Fix the spotlight so it can be selected, moved, and deleted.
- Give every "non-two-point" overlay smart tool (`tactic_spotlight`, `tactic_focus_ring`, `tactic_offside_line`, `tactic_agility_ladder`, `tactic_stat_badge`) a reliable hittable select/move handle at its anchor point, with a visible anchor when selected.
- A validation pass / checklist covering **every** tool type the Library can place (equipment, smart/tactic, token/jersey): each must be selectable, movable, and deletable.
- Keep the dimming/overlay visuals intact (the spotlight should still dim the board) while making the tool interactive.

**Out of scope:**
- Reworking the smart-tool geometry model or the two-/three-point anchor editing (owned by the shipped TASK-020).
- The layer-list selection path (TASK-047) — it complements this but is separate; this task must work from direct on-canvas interaction.
- Any Firebase wiring (Firebase-ready only).

## Files expected to change
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift`
- (possibly) `Ludi Boards/Redesign/TacticalBoardView.swift` / `Panels.swift` if a fallback delete affordance is added for currently-unselectable tools.

## Acceptance criteria
- [ ] A placed spotlight can be single-tapped to select it (Properties opens) and shows a selection affordance.
- [ ] A placed spotlight can be dragged to a new position and the move persists across a board refresh / relaunch.
- [ ] A placed spotlight can be deleted (long-press confirm, Properties delete, or context-toolbar delete) and stays deleted.
- [ ] The same three operations (select / move / delete) are verified for `tactic_focus_ring`, `tactic_offside_line`, `tactic_agility_ladder`, `tactic_stat_badge`, every equipment item, and the jersey/token tool.
- [ ] The spotlight still dims the board and renders its focus circle (visual unchanged); only its interactivity is added.
- [ ] No tool type remains that can be placed but not removed.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim — scheme **"Ludi Boards"**, bundle **io.ludi.sol**, verified headlessly per the project's background-simulator convention (`simctl` launch with `REDESIGN_SMART=1` to seed a grid of every tactic tool; capture screenshots before/after select/move/delete). For each tool type: place it, select it (confirm Properties opens), move it, delete it.

## Open questions / risks
- **Handle shape for overlay tools.** Recommend a small invisible `contentShape(Circle())` hit region (~`w * 3`) centered on the tool's `start`/`focus`, carrying the existing `moveGesture` + tap + long-press, plus a visible lime anchor when `selected` (reuse the `anchor(_:)` style). This gives a consistent grab point without changing the visual.
- **Spotlight overlay vs. handle layering.** The dimming overlay stays `allowsHitTesting(false)`; only the new handle is hittable, so the spotlight no longer blocks taps on tools beneath it (verify it didn't previously swallow/block other tools' hits — if it did, that's a second bug this fixes).
- **Standing guarantee.** Recommend encoding the "every placeable tool is select/move/delete-able" check as a reusable verification (seeded `REDESIGN_SMART` grid + a per-type assertion) so future tools can't regress this — ties into [TASK-049](TASK-049-realm-model-coverage-audit.md)'s validation theme.

## Outcome (2026-06-26) — PARTIAL (build verified)
Root fix landed: added an always-hittable transparent handle (`Circle().contentShape` at `start`, sized `w*5`) for every non-`twoPoint` overlay tool (spotlight, focus_ring, offside_line, agility_ladder, stat_badge) in SmartTools.swift, so tap-select / move / long-press-delete now have a target above the spotlight's `allowsHitTesting(false)` overlay. Build clean. **Remaining:** the per-tool-type validation sweep (every equipment + token type select/move/delete) is best done as an XCUITest over a `REDESIGN_SMART` seeded grid — interaction-level, deferred per the background-sim convention.
