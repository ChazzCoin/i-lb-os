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

## Phase SQ — Squad / Roster

**Status:** 🚧 Active

**Scope.** Close the 2026-06-26 squad/add-player/side-drawer audit
(`docs/audits/2026-06-26-squad-add-player-drawer.md`). The drawer state
machine is sound, but the roster behind it is half-wired: "Add player"
persists a `RosterPlayer` and never redraws (snapshot read in `body`,
no `refreshBoard()`), there is no away-side add / edit / delete, the
only population path is a `#if DEBUG` seed, placement has no dedup, and
the panel shows fabricated formation labels and a hardcoded squad name.
Make the panel live via `@ObservedResults`, finish roster CRUD, add an
empty state and a real production population path, make placement a
place/remove toggle, and stop the header from lying. Keep the
board-scoped `RosterPlayer` model — the reusable-team-entity question
is a deferred decision (TASK-033). Finishing wiring + honesty, not a
model rewrite.

---

## Phase FB — Functional board

**Status:** 📋 Queued

**Scope.** Make the redesign board a fully functional product. From a
2026-06-26 batch of user requests: fix interaction bugs (locked stroke
slider, Properties-close not clearing on-canvas anchors, drawer panels
cut off at the bottom, rotate buttons dead, rail curved-vs-straight,
the unselectable/undeletable spotlight + a tool-validation pass) and
finish wiring the chrome and panels to the live engine (full tool
catalog, board breadcrumb dropdown with load/create, a Photoshop-style
layer list, real session presence + a guest user, basic free share,
and a board aspect-ratio investigation). Bugs first, then wiring. No
Firebase — Firebase-ready only.

## Phase AN — Animate & Record

**Status:** 📋 Queued

**Scope.** Turn the placeholder Record button into a real recording and
playback system, with the **Animate toggle switching the entire screen**
into a record/playback/animation mode (Plan chrome hidden; board locked).
The `Recording`/`RecordingAction` Realm models and the capture + replay
engine in `BoardEngineObject` already exist but are orphaned — the
redesign only toggles `isRecording`, and `.animate` is a dead enum case.
Decomposed from the 2026-06-26 animate audit into seven tasks
(TASK-051…057): mode-switch skeleton, recordings drawer, transport
controls, faithful add/delete replay, transient-state hardening, capture
fidelity, and a timeline + scrub slider. Layers 1–2 (051–053) are wiring
to the working engine and ship first; layer 3 (054–057) hardens the
engine for faithful, seekable replay. Firebase stays out (models are
already Firebase-ready).

## Phase DM — Data model & linking

**Status:** 📋 Queued

**Scope.** The data-architecture workstream. Build a general
object-linking model — players as top-level anchors, tools (lines,
cones, etc.) attachable in sequence, and ultimately any object linkable
to any other — on Realm, ready for a future Firebase mirror. Plus a
coverage audit that every object / tool / setting that should be
persisted is backed by a Realm model and clean for Firebase. No
Firebase wiring in this phase; readiness only. The linking model
underpins the Animate phase (linked objects move together).

---

## Phase TC — Tool catalog

**Status:** 📋 Queued

**Scope.** Close the 2026-06-27 full tool-catalog audit
(`docs/audits/2026-06-27-tool-catalog.md`). An every-tool sweep found
the breakage is concentrated, not everywhere: SoccerTool (13) and
SmartTool (13) are solid end-to-end. The redesign's circle/square/
triangle render wrong (the views read point/radius geometry the tap-add
create path never sets — the only *surfaced* bug); PoolBall (16) is
invisible (missing ball assets) and GeneralTool (71) is unreachable,
both unsurfaced in the Library; dragged shapes come in the wrong size;
and every render switch defaults to a silent `EmptyText()` that hides
mis-wiring. Fix the surfaced shapes, decide whether to surface or cut
Pool/General, and add a visible unknown-tool placeholder. No Firebase;
leave the working Soccer/Smart families alone.

---

*(Add phases as the project evolves. Use `/plan` to think through new
phases conversationally; use `/task` to file tasks under existing
phases.)*
