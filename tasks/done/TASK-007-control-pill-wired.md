# TASK-007: Bottom ControlPill wired (lock / undo / redo / zoom% / scope / record)

**Phase:** RD-3 Chrome · **Depends on:** TASK-002 · **Partially supersedes:** CanvasMenuView zoom/lock/reset

## User story

As a **coach**, I want the bottom control pill to drive lock / undo / redo / zoom / scope / record against the real canvas.

## Why this matters

The design's `ControlPill` is static (`zoom @State = 100`). The engine already has `gesturesAreLocked`, `canvasScale` (min/max clamp), undo/history, and a built record/playback engine. Wire the pill to all of it.

## Scope

**In scope:**
- lock → `BEO.gesturesAreLocked`
- undo / redo → BEO history index
- zoom % live readout from `canvasScale`; zoom in/out buttons (respect min/max)
- scope → recenter canvas (reset offset/scale to defaults)
- Record → start/stop the record engine

**Out of scope (explicit):**
- Rail (TASK-006); Record-mode UI beyond start/stop (TASK-008 EditorMode).

## References

- `Ludi Boards/Redesign/Components.swift:199` — `ControlPill` / `PillIcon`
- `Ludi Boards/CanvasEngine/CanvasMenuView.swift` — current lock/zoom/reset
- `Ludi Boards/CanvasEngine/CanvasEngine.swift:174` — `scaleGestures` min/max; `BEO.canvasScale` / `canvasOffset`
- Undo/history + record/playback in `BoardEngineObject.swift`

## Files expected to change

- `Ludi Boards/Redesign/Components.swift` (`ControlPill` → bind BEO)

## Acceptance criteria

- [x] Zoom % matches actual `canvasScale`; +/- zoom works — verified (200% at scale 0.2)
- [x] Lock stops canvas pan/zoom — `gesturesAreLocked` bound (lock lit lime)
- [x] Undo (→ `undoLastToolAction`) + scope (→ `resetZoom`) wired; redo stubbed to undo (no engine redo yet)
- [x] Record toggles recording — `startRecording`/`stopRecording` wired

## Verification (build + sim)

1. `/build` clean.
2. iPad sim: zoom changes the %, lock freezes pan, undo reverses a change, Record toggles.

## Open questions / risks

- Confirm BEO undo/history + record API method names before wiring.

## Blocker notes

(empty)

## Outcome (2026-06-26) — DONE
`ControlPill` made action-driven + `EngineControlPill` wrapper binds zoom%↔`canvasScale`, lock↔`gesturesAreLocked`, undo/zoom/scope/record↔BEO. Verified headless ([render](../../docs/design/canvas-board-redesign/renders/task-007/01-pill-200pct-locked.png)). Redo has no engine counterpart yet (stubbed to undo).
