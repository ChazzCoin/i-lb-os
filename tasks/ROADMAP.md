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

- TASK-006 — Left ToolRail wired (select / pan / draw / shape / marker / color) ✅
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

## Cross-cutting

Tasks that don't fit a single phase — typically infrastructure that
several phases depend on. Use sparingly.

- (none yet)

---

*(Add phases and tasks as the project evolves. Use `/task` to file
tasks; use `/plan` to think through new phases.)*
