# TASK-020: Smart-tool drag/edit robustness

**Phase:** Tool System Hardening · **Severity:** HIGH · **Depends on:** TASK-015 · **Source:** [audit](../../docs/audits/2026-06-26-tool-system.md)

## User story
As a **coach**, I want **smart tools to drag and edit cleanly — no jumping, anchors that win over the body, and a draggable curve control** so that **I can author tactics precisely without fighting the gestures**.

## Why this matters
Today a smart tool can teleport mid-drag because a Realm observation fires during the gesture and reloads persisted geometry over the live drag. Anchor edits get swallowed by the whole-tool move gesture, so fine adjustment of an endpoint is unreliable. The curved-pass control point has no anchor at all, so the curve's bow can't be shaped after placement. Net effect: authoring tactics feels slippery and the curve tool is half-broken.

## Findings covered
- [`CoreEngine/.../SmartTools.swift:320`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift#L320) — drag never sets `MVO.isDragging`, so a Realm observation mid-drag reloads persisted geometry and makes the tool jump (the line tools guard with `isDragging`/`ignoreUpdates`). **Fix:** set `MVO.isDragging=true` on drag start, `false` in `onEnded` before persist, mirroring the line-tool guard.
- [`CoreEngine/.../SmartTools.swift:202`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift#L202) — whole-tool move is `highPriorityGesture` while anchors are plain `.gesture`; anchor drags can be swallowed by the move. **Fix:** make the anchor drags `highPriorityGesture` and drop the body move to a lower-priority gesture so anchors win.
- [`CoreEngine/.../SmartTools.swift:228`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift#L228) — curve-arrow control point can not be edited; only start/end anchors render, center never recomputed. **Fix:** add a third anchor bound to `lifeCenterX/Y` for the control point on curve tools (and other 3-point tools), persisting it like start/end.

## Scope
**In scope:**
- Guard smart-tool drags with `MVO.isDragging` (start/end) so mid-drag observations don't reload over the gesture.
- Re-prioritize gestures so anchor drags beat the whole-tool move.
- Add a control-point anchor for curve/3-point tools, wired to `lifeCenterX/Y` and persisted.

**Out of scope:**
- Line-tool (`LineToolView`/`CurvedLineToolView`) gesture changes — already guarded, owned elsewhere.
- New tool types, default-geometry, or Properties-panel editing of curve params.
- Multi-point (Tier 2+) authoring — deferred per TASK-014 follow-ups.

## Files expected to change
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift`

## Acceptance criteria
- [ ] Dragging a smart tool no longer jumps when a Realm update arrives mid-drag (`MVO.isDragging` set true on start, false in `onEnded` before persist).
- [ ] Anchor drags win over the whole-tool move (anchors `highPriorityGesture`, body move lower-priority).
- [ ] The curved-pass control point renders an anchor and is draggable, updating `lifeCenterX/Y`.
- [ ] The control-point edit persists to `ManagedView.centerX/centerY` on drag end.
- [ ] Existing 2-point anchors (start/end) and tap-to-add / move / select / delete behavior unchanged for all other tools.

## Verification (build + sim)
1. `/build` clean (CoreEngine + app).
2. iPad sim (headless ok): place a curved pass, drag the body and confirm it tracks the finger without snapping back; drag the start anchor and confirm the anchor moves (not the whole tool); drag the new control anchor and confirm the curve's bow reshapes and survives reload.

## Open questions / risks
- Whether `isDragging`/`ignoreUpdates` semantics on the line tools map cleanly onto `SmartToolManaged`'s single `MVO`, or whether the smart-tool path needs its own guard flag — verify the observation that reloads geometry actually respects `isDragging` before relying on it.
- Anchor hit-target overlap: at small `w`, the third (control) anchor may sit close to start/end; confirm it stays independently grabbable.

## Outcome (2026-06-26) — DONE
Drag now sets `isDragging`/`ignoreUpdates` (move + anchors) so a mid-drag Realm observation can't reload geometry and jump the tool; anchors use `highPriorityGesture` so they win over the whole-tool move; curve/angle tools got an editable control anchor (was frozen).
