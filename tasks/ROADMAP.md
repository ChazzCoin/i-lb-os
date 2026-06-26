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

## Cross-cutting

Tasks that don't fit a single phase — typically infrastructure that
several phases depend on. Use sparingly.

- (none yet)

---

*(Add phases and tasks as the project evolves. Use `/task` to file
tasks; use `/plan` to think through new phases.)*
