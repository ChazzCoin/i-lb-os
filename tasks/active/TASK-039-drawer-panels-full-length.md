# TASK-039: Make all right-drawer panels full height (Add-to-board cut off)

**Phase:** FB — Functional board · **Severity:** HIGH · **Size:** small · **Depends on:** none · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **every sub-view in the right-side drawer to run the full height of the available space** so that **panels like "Add to board" aren't clipped at the bottom and I can reach all their content**.

> Verbatim request: "All sub-views within the right-side drawer should be full length. Some, like Add to board, are cut off a little at the bottom."

## Why this matters
The right-drawer panels all render through the shared `PanelShell`, which constrains **width only** — its height falls out of the content's intrinsic size. `TacticalBoardView` already reserves the vertical space (it pads `rightPanel` with `.padding(.top, 74)` and `.padding(.bottom, 80)`), but because `PanelShell` doesn't fill that reserved space, the shell collapses to whatever its content measures. For the taller panels — "Add to board" (Library) especially — the content runs past the collapsed shell and gets visually cut off at the bottom. The desired state: the shell fills the available drawer height, and its internal `ScrollView` handles any overflow, so nothing is clipped.

## Findings / current state
- [`Ludi Boards/Redesign/Panels.swift:15-31`](../../Ludi%20Boards/Redesign/Panels.swift) — `PanelShell` is the shared shell for all three right-drawer panels (Squad, Properties, Library). Its `body` is a `VStack` with header / hairline / `ScrollView { content }` / footer, and the only sizing applied is `.frame(width: width)` at line 28 — **no height constraint**, so the shell collapses to content intrinsic height.
- [`Ludi Boards/Redesign/Panels.swift:28`](../../Ludi%20Boards/Redesign/Panels.swift) — the exact line to change: `.frame(width: width)` → `.frame(width: width, maxHeight: .infinity)`. This makes the `VStack` expand to fill the vertical space the parent already reserves; the existing `ScrollView` (line 25) then scrolls overflow inside the full-height shell instead of letting it spill past the bottom.
- [`Ludi Boards/Redesign/TacticalBoardView.swift:65-75`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — `rightPanel` is laid out inside an `HStack` with `.padding(.top, 74)` and `.padding(.bottom, 80)`. The vertical room is **already reserved here**; the bug is that `PanelShell` doesn't consume it. No change expected in this file — it defines the budget the shell should fill.
- [`Ludi Boards/Redesign/Panels.swift:642-730`](../../Ludi%20Boards/Redesign/Panels.swift) — `LibraryPanel` (the "Add to board" view) is the worst case: it builds the tallest content (sport selector, tabs, grids) through `PanelShell(width: 288)`, so the collapse is most visible here. Fixing `PanelShell` fixes this panel and the other two at once — no per-panel change needed.

## Scope
**In scope:**
- Add a vertical fill to `PanelShell`'s frame at `Panels.swift:28` so the shell occupies the drawer's reserved height.
- Confirm the fix lands for all three panels that use `PanelShell` (Squad, Properties, Library / "Add to board").

**Out of scope:**
- Any change to the `74`/`80` padding budget in `TacticalBoardView` (lines 74-75) — the reservation is correct; only the shell needs to fill it.
- Per-panel content, layout, or styling changes — this is a single shared-shell fix, not three panel edits.
- Firebase wiring of any kind. No data path is touched; this is a pure layout change. (Firebase wiring is OUT everywhere in this phase — Firebase-ready only.)

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift`

## Acceptance criteria
- [ ] `PanelShell`'s frame at `Panels.swift:28` expands to fill available vertical space (e.g. `.frame(width: width, maxHeight: .infinity)`).
- [ ] The "Add to board" (Library) panel is no longer cut off at the bottom — its last row/content is fully reachable, scrolling if needed.
- [ ] The Squad and Properties panels also render full-height (no shrink-to-content collapse, no new clipping introduced).
- [ ] The top (74) and bottom (80) gaps around the drawer are preserved — the panel fills the space *between* them, not beyond.
- [ ] When content exceeds the available height, the existing `ScrollView` scrolls it; when content is short, the shell still occupies full height without distorting the content.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim, headless per the project's background-simulator convention — scheme **"Ludi Boards"**, bundle **io.ludi.sol**:
   - Open the right drawer and switch to **Add to board** (Library): confirm the bottom-most content is fully visible / scrollable and nothing is clipped at the bottom edge.
   - Switch to **Squad** and **Properties**: confirm each fills the drawer height between the top and bottom gaps, with no new clipping and content intact.

## Open questions / risks
- **`maxHeight: .infinity` vs. a computed max (screen height − (74 + 80)):** Recommend `.infinity`. The parent in `TacticalBoardView` already reserves the bounded space via top/bottom padding, and the internal `ScrollView` constrains overflow — so `.infinity` resolves to the available height without needing a hand-computed value, and avoids a brittle constant that breaks across device sizes.
- **Short-content panels:** with a full-height shell, panels whose content is shorter than the drawer will have the footer pinned to the bottom and empty space above the content (standard `VStack` + `Spacer`-free behavior). Verify this reads acceptably for Squad/Properties; if it looks off, that's a follow-up styling decision, not part of this clip fix.

## Outcome (2026-06-26) — DONE (build verified)
`PanelShell` now chains `.frame(width:)` then `.frame(maxHeight: .infinity)` so the shared shell fills the drawer's reserved height; tall content (Add-to-board) scrolls inside instead of clipping at the bottom. (Note: `.frame(width:maxHeight:)` is not a valid overload — must chain.) Applies to all three panels. Build clean.

## Correction (2026-06-26) — real fix
The PanelShell `maxHeight` was inert: the rail+panel `HStack` in `TacticalBoardView` had no height constraint, so it collapsed to content height and centered, leaving the panel nothing to fill. Fix: `HStack(alignment: .top)` + `.frame(maxWidth: .infinity, maxHeight: .infinity)` on that row. Verified on sim (Library panel now full-height) and deployed to device.

## Correction 2 (2026-06-26) — actual root cause (verified on iOS 18.5 landscape)
The drawer wasn't short — it reserved an 80pt bottom gap meant for the control pill, but the pill is centre-left and never overlaps the right panel, so that gap just clipped the tool grid mid-row. Fix: split the `HStack` bottom padding — rail keeps 80pt (clears the pill), the right panel drops to 16pt so it extends to just above the bottom-right buttons; plus a 52pt bottom inset on the PanelShell ScrollView so the last scrolled row clears those buttons. Reproduced and verified on an iOS 18.5 iPad sim in landscape (matching the device); the 26.4 sim had masked it. Deployed to device.
