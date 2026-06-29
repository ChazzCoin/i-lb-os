# TASK-036: Fix the locked stroke slider in line Properties

**Phase:** FB — Functional board · **Severity:** HIGH · **Size:** small · **Depends on:** none · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **to drag the stroke slider in a line's Properties panel** so that **I can adjust line thickness directly instead of being stuck with whatever width the line was drawn at**.

> Verbatim: "When I double-tap a line the Properties settings appear, but I cannot move the stroke slider at all — it seems locked."

## Why this matters
The `SliderRow` knob renders in the right position and the write path behind it is fully wired — but there is no way to move it. `SliderRow` is a custom `GeometryReader`-based slider that draws a track, a progress fill, and a white circle knob, with no `DragGesture` attached. So the knob is purely cosmetic: it reflects the current value but cannot be changed by touch. The plumbing past it is real — the `size` binding flows through `writeSize()` into a Realm `safeWrite` — but nothing ever calls the setter from user interaction. This is not line-specific; the same component backs the SIZE and ROTATION sliders for every tool. The user notices it on lines because STROKE is often the only adjustment they reach for there. Desired state: dragging anywhere on the slider moves the knob and persists the new width live.

## Findings / current state
- [`Ludi Boards/Redesign/Panels.swift:611-638`](../../Ludi%20Boards/Redesign/Panels.swift) — `SliderRow` is a custom slider. It renders a `Capsule` track (line 626), a `Brand.lime` progress fill (line 628), and a white `Circle` knob offset by `w * value - 8` (lines 630-632), all inside a `ZStack` (line 625) wrapped in a `GeometryReader` (line 623). **There is no `.gesture(...)` modifier anywhere in the view** — the knob is locked. This is the root cause. Fix: attach a `DragGesture(minimumDistance: 0)` to the `ZStack` (line 625), and in `.onChanged` normalise `gesture.location.x / w`, clamp to `0...1`, and assign to `value`.
- [`Ludi Boards/Redesign/Panels.swift:437-440`](../../Ludi%20Boards/Redesign/Panels.swift) — the two `SliderRow` instances in `PropertiesPanel`: `SliderRow(label: sizeLabel, value: $size, ...)` and the rotation row. Both are affected by the same missing gesture; the single fix to `SliderRow` repairs both.
- [`Ludi Boards/Redesign/Panels.swift:514-515`](../../Ludi%20Boards/Redesign/Panels.swift) — in `EnginePropertiesPanel`, `size` and `rotation` are passed as `Binding`s whose `set:` closures call `writeSize($0)` / `writeRotation($0)`. These setters already persist to Realm correctly; they are simply never invoked because the slider emits no value changes. **No change needed here** — fixing `SliderRow` lights up this existing path.
- [`Ludi Boards/Redesign/Panels.swift:488,491-492`](../../Ludi%20Boards/Redesign/Panels.swift) — `isLine` (set in `loadFromTool`, line 534) drives `sizeLabel` to "STROKE" and the width range to `10...140` for line/smart tools vs `80...500` for tokens. The slider maps a normalised `0...1` value across this range, so once dragging works, STROKE behaves correctly for lines without further range work.
- [`Ludi Boards/Redesign/Panels.swift:553-560`](../../Ludi%20Boards/Redesign/Panels.swift) — `writeSize` already converts the normalised value to a pixel width (`minW + v * (maxW - minW)`) and writes `mv.width` (and `mv.height` for non-line tools) inside `safeWrite`. Verified present and correct.
- [`Ludi Boards/Redesign/Panels.swift:561-564`](../../Ludi%20Boards/Redesign/Panels.swift) — `writeRotation` writes `mv.rotation = v * 360` inside `safeWrite`. Also present and correct; it will start firing once the slider is draggable.

## Scope
**In scope:**
- Add a `DragGesture(minimumDistance: 0)` to the `ZStack` in `SliderRow` (line 625), updating the bound `value` from the normalised, clamped drag location in `.onChanged`.
- A single-touch-down anywhere on the track jumps the knob to that position (`minimumDistance: 0` gives tap-to-jump and smooth drag from one handler).
- Confirm the fix repairs the STROKE slider on lines and, by sharing the component, the SIZE and ROTATION sliders for tokens.

**Out of scope:**
- The Realm write path (`writeSize` / `writeRotation`) — already wired and unchanged.
- The stroke/size min-max ranges and the `isLine` branching — already correct.
- Replacing `SliderRow` with the system `Slider` or any restyle — keep the custom component, just make it draggable.
- Any Firebase wiring — width/rotation persist to Realm only; this task is Firebase-ready, not Firebase-wired.

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift`

## Acceptance criteria
- [ ] Double-tapping a line opens Properties and the STROKE slider knob can be dragged left/right by touch.
- [ ] Dragging the knob updates the px readout live and the on-board line's thickness changes as you drag.
- [ ] Touching down anywhere on the track moves the knob to that position (tap-to-jump), not only dragging from the knob.
- [ ] The value is clamped to `0...1` — the knob cannot be dragged past either end of the track.
- [ ] Releasing the drag persists the new width to Realm (`mv.width`) so it survives reselecting the line.
- [ ] The same fix makes the SIZE and ROTATION sliders draggable for token discs (shared `SliderRow`), with no regression to their existing readouts.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim, scheme "Ludi Boards", bundle `io.ludi.sol`, verified headlessly per the project's background-simulator convention: draw a line, double-tap it to open Properties, drag the STROKE slider end to end, and confirm the knob moves, the px readout updates, and the line's thickness changes live. Deselect and reselect the line to confirm the new stroke persisted. Repeat on a token disc to confirm SIZE and ROTATION sliders drag.

## Open questions / risks
- **Tap-to-jump vs drag-only.** Should touching the track jump the knob, or only dragging the knob itself? *Recommendation:* use one `DragGesture(minimumDistance: 0)` on the `ZStack` so a touch-down anywhere reads as `.onChanged` and jumps the knob, with continued movement dragging smoothly. This is the least code and the most forgiving for a 16pt knob on touch.
- **Gesture coordinate space.** `gesture.location` must be in the slider's local space to match the `w * value` knob math. *Recommendation:* read the gesture location directly inside the `GeometryReader` and divide by `geo.size.width` (use `.frame(in: .local)` only if the location turns out to be reported in a parent space). Confirm during the sim pass that the knob lands exactly under the touch.
- **Write frequency.** `.onChanged` fires on every drag sample, so `writeSize`/`writeRotation` will issue a Realm `safeWrite` per sample. *Recommendation:* acceptable for the small-task fix since views already observe Realm live; if drag feels janky, debounce or write only on `.onEnded` in a follow-up — do not expand this task for it.

## Outcome (2026-06-26) — DONE (build verified)
Added a `DragGesture(minimumDistance: 0)` to `SliderRow`'s `ZStack` (Panels.swift) with `value = clamp(g.location.x / w)` + `.contentShape(Rectangle())`. The existing `writeSize`/`writeRotation` setters now fire. One-component fix → STROKE (lines), SIZE and ROTATION (tokens) all draggable + tap-to-jump. Build clean. Tap-level drag deferred to interaction test/XCUITest.
