**Target.** Curved-line tool's middle/control anchor (the curve-bend handle) on the redesign board.
**Scope.** `CoreEngine/.../ManagedViews/Lines/CurvedLineToolView.swift` (CurvedLineDrawingManaged, dragCurvedCenterAnchor, fullCurvedLineDragGesture), `MVObject.swift` (quadBezierPoint).
**Date.** 2026-06-27

# Audit — Curved-line control anchor

> **TL;DR.** The control handle is drawn at the curve's *on-curve midpoint* (t=0.5) but its drag moves the *control point* — and the midpoint moves at exactly **half** the control's rate, so the handle crawls at half your finger's speed and your finger runs off it. That's the "stuck / hard to work with." Overlapping 300pt anchor hit-boxes make it worse.

**Scope.** CurvedLineToolView (control + start/end anchors, full-drag, gestures), quadBezierPoint
**Lines audited.** ~270

---

## Part 1 — Architectural breakdown

### The curve + its handles
A quad curve from `lifeStart`→`lifeEnd` with `lifeCenter` as the control point. When `anchorsAreVisible`, four 300pt circles overlay it (start, end, end-triangle, control), plus a 300pt-stroked invisible `MatchedShape` for whole-line hit-testing.

```swift
// CurvedLineToolView.swift:44-47
path.move(to: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY))
path.addQuadCurve(to: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY),
                  control: CGPoint(x: MVO.lifeCenterX, y: MVO.lifeCenterY))
```

### The control handle — drawn at the midpoint, drags the control
The handle circle is positioned at `quadBezierPoint(...)` — the point *on the curve* at t=0.5 — but its drag writes `lifeCenter` (the control point):

```swift
// CurvedLineToolView.swift:95-96  — handle is at the ON-CURVE midpoint
.position(quadBezierPoint(start: …, end: …, control: CGPoint(x: MVO.lifeCenterX, y: MVO.lifeCenterY)))
.gesture(!MVO.anchorsAreVisible ? nil : dragCurvedCenterAnchor())

// :190-191  — but the drag moves the CONTROL point to follow the finger
MVO.lifeCenterX = (value.location.x + dragOffset.width)
MVO.lifeCenterY = (value.location.y + dragOffset.height)
```

And the midpoint is half the control's motion:

```swift
// MVObject.swift:15-19  (t = 0.5)
x = 0.25*start.x + 0.5*control.x + 0.25*end.x   // d(midpoint)/d(control) = 0.5
```

So a finger delta Δ moves the control by Δ but the handle (drawn at the midpoint) only by Δ/2 — the handle visibly lags at half speed and the finger drifts away from it. This is the core "stuck" feel.

### Anchor hit-testing — overlapping 300pt boxes
Start, end, and control handles are each 300×300, and on a shallow curve the control handle (the midpoint) sits between/over the start and end circles. They're plain `.gesture` (not `highPriorityGesture`), and the whole-view `fullCurvedLineDragGesture()` is also always attached:

```swift
// CurvedLineToolView.swift:96-97
.gesture(!MVO.anchorsAreVisible ? nil : dragCurvedCenterAnchor())
.gesture(MVO.anchorsAreVisible ? nil : fullCurvedLineDragGesture())
// :111 — and again at the view root, always attached
.gesture(fullCurvedLineDragGesture())
```

Overlapping equal-size `.gesture`s with no priority → which one wins is ambiguous, so a control-handle drag can be captured by the start/end anchor or the full-line drag instead.

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | 20.0.4 | `lifeCenter`/geometry persistence (`updateRealm`) | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |
| `SwiftUI` | iOS SDK | `Path.addQuadCurve`, `DragGesture`, anchor overlays | https://developer.apple.com/documentation/swiftui |

---

## Part 2 — Honest assessment

### What's working

- **The math model is right** — quad curve with a single control point is the correct primitive; `quadBezierPoint` correctly finds the on-curve point. `CurvedLineToolView.swift:44`, `MVObject.swift:15`.
- **Start/end anchors track 1:1** — they set `lifeStart`/`lifeEnd` to `value.location` directly, so they don't have the control's mismatch. `CurvedLineToolView.swift:213-218`.
- **Anchors gate on `anchorsAreVisible`** — the whole-line drag and the per-anchor drags are mutually exclusive by intent (full-drag bails when anchors show). `:137,183`.

### Findings

```
▌ HIGH      ·  CurvedLineToolView.swift:95-96 + :190-191 (vs MVObject.swift:15)
  The control handle is drawn at the on-curve midpoint (quadBezierPoint, t=0.5)
  but the drag moves the control point. The midpoint moves at HALF the control's
  rate, so the handle tracks your finger at half speed and the finger slides off
  it — the "stuck / unresponsive" feel. The once-computed dragOffset is correct
  only at the start and drifts as they diverge.
  └─ draw the handle AT the control point (lifeCenterX/Y) and drag it 1:1; OR
     keep it on the curve but invert the math so control = 2*finger-(start+end)/2
     (so the on-curve point follows the finger). Either makes it track 1:1.

▌ MEDIUM    ·  CurvedLineToolView.swift:80-99
  start / end / control handles are each 300×300 and cluster on a shallow curve;
  with plain .gesture (no priority) the wrong overlapping anchor can capture the
  drag, so grabbing the middle anchor sometimes moves an endpoint or nothing.
  └─ shrink/space the hit targets, and use highPriorityGesture on the anchors so
     the intended handle wins

▌ MEDIUM    ·  CurvedLineToolView.swift:97,111
  fullCurvedLineDragGesture() is attached on every anchor overlay AND at the view
  root, always. It bails in onChanged when anchorsAreVisible but still *recognises*
  the drag, competing with the anchor gesture for the same touch.
  └─ attach the full-line drag in one place and make it truly inert (or detached)
     while anchors are visible

▌ LOW       ·  CurvedLineToolView.swift:136,182,209
  Every gesture body is wrapped in main { … } even though gesture callbacks are
  already on the main thread — an extra async hop per drag sample adds a frame of
  latency, compounding the sluggish feel.
  └─ drop the redundant main { } in the drag handlers

▌ LOW       ·  CurvedLineToolView.swift:186-189
  dragOffset is captured once (== .zero guard) and only reset on .onEnded. If a
  drag ends off-frame or is interrupted, a stale offset carries into the next drag.
  └─ reset dragOffset at .onChanged start, not just onEnded
```

### Tradeoffs worth naming

Putting the handle *on the curve* (at the visual apex) is a reasonable UX instinct — it's where the user sees the bend, so grabbing there feels natural. The mistake is dragging the *control* point 1:1 with the finger while the handle sits at the midpoint, which moves half as fast. You can keep the on-curve handle (nicer) **if** you do the inverse math so the on-curve point follows the finger and back-solve the control; or you move the handle onto the control point (standard bezier-editor UX, simplest) and accept the handle floats off the curve. Both are valid; the current code is the one combination that feels broken.

---

## Bottom line

One root cause: handle-at-midpoint + drag-the-control = 2:1 mismatch, so it lags and feels stuck. Cheapest correct fix is to make the on-curve handle drive the on-curve point — set `control = 2·finger − (start+end)/2` so the apex tracks your finger exactly — or move the handle to the control point and drag 1:1. Then tighten the overlapping 300pt hit-boxes and the doubled full-drag gesture so the middle anchor reliably wins the touch. After that it'll feel direct instead of sticky.

**Adjacent observations.** The straight-line tool (LineToolView) shares the anchor/gesture pattern but has no control point, so it dodges the HIGH; the overlapping-300pt-hit-box concern (MEDIUM) likely applies there too for start/end.
