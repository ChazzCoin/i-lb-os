**Target.** The redesign left tool rail (`EngineToolRail` / `ToolRail`) and its wiring to engine actions.
**Scope.** `Ludi Boards/Redesign/Components.swift` (rail), `Ludi Boards/CanvasEngine/BoardEngineObject.swift` (draw/lock state + actions), `Ludi Boards/Redesign/RedesignBoardCanvas.swift` (pan/zoom + gesture lock), `Ludi Boards/CanvasEngine/BoardEngineView.swift` (`BoardEngine` draw gesture), `Ludi Boards/Redesign/TacticalBoardView.swift` (rail mount).
**Date.** 2026-06-26

# Audit — left tool rail

> **TL;DR.** The rail is three working tools (select, draw-straight, draw-curved) wearing nine buttons. Pan is a byte-identical duplicate of select, and five buttons (photo/person/shape/flag/color) ship live but do nothing — they fall through to a `default` that just stops drawing. The draw path itself is clean and correctly wired.

**Scope.** 5 files (the rail + every BEO action it touches + the two gesture surfaces that consume its state).
**Lines audited.** ~330 (rail + drawing model + both canvas gesture blocks).

---

## Part 1 — Architectural breakdown

### Static / engine split

The rail is deliberately two structs. `ToolRail` (Components.swift:177) is pure visual — a `[(symbol, dividerAfter)]` table rendered as `RailButton`s, BEO-free so the preview/scaffold path renders without an engine. `EngineToolRail` (Components.swift:208) wraps it, derives the active index from real engine state, and routes taps to `BoardEngineObject` methods.

```swift
// Ludi Boards/Redesign/Components.swift:186
static let tools: [(String, Bool)] = [
    ("cursorarrow", false), ("hand.draw", true),
    ("pencil.tip", false), ("scribble.variable", false), ("photo", true),
    ("person", false), ("triangle", false), ("flag", true),
    ("paintbrush.pointed", false),
]
```

Tool identity is the **array index** — `EngineToolRail` maps positions 0–8 to actions. Clean for previews, but it makes the tool↔action contract positional and implicit (see Findings).

### Tap routing

`handleTap` is the entire wiring surface. Four cases are real; the rest collapse into one `default`.

```swift
// Ludi Boards/Redesign/Components.swift:223
private func handleTap(_ i: Int) {
    switch i {
    case 0:  BEO.disableDrawing()                                   // select / cursor
    case 1:  BEO.disableDrawing(); BEO.gesturesAreLocked = false    // hand / pan
    case 2:  BEO.toggleDrawingMode(subType: "line_straight")        // draw straight
    case 3:  BEO.toggleDrawingMode(subType: "line_curved")          // draw curved
    default: BEO.disableDrawing()  // photo/person/shape/marker/colour — wired in later tasks
    }
}
```

### Drawing model (the state the rail drives)

Three `@Published` fields on BEO carry the rail's effect: `isDraw`, `shapeSubType`, `gesturesAreLocked`. The methods are small and correct:

```swift
// Ludi Boards/CanvasEngine/BoardEngineObject.swift:99
func enableDrawing(subType: String = …line_straight…) {
    shapeSubType = subType; isDraw = true; gesturesAreLocked = true
}
func disableDrawing() { isDraw = false; gesturesAreLocked = false }
func toggleDrawingMode(subType: String = …) {
    if isDraw && shapeSubType == subType { disableDrawing() } else { enableDrawing(subType: subType) }
}
```

`enableDrawing` sets `gesturesAreLocked = true` so the drag draws instead of panning — that single flag is the coupling point between the rail and both canvas gestures.

### Active-state derivation

`activeIndex` reads engine state rather than a local `@State`, so the highlight reflects the real draw mode and survives re-renders:

```swift
// Ludi Boards/Redesign/Components.swift:211
private var activeIndex: Int {
    guard BEO.isDraw else { return 0 }            // cursor
    switch BEO.shapeSubType {
    case "line_curved": return 3                  // scribble
    default:            return 2                   // pencil (straight)
    }
}
```

Note the codomain: `{0, 2, 3}` only. Indices 1 and 4–8 can never light up.

### Where the rail's state lands (the two consumers)

The redesign canvas (`RedesignBoardCanvas`) hosts `BoardEngine()`, which is the struct in `BoardEngineView.swift:15` — the same struct that owns the draw gesture. So the rail's draw state reaches a real gesture:

- **Pan/zoom** — `RedesignBoardCanvas.swift:46` & `:64` bail with `if BEO.gesturesAreLocked { return }`, so draw mode freezes the canvas.
- **Draw** — `BoardEngineView.swift:75` attaches `simultaneousGesture(BEO.isDraw ? DragGesture()… : nil)`; on end it saves a line whose `subToolType = BEO.shapeSubType` (`BoardEngineView.swift:320`).

The chain `rail tap → toggleDrawingMode → isDraw/shapeSubType → BoardEngine draw gesture → persisted line` is complete and correct. I verified it by reading end-to-end (didn't re-run an interactive draw this session, but the wiring is intact and was exercised via the `REDESIGN_DRAW` harness in earlier work).

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| SwiftUI | iOS 17+ SDK | rail views, `Button`/`onHover`, `DragGesture`/`MagnificationGesture` | https://developer.apple.com/documentation/swiftui |
| CoreEngine | local pkg | `BoardEngineObject`, `ViewEngine.Tool.ShapeTool`, `GlobalPositioningZStack` | (in-repo `CoreEngine/`) |

---

## Part 2 — Honest assessment

### What's working

- **Draw straight / curved are fully wired** — tap → `toggleDrawingMode` → `isDraw`+`shapeSubType` → the live `BoardEngine` draw gesture saves a line with the right subtype (Components.swift:227, BoardEngineView.swift:75,320). This is the rail's real function and it's correct end-to-end.
- **Active state is derived from engine truth** — `activeIndex` reads `BEO.isDraw`/`shapeSubType`, not a local flag (Components.swift:211), so the highlight can't drift from actual draw mode.
- **Static/engine split is the right shape** — `ToolRail` stays BEO-free and previewable; `EngineToolRail` owns the wiring (Components.swift:177 vs 208). Good separation.
- **`toggleDrawingMode` UX is sensible** — re-tap the active line tool to exit draw, tap the other to switch without leaving draw mode (BoardEngineObject.swift:110).

### Findings

```
▌ HIGH      ·  Ludi Boards/Redesign/Components.swift:229
  5 of 9 rail buttons are dead in the SHIPPED board: photo, person,
  triangle (shape), flag (marker), paintbrush (colour) all fall to
  `default: BEO.disableDrawing()`. They render identically to working
  tools (same RailButton, no disabled/coming-soon affordance), so a
  tap reads as "deselect" with no feedback. The live board (RD-6,
  useEngineCanvas) mounts EngineToolRail, so users see and tap these.
  └─ wire them, or hide them until wired. Note: shape/marker live in
     the Library panel and colour lives in Properties — decide whether
     the rail should duplicate those panels at all before wiring.

▌ MEDIUM    ·  Ludi Boards/Redesign/Components.swift:226
  Pan (index 1) is functionally identical to Select (index 0): both
  call disableDrawing(), which already sets gesturesAreLocked=false,
  so the extra `gesturesAreLocked = false` is a redundant no-op. Pan
  can never show active (activeIndex never returns 1). Since the canvas
  already pans from anywhere regardless of mode (RedesignBoardCanvas
  full-screen contentShape), a separate "hand/pan" mode is vestigial.
  └─ drop the hand button, or give pan a real distinct behaviour/state.

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:99-108
  `gesturesAreLocked` is overloaded: it is BOTH the pill's explicit
  canvas lock AND the draw-mode pan-suppression. Consequences via the
  rail: (a) entering draw mode lights the pill's lock icon (it shows
  `locked: BEO.gesturesAreLocked`); (b) tapping select/pan/any dead
  button calls disableDrawing(), which silently clears a lock the user
  set with the pill. Two controls write one flag and stomp each other.
  └─ split draw-suppression from the user-facing lock (separate flags),
     or have the lock OR-in with draw mode instead of sharing storage.

▌ LOW       ·  Ludi Boards/Redesign/Components.swift:211-217
  activeIndex codomain is {0,2,3}; 6 of 9 buttons can never display an
  active state. Correct for the dead ones (they do nothing), but it
  means most of the rail has no selected/unselected feedback.
  └─ falls out once dead/duplicate buttons are resolved.

▌ LOW       ·  Ludi Boards/Redesign/Components.swift:186 + :223
  Tool identity is positional — handleTap and activeIndex switch on
  hard-coded indices into the `tools` tuple array. Reordering or
  inserting a tool silently re-points the wiring (insert at 2 and
  "pencil" becomes a draw-curved, etc.). No enum/typed identity.
  └─ key tools by a typed case, not array position.

▌ LOW       ·  tasks/ROADMAP.md:51
  Doc drift: TASK-006 is recorded as "Left ToolRail wired (select /
  pan / draw / shape / marker / color) ✅". Actually wired: select,
  draw-straight, draw-curved. Pan == select; shape/marker/color are
  the dead default branch.
  └─ correct the task's recorded scope or reopen it.
```

### Tradeoffs worth naming

The positional tool table buys cheap previews (a BEO-free `ToolRail` renders the same array the engine wires) at the cost of an implicit, fragile index contract between the two structs. That's a fair trade for a 9-item rail — until someone reorders it. Separately, reusing `gesturesAreLocked` for draw-mode pan-suppression is the minimal implementation (one flag, no new state), but it's the root of the lock/draw entanglement: the simplicity is real and so is the cross-control clobber. Both are "small now, will bite when the rail grows / when a user actually leans on the lock."

---

## Bottom line

The rail's core — drawing — is solid and correctly wired. The problem is everything around it: it advertises nine tools and delivers three, with pan duplicating select and five live-but-dead buttons that give zero feedback on tap. If this were mine I'd do two things before anything else: (1) hide or disable the five unwired buttons in the shipped board (a dead button that looks alive is worse than no button), and decide whether they should even exist given shape/marker live in Library and color lives in Properties; (2) separate the explicit canvas lock from draw-mode pan-suppression so the rail stops silently clearing the user's lock. Neither is a rewrite — the rail's bones are fine, it's the unfinished surface that ships as if finished.

**Adjacent observations.** The same overloaded `gesturesAreLocked` flag is read by `EngineControlPill` (`locked:` indicator) and written by both the pill's lock toggle and the rail — so this finding spans the rail *and* the bottom pill; a fix touches both. The bottom pill also wires `onRedo` to `undoLastToolAction()` (Components.swift:322, "no redo yet") — out of rail scope but a related live-but-misleading control.
