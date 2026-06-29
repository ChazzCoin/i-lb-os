# TASK-033: Squad/team identity (replace hardcoded "U-12 Squad")

**Phase:** SQ — Squad / Roster · **Severity:** LOW · **Depends on:** none (decision feeds the rest of the SQ batch) · **Source:** [audit](../../docs/audits/2026-06-26-squad-add-player-drawer.md)

## User story
As a **coach**, I want **the top bar to show my actual squad/team name instead of the fixed "U-12 Squad" placeholder** so that **the chrome reflects the board I'm on and doesn't read as a stub the moment anyone other than U-12 opens it**.

## Why this matters
`EngineTopBar` passes the literal string `"U-12 Squad"` into `TopBar`, with a comment promising "roster name lands in RD-5" — it did not. Every board, for every coach, shows the same fabricated team name. It is cosmetic (LOW), but it actively misleads: it implies a squad identity exists when none does. `RosterPlayer` is board-scoped only — there is no team name, no formation, no squad entity anywhere in the model. This task is primarily a **decision**: do we keep the squad board-scoped (and source a name from the activity, or drop the breadcrumb), or introduce a reusable team entity that persists across boards? The recommendation below should be ratified before any code lands; implementation may be deferred pending that call.

## Findings covered
- [`Ludi Boards/Redesign/Components.swift:134`](../../Ludi%20Boards/Redesign/Components.swift) — `EngineTopBar` passes `squad: "U-12 Squad"` as a hardcoded literal into `TopBar`, with the comment `// roster name lands in RD-5`. RD-5 never delivered a squad name; `activityTitle` (Components.swift:139) already resolves the board title live from `ActivityPlan`, but the squad string does not. No squad/team entity exists — [`RosterPlayer`](../../Ludi%20Boards/Redesign/RosterPlayer.swift) is keyed on `boardId` and carries no team name. Fix (pending decision): either source the squad label from the activity / roster on the current board, or drop the breadcrumb until a real identity exists — do NOT keep the fabricated literal.

## Scope
**In scope:**
- A documented decision: board-scoped squad name vs. a reusable team entity. Capture it (recommendation below) and ratify before code.
- If the board-scoped option is taken: replace the `"U-12 Squad"` literal in `EngineTopBar` with a value derived from the current activity/board (or remove it if no real source exists yet).

**Out of scope:**
- Introducing a new `Team`/`Squad` Realm entity and the cross-board migration it implies — that is a separate, larger task only if the decision goes that way.
- Any roster behaviour (add/edit/delete/away-side) — covered by TASK-028..032.
- Changing the board-scoped `RosterPlayer` model. The design constraint is to **keep `RosterPlayer` board-scoped**.

## Files expected to change
- `Ludi Boards/Redesign/Components.swift` (only if the board-scoped fix is implemented; otherwise this task ships as a recorded decision with no code change)

## Acceptance criteria
- [ ] The squad-vs-team decision is written down (a `/decision` ADR or a note in this task's outcome) with the chosen option and its rationale.
- [ ] No code path passes the hardcoded literal `"U-12 Squad"` as the live squad name; the stale `// roster name lands in RD-5` comment is removed or corrected.
- [ ] If board-scoped is chosen: the top bar squad label is derived from the current activity/board (or omitted), and renders correctly on a board whose activity is not "U-12".
- [ ] If a team entity is chosen: this task is closed as a decision and the entity work is filed as its own task (no entity is built under this task).
- [ ] `RosterPlayer` remains board-scoped — no schema change to its scope in this task.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim — scheme **"Ludi Boards"**, bundle **io.ludi.sol**: open a board whose activity title is not "U-12" and confirm the top bar no longer shows the fixed "U-12 Squad" — it shows the derived name (or nothing), per the chosen option.

## Open questions / risks
- **The core fork (decide first):** (a) keep the squad board-scoped — source a name from the `ActivityPlan` or drop the breadcrumb; small, no migration; or (b) introduce a reusable `Team`/`Squad` entity that owns players and persists across boards — larger, needs a Realm migration and a re-parenting of `RosterPlayer.boardId`.
- **Recommendation:** keep it **board-scoped** for now (matches the existing `RosterPlayer.boardId` model and the audit's stated scaffold intent), and either derive the label from the activity or remove it. Defer a reusable team entity until there's a concrete cross-board need; building it now is speculative scope.
- If board-scoped and no activity-level name field exists, the honest move is to drop the squad breadcrumb rather than invent another placeholder.
- Low blast radius, but the decision shapes the whole SQ batch's data model — settle it before any team-entity work is greenlit.
