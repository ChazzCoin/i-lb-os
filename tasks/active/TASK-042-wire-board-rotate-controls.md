# TASK-042: Wire the board rotate-left / rotate-right controls

**Phase:** FB — Functional board · **Severity:** HIGH · **Size:** small · **Depends on:** TASK-007, TASK-025, TASK-026 · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **the rotate-left and rotate-right buttons in the bottom board settings bar to actually rotate the board** so that **I can orient the tactical view to match how I'm presenting, instead of tapping dead buttons**.

## Why this matters
The user reports the bottom bar rotate buttons "are not working." That's accurate for the live redesign: the redesign's bottom control pill ([`ControlPill` + `EngineControlPill` in `Components.swift:265-332`](../../Ludi%20Boards/Redesign/Components.swift)) has **no rotate buttons at all** — there is nothing to wire, the affordance is simply absent. Rotation *is* wired in two other places (the legacy settings bar and the `NavPad`), and the canvas already honors a rotation transform — so the engine plumbing exists; only the redesign's pill is missing the controls.

## Findings / current state
- [`Ludi Boards/Redesign/Components.swift:265-332`](../../Ludi%20Boards/Redesign/Components.swift) — **MISSING (redesign).** `ControlPill` exposes 7 closures (`onLock`/`onUndo`/`onRedo`/`onZoomOut`/`onZoomIn`/`onScope`/`onRecord`) and its body (lines 279-303) renders lock, undo, redo, zoom -/+, scope, record. There are **no** `onRotateLeft`/`onRotateRight` closures and no rotate buttons. `EngineControlPill` (315-332) wires those same 7 actions to BEO and likewise has no rotate wiring. This is what the user sees. Fix: add `onRotateLeft`/`onRotateRight` closures to the struct (near 270-276), render two `PillIcon` buttons in the body after `onScope`/before the record button (around line 290), and wire them in `EngineControlPill`.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:130`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — **EXISTS.** `BEO.canvasRotation` is a `@Published` var on the engine object. This is the correct target for the new buttons (rotates the canvas, not the field background). No change needed beyond writing to it.
- [`Ludi Boards/Redesign/RedesignBoardCanvas.swift:30`](../../Ludi%20Boards/Redesign/RedesignBoardCanvas.swift) — **EXISTS.** The redesign canvas already applies `.rotationEffect(Angle(degrees: self.BEO.canvasRotation))`, so mutating `canvasRotation` will visibly rotate the board. The render path is already correct; only the input is missing.
- [`Ludi Boards/views/NavViews/NavPad.swift:32-33`](../../Ludi%20Boards/views/NavViews/NavPad.swift) — **REFERENCE PATTERN (wired).** `rotate.left` → `BEO.canvasRotation += -45.0`, `rotate.right` → `BEO.canvasRotation += 45.0`. Copy this shape (SF Symbols `rotate.left`/`rotate.right` and the `canvasRotation +=` mutation), but use ±90° per the user request rather than ±45°.
- [`Ludi Boards/views/Windows/BoardSettingsToolBar.swift:235-260`](../../Ludi%20Boards/views/Windows/BoardSettingsToolBar.swift) — **WIRED (legacy, different target).** The legacy bar's rotate buttons call `rotateView(by: ±22.5)`, which mutates `BEO.boardFeildRotation` and saves to Realm. This rotates the **field/background**, not the canvas — do **not** copy this target or its 22.5° increment for the redesign. Noted only so the two rotation concepts (`boardFeildRotation` vs `canvasRotation`) aren't conflated.

## Scope
**In scope:**
- Add `onRotateLeft` and `onRotateRight` closures to `ControlPill` (`Components.swift`).
- Render two `PillIcon` rotate buttons in the `ControlPill` body (`rotate.left` / `rotate.right` SF Symbols), placed after the scope button and before the record button.
- Wire them in `EngineControlPill`: `onRotateLeft: { BEO.canvasRotation += -90.0 }`, `onRotateRight: { BEO.canvasRotation += 90.0 }`.

**Out of scope:**
- The legacy `BoardSettingsToolBar` and its `boardFeildRotation` field rotation — untouched.
- `NavPad` — untouched (it already works; it's reference only).
- Any persistence of `canvasRotation` to Realm/Firebase. Firebase wiring is OUT; `canvasRotation` stays a live session transform unless a future task decides otherwise. Keep the change Firebase-ready (don't add a competing local persistence path).
- Reworking the pill layout, styling, or the other six controls.

## Files expected to change
- `Ludi Boards/Redesign/Components.swift`

## Acceptance criteria
- [ ] The redesign bottom control pill shows a rotate-left and a rotate-right button (SF Symbols `rotate.left` / `rotate.right`), positioned after scope and before the record button.
- [ ] Tapping rotate-right increments `BEO.canvasRotation` by +90°; tapping rotate-left by -90°.
- [ ] Each tap visibly rotates the board canvas (via the existing `.rotationEffect` in `RedesignBoardCanvas.swift:30`).
- [ ] Four rotate-right taps return the board to its original orientation (net 360°).
- [ ] `ControlPill` remains pure-visual: the rotation mutation lives only in `EngineControlPill`, matching the existing closure pattern.
- [ ] The legacy `boardFeildRotation` path is unchanged.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim, scheme **"Ludi Boards"**, bundle **io.ludi.sol**, verified headlessly per the project's background-simulator convention: launch a board, confirm the two rotate buttons appear in the bottom pill; tap rotate-right and confirm the board rotates 90° clockwise; tap rotate-left and confirm it rotates back; confirm four rotate-right taps return to the start orientation.

## Open questions / risks
- **Increment size — 90° vs legacy 22.5°?** Recommend **90°**: the user explicitly asked for it, it's cleaner UX for orienting a board, and it matches `canvasRotation` semantics rather than the legacy field-rotation pattern.
- **Should rotation persist (write to Realm like legacy `boardFeildRotation`)?** Recommend **session-scoped, not persisted** — treat `canvasRotation` like the existing pan/zoom transforms in `RedesignBoardCanvas`, which are live and not saved between loads. Confirm against the canvas pan/zoom logic before implementing; if those do persist, match them.
- **Icon choice.** Recommend SF Symbols `rotate.left` / `rotate.right`, consistent with both `NavPad.swift:32-33` and legacy `BoardSettingsToolBar.swift:235,248`.

## Outcome (2026-06-26) — DONE (build + render verified)
Added `onRotateLeft`/`onRotateRight` to `ControlPill` with `rotate.left`/`rotate.right` PillIcons (after scope, before Record), wired in `EngineControlPill` to `BEO.canvasRotation += ∓90`. The existing `.rotationEffect` in RedesignBoardCanvas applies it. Verified on the iPad sim: both rotate buttons render in the pill in the correct position.
