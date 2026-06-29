# TASK-032: Derive or drop the fabricated formation labels

**Phase:** SQ — Squad / Roster · **Severity:** MEDIUM · **Depends on:** TASK-028 (live panel) · **Source:** [audit](../../docs/audits/2026-06-26-squad-add-player-drawer.md)

## User story
As a **coach**, I want **the formation shown next to each side to reflect my actual squad (or not be shown at all)** so that **the panel never tells me I'm playing 4-3-3 when I've edited the roster into something else**.

## Why this matters
The squad panel prints "HOME · 4-3-3" and "AWAY · 4-4-2" as fixed strings. The player *count* beside them is live (it reads `home.count` / `away.count`), but the formation half of the label is fabricated and never changes. The moment a coach adds, removes, or repositions players the count moves and the formation does not — so the header actively lies. It reads as real data because it sits next to a number that *is* real, which makes it worse than an obvious placeholder. Either the formation is derived from the roster's positions and earns its place, or it comes out until something computes it. A wrong-but-confident label is a liability once the roster becomes editable (TASK-029/030/031).

## Findings covered
- [`Ludi Boards/Redesign/Panels.swift:93`](../../Ludi%20Boards/Redesign/Panels.swift) — `EngineSquadPanel` hardcodes `title: "HOME · 4-3-3"` on the home `RosterHeader` while `count: home.count` is live. The formation is fabricated and never reflects the real roster. Fix: derive the formation from the players' `position` values, or drop the formation portion of the title and keep only "HOME".
- [`Ludi Boards/Redesign/Panels.swift:97`](../../Ludi%20Boards/Redesign/Panels.swift) — same in `EngineSquadPanel` for the away side: `title: "AWAY · 4-4-2"`, `count: away.count` live. Fix: derive from `away` positions or drop the formation string.
- [`Ludi Boards/Redesign/Panels.swift:46`](../../Ludi%20Boards/Redesign/Panels.swift) + [`Ludi Boards/Redesign/Panels.swift:52`](../../Ludi%20Boards/Redesign/Panels.swift) — the preview twin `SquadPanel` carries the same fabricated "HOME · 4-3-3" / "AWAY · 4-4-2" strings (with literal counts 11 / 5). Fix: keep the two twins consistent — whatever the live panel does, mirror it here so the preview doesn't reintroduce the fiction.

## Scope
**In scope:**
- Decide the call: derive the formation string from `RosterPlayer.position` values per side, or drop the formation text entirely (leaving "HOME" / "AWAY").
- Apply the decision to the live `EngineSquadPanel` (`Panels.swift:93`, `:97`).
- Mirror the same treatment in the preview `SquadPanel` (`Panels.swift:46`, `:52`) so the twins stay honest.

**Out of scope:**
- Any change to the `RosterPlayer` model or its `position` field — keep the board-scoped model as-is.
- Position-editing UI (owned elsewhere in the SQ batch) — this task only consumes whatever positions already exist.
- The squad/team *name* breadcrumb ("U-12 Squad") — that is the team-entity decision carried by TASK-033, not this task.
- The live-redraw plumbing — assumed already fixed by TASK-028 (`@ObservedResults`); this task just renders the right string.

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift`

## Acceptance criteria
- [ ] No hardcoded "4-3-3" or "4-4-2" formation string remains in `EngineSquadPanel`.
- [ ] No hardcoded "4-3-3" or "4-4-2" formation string remains in the preview `SquadPanel`.
- [ ] If derive is chosen: the header formation recomputes from the side's `RosterPlayer.position` values and changes when the roster changes (verified by editing the squad and watching the string update). The chosen derivation rule (e.g. count by line: DEF/MID/FWD) is documented in a one-line comment at the header.
- [ ] If drop is chosen: the header shows only the side ("HOME" / "AWAY") with the live count, and no formation token appears anywhere in the panel.
- [ ] The live panel and the preview twin show the same kind of label (both derived, or both dropped) — they do not disagree.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim — scheme "Ludi Boards", bundle `io.ludi.sol`: open the squad panel on a board with players.
   - If derived: confirm the header formation matches the real positions; add/remove a player or change a position and confirm the formation string updates (not just the count).
   - If dropped: confirm no "4-3-3"/"4-4-2" text appears and the side label + live count render correctly.
3. Confirm the SwiftUI preview (`SquadPanel`) renders without a `BoardEngineObject` and shows the same treatment as the live panel.

## Open questions / risks
- Derive vs. drop is a real fork. Deriving needs a rule that maps `position` strings to a formation token, and positions are currently free-text "—" / "GK" placeholders — until positions are meaningful (TASK-029/030/031), a derived formation would be as fake as the hardcoded one. Leaning toward **drop now, derive later** once positions carry real data; confirm before implementing.
- If dropping, decide whether the "· " separator and any layout spacing in `RosterHeader` need adjusting so a bare "HOME" doesn't look truncated.
- Keep the board-scoped `RosterPlayer` model — do not introduce a formation field or team entity to back this. That decision is carried by TASK-033.

## Outcome (2026-06-26) — DONE (render verified)
Dropped the fabricated `· 4-3-3` / `· 4-4-2` from both `EngineSquadPanel` and the static `SquadPanel`; headers now read just "HOME"/"AWAY" with the live count. Deriving a real formation from positions is deferred (its own feature). Verified in the rendered panel — headers no longer carry a formation string.
