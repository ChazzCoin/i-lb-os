# TASK-026: Separate draw-mode pan-suppression from the explicit canvas lock

**Phase:** Left tool rail · **Severity:** MEDIUM · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-left-tool-rail.md)

## User story

As a **coach who locked the canvas**, I want **my lock to stay put when I tap a rail tool** so that **the lock means "I locked it", not "I haven't drawn recently", and entering draw mode doesn't light the lock icon as if I'd locked the board**.

## Why this matters

`BEO.gesturesAreLocked` is overloaded: it's the pill's explicit canvas lock AND the draw-mode pan-suppression. Because `enableDrawing()` sets it `true` and `disableDrawing()` sets it `false`, two real bugs follow: (a) entering draw mode lights the pill's lock icon (`locked: BEO.gesturesAreLocked`), and (b) tapping select (or, before TASK-025, any non-draw button) silently clears a lock the user set with the pill. The flag's real meaning is "pan/zoom is suppressed"; draw-suppression should derive from `isDraw` instead, leaving `gesturesAreLocked` as the explicit user lock only.

## Findings covered

- [`BoardEngineObject.swift:99-108`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — MEDIUM: `gesturesAreLocked` overloaded; `enable/disableDrawing` co-opt it, clobbering the explicit lock and lighting the lock icon on draw.

## Scope

**In scope:**
- `enableDrawing()` / `disableDrawing()` stop writing `gesturesAreLocked` (draw no longer touches the lock).
- The 4 gesture-bail sites suppress pan/zoom on `gesturesAreLocked || isDraw`:
  - redesign: `RedesignBoardCanvas.swift:46, :64`
  - legacy parity: `CanvasEngine.swift:186, :212`
- Net: `gesturesAreLocked` becomes the explicit lock only (pill / legacy lock toggles / `REDESIGN_LOCK`); drawing suppresses pan via `isDraw`; the pill lock icon now reflects only the user's lock.

**Out of scope:**
- `runCanvasLoading()` (`BoardEngineObject.swift:265,269`) keeps its transient 5s load-time `gesturesAreLocked` set/clear — it's a load lock, not part of this finding (folding it into `isLoading` is risky because `isLoading` defaults `true`).
- The separate CoreEngine `@AppStorage("gesturesAreLocked")` canvas system (CanvasView/CoreCanvas/CanvasMenu) — a different flag entirely; untouched.
- The pill's `onRedo → undoLastToolAction()` ("no redo yet") — separate, needs a real redo (not this task).

## Files expected to change

- `Ludi Boards/CanvasEngine/BoardEngineObject.swift`
- `Ludi Boards/Redesign/RedesignBoardCanvas.swift`
- `Ludi Boards/CanvasEngine/CanvasEngine.swift`

## Acceptance criteria

- [ ] Entering draw mode does NOT change `gesturesAreLocked` (pill lock icon unaffected by drawing).
- [ ] Tapping select after an explicit lock leaves the lock set (canvas stays locked).
- [ ] While drawing, canvas pan/zoom is still suppressed (via `isDraw`) on both redesign and legacy gesture surfaces.
- [ ] An explicit lock still suppresses pan/zoom when not drawing.

## Verification (build + sim)

1. `/build` clean.
2. Interaction is a gesture sequence (lock → tap select → try to pan), hard to capture in a static screenshot — verify primarily by reading the 6 edit sites end-to-end; sanity-check on sim that the board still pans normally and freezes under `REDESIGN_LOCK=1` and `REDESIGN_DRAW`.

## Open questions / risks

- Legacy parity: `CanvasMenuView` shows the lock icon from `BEO.gesturesAreLocked`; after the fix it no longer lights during draw (more correct, but a visible change on the QA-only legacy path).
- Residual: an explicit lock set during the first 5s of board load could still be cleared by `runCanvasLoading`'s timer — pre-existing, out of scope, noted.

## Outcome (2026-06-26) — DONE

`enableDrawing`/`disableDrawing` no longer write `gesturesAreLocked`. The 4 pan/
zoom gesture-bail sites now suppress on `gesturesAreLocked || isDraw`
(`RedesignBoardCanvas.swift` ×2, `CanvasEngine.swift` ×2). Net: `gesturesAreLocked`
is the explicit user lock only; draw-suppression derives from `isDraw`. So
drawing no longer lights the pill's lock icon, and tapping select no longer
clears an explicit lock. Build green; the board still pans and freezes correctly
under `REDESIGN_DRAW`/`REDESIGN_LOCK`. The lock-vs-draw behaviour is a gesture
sequence (not a static frame), verified by reading the 6 edit sites end-to-end.
`runCanvasLoading`'s transient load lock left as-is (out of scope, noted).
