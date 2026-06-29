# TASK-025: Trim the left rail to wired interaction modes (+ typed tool identity)

**Phase:** Left tool rail · **Severity:** HIGH · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-left-tool-rail.md)

## User story

As a **coach using the board**, I want **the left rail to show only tools that actually do something** so that **tapping a rail button never silently does nothing, and the rail honestly reflects what the board can do**.

## Why this matters

The shipped rail (`EngineToolRail`, live via RD-6) renders 9 buttons but wires 3. Five (`photo`, `person`, `triangle`, `flag`, `paintbrush`) fall through to `default: BEO.disableDrawing()` — they look identical to working tools and give zero feedback on tap. A sixth (`hand`/pan) is a byte-for-byte duplicate of select (both `disableDrawing()`), and the canvas already pans from anywhere, so a pan "mode" is vestigial. Decision (owner, 2026-06-26): **remove them** — the add/colour functions already live in the Library / Squad / Properties panels; the rail should be interaction modes only. Also replaces the fragile positional index contract (handleTap/activeIndex switch on hard-coded array indices) with a typed `RailTool` so the rail can't silently mis-wire when reordered.

## Findings covered

- [`Components.swift:229`](../../Ludi%20Boards/Redesign/Components.swift) — HIGH: 5 dead buttons (`default: disableDrawing()`). Fix: remove them.
- [`Components.swift:226`](../../Ludi%20Boards/Redesign/Components.swift) — MEDIUM: pan (1) == select (0); vestigial. Fix: remove the hand button.
- [`Components.swift:211-217`](../../Ludi%20Boards/Redesign/Components.swift) — LOW: `activeIndex` codomain `{0,2,3}`; most buttons can never show active. Fix: falls out once the rail is the 3 real tools.
- [`Components.swift:186 + :223`](../../Ludi%20Boards/Redesign/Components.swift) — LOW: positional tool identity. Fix: a typed `RailTool` enum drives render + tap + active state.

## Scope

**In scope:**
- Define `RailTool` (`select`, `drawStraight`, `drawCurved`) with its SF Symbol + divider rule.
- `ToolRail` renders `RailTool.allCases`; its `active`/`onTap` are typed (`RailTool`), not `Int`.
- `EngineToolRail` derives the active `RailTool` from `BEO.isDraw`/`shapeSubType` and routes taps by case (select → `disableDrawing`, straight/curved → `toggleDrawingMode`).
- Keep the static/engine split (BEO-free `ToolRail` still previewable).

**Out of scope:**
- Wiring shape/marker/colour/player as rail tools (decision: they live in Library/Squad/Properties; not duplicated on the rail).
- The lock/draw flag separation (TASK-026).
- Any panel, pill, or gesture change.

## Files expected to change

- `Ludi Boards/Redesign/Components.swift`

## Acceptance criteria

- [ ] The live rail shows exactly 3 buttons: select, draw-straight, draw-curved.
- [ ] No rail button is a no-op; every tap changes engine state observably.
- [ ] `ToolRail`/`EngineToolRail` use a typed `RailTool`, not array indices.
- [ ] Active highlight reflects real draw state for all 3 tools (no unreachable cases).
- [ ] BEO-free `ToolRail()` preview path still compiles and renders.

## Verification (build + sim)

1. `/build` clean.
2. iPad sim (headless): launch the live board — rail shows 3 buttons; `REDESIGN_DRAW=straight`/`curved` highlights the matching tool; default highlights select.

## Open questions / risks

- The static `#Preview`s and the non-engine `ToolRail()` branch in `TacticalBoardView` must keep compiling with the typed interface — update call sites if the signature changes.

## Outcome (2026-06-26) — DONE

Replaced the 9-entry positional tuple + index switches with a typed `RailTool`
enum (`select` / `drawStraight` / `drawCurved`). `ToolRail` renders
`RailTool.allCases`; `EngineToolRail` derives the active case from
`isDraw`/`shapeSubType` and routes taps by case. The 5 dead buttons
(photo/person/triangle/flag/paintbrush) and the vestigial pan are gone — every
remaining button changes engine state. Verified on iPad sim across all three
states: select → cursor highlighted, straight → pencil, curved → scribble. One
file changed: `Components.swift`. Add/colour stay in the panels (not duplicated).
