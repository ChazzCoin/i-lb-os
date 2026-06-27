# Phases

High-level phase-only roadmap for this project. Each phase has a
**name**, a **scope paragraph** (2–4 sentences), and a status. The
ordered task list for each phase lives in [`ROADMAP.md`](ROADMAP.md).

This file answers "what's the big picture?" — `ROADMAP.md` answers
"what's in flight?".

---

## How to read this file

- 📋 **Queued** — defined, not started.
- 🚧 **Active** — current work happens here.
- ✅ **Shipped** — phase done; record the version that landed it.

Phases ship in order top-to-bottom, but cross-cutting work (typically
infrastructure or process) can interleave.

---

> **Theme: Canvas/Board redesign.** Phases RD-1 … RD-6 roll out the
> Claude Design Canvas/Board redesign onto the live `CanvasEngine`.
> Locked decisions: **board-screen theme only**, **reskin-first
> (roster later)**, **iPad-landscape first**. Reference:
> [`docs/design/canvas-board-redesign/GAP-ANALYSIS.md`](../docs/design/canvas-board-redesign/GAP-ANALYSIS.md).

## Phase RD-1 — Foundation

**Status:** ✅ Shipped (2026-06-26)

**Scope.** Stand up the design system inside the app and a flagged,
iPad-landscape shell for the redesigned board. Brand tokens, the
`GlassPanel` surface, and the three custom fonts become available and
are **scoped to the board screen** so the SOL-green home/nav are
untouched. Produces a `TacticalBoardView` reachable behind a debug
flag with the floating-chrome layout and right-panel state machine —
the frame every later phase hangs on. Out: wiring any control to the
engine.

---

## Phase RD-2 — Canvas & tokens

**Status:** ✅ Shipped (2026-06-26)

**Scope.** The pitch and the things on it. Reconcile the design's
vector pitch with `FieldOverlayView` + the `Sports` registry, reskin
player tokens onto existing `ManagedView` tools (home/away/GK visual
mapping, **no roster model yet**), wire the lime selection ring +
floating context toolbar to the engine's real selection, and style
drawn lines/arrows to match. Out: the roster/linked-player data model.

---

## Phase RD-3 — Chrome

**Status:** ✅ Shipped (2026-06-26)

**Scope.** Replace the current `CanvasMenuView` chrome with the
redesign's left tool rail, bottom control pill, and top bar — each
wired to real engine actions (draw/select/pan, lock/undo/redo/zoom/
scope/record, breadcrumb/sport-switch/share, Plan-Animate-Present).
The record/playback engine in BEO (built but unreached) gets its first
real UI entry. Out: the right-hand panels.

---

## Phase RD-4 — Panels

**Status:** ✅ Shipped (2026-06-26)

**Scope.** The right-hand panels. The Properties panel replaces
`MvSettingsBar`, wired through the existing `CodiChannel.TOOL_ATTRIBUTES`
bus (rotation/size/color/delete already flow there). The Library panel
replaces the current tool picker and drives sport/board switching plus
drag-to-board tool creation through the existing drop path. Out: the
Squad roster panel (needs the roster model — RD-5).

---

## Phase RD-5 — Roster (later)

**Status:** ✅ Shipped (2026-06-26)

**Scope.** The deferred half of the "reskin-first" decision. Introduce
a teams/players/roster data model, link roster entries to board tokens,
and light up the Squad panel + the Properties panel's identity and
linked-player rows as real, persisted features. This is schema work on
`ManagedView`/Realm — sequenced after the visual redesign lands so the
two efforts don't entangle.

---

## Phase RD-6 — Cutover

**Status:** ✅ Shipped (2026-06-26)

**Scope.** Make the redesigned board the real board: route the live
entry to the redesigned `TacticalBoardView`, retire the superseded
`CanvasMenuView` and `MvSettingsBar`, remove the `RedesignPreviewEntry`
harness, and do final iPad-landscape polish. Ships the redesign.

---

## Phase ST — Smart Tools (Tier 1)

**Status:** ✅ Shipped (2026-06-26)

**Scope.** Import the Smart Tool Catalogue (24 SwiftUI tactical tools)
and wire **Tier 1 (13 tools)** end-to-end — a new `SmartTool` catalog,
the `SmartToolManaged` board-scale dispatcher, and a Library **Tactics**
tab. Tiers 2–5 (multi-point, computed overlays, generators, FreezeFrame)
deferred. See `docs/design/smart-tools/`.

---

## Phase TH — Tool System Hardening

**Status:** ✅ Shipped (2026-06-26)

**Scope.** Close the gaps the 2026-06-26 tool-system audit
(`docs/audits/2026-06-26-tool-system.md`) found in the *editing*
layer the redesign added over the engine. The render pipeline is
sound; the interaction wiring is half-finished. Make smart tools
selectable, make Properties tool-family-aware, make tool views
re-render on data change, unify the four create paths, wire the
roster, harden smart-tool drag/selection, and clear out dead routes /
magic numbers / DEBUG scaffolding. No model rewrite — finishing wiring.

---

## Phase LR — Left tool rail

**Status:** ✅ Shipped (2026-06-26)

**Scope.** Close the 2026-06-26 left-rail audit
(`docs/audits/2026-06-26-left-tool-rail.md`). The rail shipped nine
buttons but wired three: five were dead placeholders and pan duplicated
select. Trim it to the real interaction modes (select / draw-straight /
draw-curved) behind a typed `RailTool`, and untangle the overloaded
`gesturesAreLocked` so the draw-mode pan-suppression (now derived from
`isDraw`) no longer clobbers — or masquerades as — the user's explicit
canvas lock. Add/colour stay in the Library / Squad / Properties panels.
No new rail features; finishing and honesty.

---

*(Add phases as the project evolves. Use `/plan` to think through new
phases conversationally; use `/task` to file tasks under existing
phases.)*
