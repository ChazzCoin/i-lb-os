**Target.** Pool tools (PoolBallTool) end-to-end on the redesign board — Library tab, create, render, interaction.
**Scope.** `CoreEngine/.../MVEngineBuilder.swift` (PoolBallTool enum + Build + color/number), `.../ManagedViews/Shapes/PoolBallToolView.swift` (PoolBallIcon), `.../ManagedViews/ManagedToolView.swift` (ManagedViewTool sizing), `Ludi Boards/Redesign/Panels.swift` (Pool tab + addPool).
**Date.** 2026-06-27

# Audit — Pool tools

> **TL;DR.** The pool *logic* is fine (correct ball→colour→solid/stripe→number), but the render is wrong: `PoolBallIcon` is a fixed **30×30** picker icon with a **size-3 font**, and the board reuses it as the tool — so a placed ball draws as a tiny 30pt dot inside the 300pt frame the engine gives it (≈3pt at board scale). It's not "nothing works" — it's "the ball is microscopic and unreadable."

**Scope.** PoolBallTool enum/Build/colour, PoolBallIcon, ManagedViewTool, the Pool tab + addPool create path
**Lines audited.** ~260

---

## Part 1 — Architectural breakdown

### Create path — correct
`addPool` makes a `pool` ManagedView at board centre, sized 150:

```swift
// Ludi Boards/Redesign/Panels.swift  (addSimpleTool, toolType "pool")
mv.toolType = "pool"; mv.subToolType = subType   // "1"…"15"/"8"/"0"
mv.x = 2500; mv.y = 3000; mv.width = 150; mv.height = 150
```

This is consistent with the other families — the geometry is set correctly.

### Render dispatch — correct routing, wrong sizing
`toolType "pool"` → `PoolBallTool.Build(name:)` → `ManagedViewTool { PoolBallIcon }`. `ManagedViewTool` frames its content to the tool's size and positions it:

```swift
// ManagedToolView.swift:112,132   (enableManagedViewBasic)
.frame(width: MVO.lifeWidth * 2, height: MVO.lifeHeight * 2)   // 150*2 = 300pt
.position(x: MVO.position.x + MVO.lifeWidth, y: MVO.position.y + MVO.lifeHeight)
```

So the engine hands `PoolBallIcon` a 300pt frame — exactly like the soccer disc gets, which fills it via `GeometryReader`.

### The ball view — a fixed-size icon, not a board tool
`PoolBallIcon` ignores that frame and draws at a hardcoded 30pt with a 3pt font:

```swift
// PoolBallToolView.swift:58-60, 73-90
let width: Double = 30.0
let height: Double = 30.0
…
Circle().fill(ballType.color).frame(width: width, height: height)   // always 30pt
  .overlay( … Text("\(ballType.number)").font(.system(size: 3)) … ) // always 3pt
```

Compare the soccer disc, which scales to the frame:

```swift
// SoccerPlayerToolView.swift
GeometryReader { geo in let d = min(geo.size.width, geo.size.height); … }   // fills the frame
```

`PoolBallIcon` was written as the 30×30 picker icon (`BuildIcon()` uses it too); TASK-060 reused it verbatim as the on-board tool, so every placed ball is a 30pt dot centred in a 300pt invisible frame.

### Ball classification — correct
`number > 8` → stripe (9–15), `que` → cue, else → solid (1–7) and 8-ball (8, solid black). The `color` switch and `number = Int(rawValue) ?? 0` are right. The only problem is everything renders at icon scale.

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | 20.0.4 | `ManagedView` pool tool persistence | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |
| `CoreEngine` | local SPM | `PoolBallTool`, `PoolBallIcon`, `ManagedViewTool` | in-repo `CoreEngine/` |
| `SwiftUI` | iOS SDK | the drawn ball (`Circle`/`mask`/`overlay`) | https://developer.apple.com/documentation/swiftui |

---

## Part 2 — Honest assessment

### What's working

- **Create + dispatch are correct** — pool balls persist as `pool` ManagedViews and route to `PoolBallTool.Build` → `PoolBallIcon`. `Panels.swift addSimpleTool`, `MVEngineBuilder.swift`.
- **Ball classification is right** — colour, solid/stripe (`number > 8`), cue, and 8-ball all map correctly. `MVEngineBuilder.swift` PoolBallTool `color`/`number`.
- **The Pool tab no longer crashes** — the `substring` clamp + safe label fix held.

### Findings

```
▌ HIGH      ·  CoreEngine/.../Shapes/PoolBallToolView.swift:58-60
  PoolBallIcon hardcodes width/height = 30 and a size-3 font. ManagedViewTool
  frames it to lifeWidth*2 (300pt), but the ball draws at a fixed 30pt centred
  in that frame — so a placed pool ball is a tiny dot (~3pt at the ~0.1 board
  scale) with an unreadable number. This is the "nothing seems right".
  └─ make the ball fill its frame via GeometryReader and scale the number font
     to the diameter (mirror SoccerPlayerToolView), or add a board-sized
     PoolBallManagedView instead of reusing the 30pt picker icon

▌ MEDIUM    ·  CoreEngine/.../Shapes/PoolBallToolView.swift:64-90
  The stripe mask (Rectangle height 25) and the inner number circle (width/2)
  are all derived from the fixed 30pt — even once the outer size is fixed they
  won't scale unless rewritten in frame-relative terms.
  └─ express stripe band + number bubble as fractions of the diameter

▌ MEDIUM    ·  ManagedToolView.swift:112,132 + PoolBallToolView.swift:58
  The hit area is lifeWidth*2 (300pt) but the visible ball is 30pt, so the
  tap/drag target is a large invisible box around a tiny dot — selecting/moving
  a ball feels disconnected from what's drawn. Fixing the fill (HIGH) also fixes
  the perceived hit target.
  └─ once the ball fills the frame, the visible and hittable areas align

▌ LOW       ·  CoreEngine/.../MVEngineBuilder.swift:264-265
  PoolBallTool.displayName still does substring(from: 5) on 1–2 char rawValues.
  It no longer crashes (substring is clamped) but returns "" — wrong for pool.
  The Pool tab dodges it with a custom label, but the enum method is broken for
  any future caller.
  └─ replace with a real label (Cue / 8-ball / "Ball N")

▌ LOW       ·  CoreEngine/.../Shapes/PoolBallToolView.swift:52
  PoolBallIcon stores ballType in @State (init-injected) and doesn't observe the
  ManagedView. Fine today (pool colour is intrinsic, not picker-driven), but it
  means a pool ball won't reflect any future per-tool edit. Note, don't fix now.
```

### Tradeoffs worth naming

The shortcut in TASK-060 was reasonable under time pressure — reusing the existing `PoolBallIcon` avoided adding 16 image assets and got the ball *drawing* instead of rendering an invisible missing `Image(name)`. But "draws something" isn't "draws correctly on the board": the icon was built for a 30pt palette cell, and the board needs a frame-filling tool view. Every other tool family that renders custom geometry (soccer disc, smart tools, shapes) scales to `lifeWidth`; pool is the one that doesn't. The fix is to make pool follow that same contract.

---

## Bottom line

One real bug, clearly located: `PoolBallIcon` renders at a fixed 30pt and must fill the frame the engine already gives it (a `GeometryReader` that scales the circle + number, exactly like `SoccerPlayerToolView`). Do that and pool balls become correctly-sized, readable, and properly tappable in one change — the classification/colour logic underneath is already correct. Either rewrite `PoolBallIcon` to be size-agnostic (and keep a 30pt wrapper for the picker), or add a dedicated `PoolBallManagedView` for the board. Until then, pool is technically wired but visually unusable.

**Adjacent observations.** The same fixed-30pt icon is used by `BuildIcon()` for the Library cell — that usage is *correct* (it wants 30pt); only the board `Build` path needs the frame-filling version, so don't change the icon out from under the picker.
