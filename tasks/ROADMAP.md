# Roadmap

Phase-by-phase task registry for this project. Each phase has a name,
a scope paragraph, and an ordered list of tasks. Order implies
suggested ship order.

The skills `/roadmap` (full per-phase view) and `/backlog`
(forward-looking only) parse this file as the source of truth for
which tasks belong to which phase.

For phase scopes only (no task lists), see [`PHASES.md`](PHASES.md).

Reference for the whole redesign:
[`docs/design/canvas-board-redesign/GAP-ANALYSIS.md`](../docs/design/canvas-board-redesign/GAP-ANALYSIS.md).

---

## Phase RD-1 — Foundation

> **Scope.** Design system in the app + flagged iPad-landscape board
> shell, theme scoped to the board screen. (See PHASES.md.)

Tasks (in suggested ship order):

- TASK-001 — Design system: tokens, board-scoped theme, `Color(hex:)` reconciliation, fonts ✅
- TASK-002 — iPad-landscape board scaffold (redesigned `TacticalBoardView` behind a flag) ✅

---

## Phase RD-2 — Canvas & tokens

> **Scope.** Pitch + tokens + selection + drawn lines, reskin onto
> existing `ManagedView` tools (no roster model yet).

Tasks (in suggested ship order):

- TASK-003 — Vector pitch reconciled with `FieldOverlayView` + Sports registry ✅
- TASK-013 — Engine-connect the redesign board (render live tools + tap-to-select) ✅
- TASK-004 — Token reskin + selection ring + context toolbar wired to engine selection ✅
- TASK-005 — Drawn-line / arrow styling reconciled with line-draw ✅

---

## Phase RD-3 — Chrome

> **Scope.** Replace `CanvasMenuView` chrome with the rail / pill /
> top bar, each wired to real engine actions.

Tasks:

- TASK-006 — Left ToolRail wired (select / draw-straight / draw-curved) ✅ — *recorded scope said "pan / shape / marker / color" too; those were never wired (pan duplicated select). Corrected + trimmed in TASK-025.*
- TASK-007 — Bottom ControlPill wired (lock / undo / redo / zoom% / scope / record) ✅
- TASK-008 — TopBar + EditorMode (Plan/Animate/Present) wired ✅

---

## Phase RD-4 — Panels

> **Scope.** Properties panel replaces `MvSettingsBar`; Library panel
> replaces the tool picker. Wired through existing channels/drop path.

Tasks:

- TASK-009 — Properties panel replaces `MvSettingsBar` (via `CodiChannel.TOOL_ATTRIBUTES`) ✅
- TASK-010 — Library panel wired (sport/board switch + equipment drag-to-board) ✅

---

## Phase RD-5 — Roster (later)

> **Scope.** Deferred roster/team data model + Squad panel +
> linked-player. Schema work, sequenced after the visual redesign.

Tasks:

- TASK-011 — Roster model + Squad panel + linked-player (extend `ManagedView`/Realm) ✅

---

## Phase RD-6 — Cutover

> **Scope.** Make the redesign the live board; retire old chrome;
> remove the harness; final polish.

Tasks:

- TASK-012 — Cutover & cleanup (route live board to redesign, retire `CanvasMenuView`/`MvSettingsBar`) ✅

---

## Phase ST — Smart Tools (Tier 1)

> **Scope.** Import the Smart Tool Catalogue; wire 13 Tier-1 tactical
> tools (catalog + dispatcher + Library Tactics tab). Tiers 2–5 deferred.

Tasks:

- TASK-014 — Smart Tools — Tier 1 (13 tactical tools wired) ✅

---

## Phase TH — Tool System Hardening

> **Scope.** Close the 2026-06-26 audit's gaps in the tool editing
> layer (`docs/audits/2026-06-26-tool-system.md`). Finishing wiring,
> not a rewrite. Order below = suggested ship order (HIGH first; 016/020
> depend on 015).

Tasks (in suggested ship order):

- TASK-015 — Fix smart-tool selection (unblock Properties for tactic tools) ✅
- TASK-016 — Make the Properties panel tool-family-aware ✅
- TASK-017 — Make tool views re-render on Realm change (colour edits show) ✅
- TASK-018 — Unify the four tool-creation paths (defaults + persistence) ✅
- TASK-019 — Wire the roster "Add player" + roster write-back ✅
- TASK-020 — Smart-tool drag/edit robustness ✅
- TASK-021 — Unified selection: shared ring, single-tap, non-global state ✅
- TASK-022 — Delete dead routes & duplicate views ✅
- TASK-023 — Board-scale constants & shared CoreEngine tokens ✅
- TASK-024 — Engine hygiene: extract DEBUG harness + model nits ✅

---

## Phase LR — Left tool rail

> **Scope.** Close the 2026-06-26 left-rail audit
> (`docs/audits/2026-06-26-left-tool-rail.md`). Trim the rail to the
> controls that are actually wired, separate the draw-mode pan-lock
> from the user's explicit canvas lock, and correct the recorded scope.

Tasks (in suggested ship order):

- TASK-025 — Trim the left rail to wired interaction modes (remove 5 dead buttons + vestigial pan; typed `RailTool`) ✅
- TASK-026 — Separate draw-mode pan-suppression from the explicit canvas lock ✅
- TASK-027 — Correct the TASK-006 recorded rail scope (doc drift) ✅

---

## Phase SQ — Squad / Roster

> **Scope.** Close the 2026-06-26 squad/add-player/side-drawer audit
> (`docs/audits/2026-06-26-squad-add-player-drawer.md`). Make the squad
> panel live, finish roster CRUD (away add / edit / delete), add an
> empty state and a real production population path, turn placement into
> a place/remove toggle, and stop the panel from lying about formation
> and squad name. Keeps the board-scoped `RosterPlayer` model; the
> team-entity question is a deferred decision (TASK-033). Order below =
> suggested ship order (TASK-028 gates the rest).

Tasks (in suggested ship order):

- TASK-028 — Make the squad panel observe the roster live (`@ObservedResults`; Add-player redraw) — CRITICAL
- TASK-029 — Roster CRUD: away-side add, edit (name/number/position), delete — HIGH
- TASK-030 — Squad empty state + production population path — HIGH
- TASK-031 — Place/remove toggle + dedup (one disc per roster player) — MEDIUM
- TASK-032 — Derive or drop the fabricated formation labels — MEDIUM
- TASK-033 — Squad/team identity (replace hardcoded "U-12 Squad"; team-entity decision) — LOW
- TASK-034 — Schema migration discipline guard (RosterPlayer / ManagedView) — LOW
- TASK-035 — Post-cutover hygiene (RedesignPreviewEntry framing + Library entry affordance) — LOW

---

## Phase FB — Functional board

> **Scope.** Make the redesign board a fully functional product: fix
> the interaction bugs and finish wiring the chrome and panels to the
> live engine. From a batch of user requests (2026-06-26). Bugs first,
> then panel/feature wiring. No Firebase wiring anywhere — Firebase-ready
> only. The two larger workstreams these requests touched (recording and
> universal linking) split into Phases AN and DM.

Tasks (in suggested ship order):

- TASK-036 — Fix the locked stroke slider in line Properties — HIGH
- TASK-038 — Sync Properties close (X) with clearing the on-canvas anchors — HIGH
- TASK-039 — Make all right-drawer panels full height (Add-to-board cut off) — HIGH
- TASK-042 — Wire the board rotate-left / rotate-right controls — HIGH
- TASK-048 — Rail squiggly draws curved lines; straight icon draws straight — MEDIUM
- TASK-050 — Validate every tool is selectable / movable / deletable (spotlight stuck) — HIGH
- TASK-040 — Restore the full tool catalog (legacy + current) and future-proof it — HIGH
- TASK-044 — Wire the top-left board breadcrumb dropdown (list / load / create board) — MEDIUM
- TASK-047 — Layer-list drawer of all tools on the board (Photoshop-style) — MEDIUM
- TASK-045 — Investigate the board image aspect ratio (too wide / short) — MEDIUM
- TASK-041 — Wire session presence (no fake data) + a generic guest user — MEDIUM
- TASK-046 — Basic share wiring (free tier; deeper sharing later) — MEDIUM

---

## Phase AN — Animate & Record

> **Scope.** Turn the placeholder Record button into a real
> record/playback system: the Animate toggle switches the **entire
> screen** into a record/playback/animation mode (Plan chrome hidden),
> with a recordings drawer, transport controls, and a scrub slider. The
> `Recording`/`RecordingAction` Realm models and the capture + replay
> engine in `BoardEngineObject` already exist but are orphaned (the
> redesign only toggles `isRecording`). Decomposed from the 2026-06-26
> animate audit (`docs/audits/2026-06-26-animate-record-playback.md`).
> Ship order: 051→052→053 (visible record/playback in Animate mode),
> then 055/056/057 (engine fidelity, parallel), then 054 (scrub).

Tasks (in suggested ship order):

- TASK-051 — Animate mode switches the whole screen (gate Plan chrome, lock board) — HIGH
- TASK-052 — Recordings drawer (list & load recordings for the board) — HIGH
- TASK-053 — Playback transport controls (play / pause / restart) wired to the engine — HIGH
- TASK-055 — Faithful replay — honor adds and deletes during playback — HIGH
- TASK-056 — Move transient record/playback state out of `@AppStorage` — MEDIUM
- TASK-057 — Capture fidelity — reliable add/delete/timed capture — MEDIUM
- TASK-054 — Playback timeline + scrub slider (per-action timestamps) — MEDIUM
- TASK-043 — *(epic, decomposed into TASK-051…057 — keep as the umbrella reference)* ✅ superseded

---

## Phase DM — Data model & linking

> **Scope.** The data-architecture workstream: a general object-linking
> model (players as anchors, tools attached in sequence, any object to
> any object) and a coverage audit that everything is backed by Realm
> and Firebase-ready. No Firebase wiring — readiness only.

Tasks:

- TASK-037 — Universal object linking (players as anchors; tools attach in sequence) — HIGH (epic)
- TASK-049 — Realm-model coverage audit (everything persisted, Firebase-ready) — HIGH

---

## Cross-cutting

Tasks that don't fit a single phase — typically infrastructure that
several phases depend on. Use sparingly.

- (none yet)

---

*(Add phases and tasks as the project evolves. Use `/task` to file
tasks; use `/plan` to think through new phases.)*
