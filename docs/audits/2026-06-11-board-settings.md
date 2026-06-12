**Target.** Board Settings — BoardSettingsBar, BEO board-settings state, ActivityPlan persistence chain, background rendering chain.
**Scope.** `Ludi Boards/views/Windows/BoardSettingsToolBar.swift`, `Ludi Boards/CanvasEngine/BoardEngineObject.swift` (board fields), `Ludi Boards/Providers/Sports.swift`, `Ludi Boards/views/Backgrounds/*` (BoardBackgrounder, SoccerFieldBG, FootballFieldView, ImageBgView), CoreEngine `ActivityPlan.swift` + `ActivityPlanO.swift`, `Ludi Boards/views/Sheets/ActivityPlanSingleView.swift`, `Ludi Boards/CanvasEngine/CanvasMenuView.swift` (CAP wiring).
**Date.** 2026-06-11

> Audited immediately before a fix round (user pre-authorized fixes; see git history
> for the same-day remediation). This file records the PRE-FIX state.

---

# Audit — Board Settings

> **TL;DR.** The live edit path works (every control updates the board on screen), but persistence is a one-way street into a row that usually doesn't exist: settings save to ActivityPlan, nothing ever loads them back, every save stomps the stored colors with transparent black, and the default board has no ActivityPlan row — so for a first-launch free user, board settings are 100% ephemeral.

**Lines audited.** ~2,000 read directly, plus a 3-agent mapped pass over the persistence chain, background views, and every BEO board-field consumer.

---

## Part 1 — Architectural breakdown

### The settings bar (live editor)

`BoardSettingsBar` (BoardSettingsToolBar.swift:14) is a horizontal scroll of controls inside the CanvasMenuView drawer: lock, delete-all, recordings/record, undo/history, board picker (sheet over `getAllMinis()`), rotate ±22.5°, line stroke ±10, background color, line color. Every edit writes a `@Published` BEO field → the board re-renders live. Each edit also calls `saveToRealm()`.

```swift
// Ludi Boards/views/Windows/BoardSettingsToolBar.swift:436
func saveToRealm() {
    if let activityPlan = self.BEO.realmInstance.findByField(ActivityPlan.self,
                            value: self.BEO.currentActivityId) {
        ...writes backgroundView/Rotation/LineStroke + RGBA from LOCAL @State...
```

The guard is the first problem: no ActivityPlan row → silent no-op.

### Persistence model — ActivityPlan

`ActivityPlan` (CoreEngine `Models/Master/ActivityPlan.swift:50-62`) carries the full background block: width/height, backgroundRGBA, backgroundLine RGBA, stroke, rotation (default **−90**), `backgroundView` ("Sol"). Defaults mix scales: bg color 0–1 (`0.2/0.78/0.34`), line color 0–255 (`255.0`). `ActivityPlanObject` (CAP) round-trips every field to `@Published` mirrors; its only save caller is ActivityPlanSingleView's save button. CanvasMenuView loads CAP on activity change and then **never reads it** — dead work.

### The missing half of the loop

Nothing in the live app copies `ActivityPlan.background*` into BEO. The only loader in repo history was `threeLoadActivityPlan()` in `BoardEngineById.swift` — dead code, deleted in this branch's canvas fix round. `BEO.changeActivity` switches IDs and tool actions only.

### Background rendering chain

`BoardEngine` renders the tools ZStack at `boardWidth×boardHeight` (5000×6000) with `.background(FieldOverlayView(width: canvasWidth, height: canvasHeight, ...))` — note **canvas** size (8000×8000), not board size. FieldOverlayView wraps a fixed-size ZStack in a GeometryReader whose `geometry` is unused:

```swift
// Ludi Boards/views/Backgrounds/BoardBackgrounder.swift:24
GeometryReader { geometry in        // geometry never used
    ZStack {
        background.frame(width: width, height: height)   // 8000×8000
        overlay.frame(width: width, height: height)
    }
}
```

GeometryReader anchors children top-leading, so the 8000×8000 block hangs off the board's top-left corner: the bg-color apron extends only right/down, and every field view (center-aligned inside the 8000 frame) centers at (4000,4000) in tool space while the board's center is (2500,3000). **The visible field is offset +1500x/+1000y from where tools spawn and lines draw.**

The registry (`Sports.swift`) maps 10 board names → views. Vector fields (SoccerFull/Half, BasicSquare) honor line color/stroke/rotation from BEO; `ImageBgView` boards (Soccer 1/2, Basketball 1–3, Pool) honor only size; `FootballFieldView` ignores rotation; `SolBackground` is a fixed 5000×5000 image.

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | realm-cocoa 20.0.4 / realm-core 20.1.4 | ActivityPlan persistence, `@Persisted` background fields | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |
| `SwiftUI` | SDK | All views; `Color(red:green:blue:opacity:)` expects 0–1 components | https://developer.apple.com/documentation/swiftui |
| `CoreEngine` | local | ActivityPlan/ActivityPlanObject, ColorProvider.toRGBA (0–1 via UIColor.getRed) | — internal — |

---

## Part 2 — Honest assessment

### What's working

- **Live editing is solid** — every control writes a `@Published` BEO field and the board updates immediately; the board picker's keys are byte-identical between `getAllMinis()` and `getAllBoards()`, so a picked board always resolves.
- **The vector soccer fields are the real deal** — proportionally scaled penalty/goal areas from real field dimensions, honoring BEO line color/stroke/rotation (SoccerFieldBG.swift:40-76).
- **The color pipeline is internally consistent once touched** — pickers produce 0–1 colors, `toRGBA()` returns 0–1, `getColor()` round-trips correctly after the first user pick.
- **One settings surface** — the bar lives in the drawer next to the tools; the old standalone-window plumbing (closeWindow, NavStackMessage "board settings") is inert rather than conflicting.

### Findings

```
▌ CRITICAL  ·  Ludi Boards/views/Windows/BoardSettingsToolBar.swift:436
  Persistence is write-only. saveToRealm writes ActivityPlan but NOTHING
  loads ActivityPlan.background* back into BEO — the only loader died with
  BoardEngineById.swift. Every saved setting is ignored on relaunch and on
  activity switch; the board always renders compile-time defaults.
  └─ add a BEO loader (plan → board fields, unit-normalized) called on
     launch and in changeActivity

▌ CRITICAL  ·  Ludi Boards/views/Windows/BoardSettingsToolBar.swift:445
  Every save stomps the stored colors. bgColor/lineColor are local @State
  initialized to Color.clear and never restored by loadFromRealm;
  Color.clear.toRGBA() returns (0,0,0,0) — NOT nil. One rotation or stroke
  tap overwrites backgroundRGBA and backgroundLineRGBA with transparent
  black. Silent today only because finding #1 means nothing reads them.
  └─ persist from BEO truth, not from local picker state

▌ CRITICAL  ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:68
  The default board has no ActivityPlan row. currentActivityId is "" on
  first launch, findByField finds nothing, and saveToRealm silently no-ops
  — free users lose every board setting with zero feedback.
  └─ create a default ActivityPlan on first board load and key the board
     (and orphaned boardId=="" tools) to it

▌ HIGH      ·  Ludi Boards/views/Backgrounds/BoardBackgrounder.swift:25
  Background offset from the board. FieldOverlayView's unused GeometryReader
  anchors the fixed 8000×8000 content top-leading in the 5000×6000 board
  frame: field centers land at (4000,4000) vs board center (2500,3000), and
  the color apron extends only right/down. Tools spawned at board center
  don't sit at field center.
  └─ drop the GeometryReader; pass boardWidth/boardHeight, not canvas size

▌ HIGH      ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:158
  Color unit chaos. BEO defaults are 0-255 scale (48/128/20) fed into
  SwiftUI Color(red:) which clamps to white; ActivityPlan defaults mix 0-1
  bg with 0-255 line colors. Any loader must normalize or saved boards
  render wrong.
  └─ normalize BEO defaults to 0-1; divide >1 values by 255 on load

▌ MEDIUM    ·  Ludi Boards/views/Sheets/ActivityPlanSingleView.swift:155
  Alpha slider writes a stale local (colorOpacity, stuck at 1.0) into
  BEO.boardBgAlpha instead of the APO value the slider actually binds; its
  color pickers write BEO but never APO, so colors are lost unless the user
  separately taps save. Reachable from Home → activity sheet.
  └─ use APO.backgroundAlpha; mirror picker colors into APO

▌ MEDIUM    ·  Ludi Boards/views/Windows/BoardSettingsToolBar.swift:326
  Stroke clamp floor (50) above the default stroke (10): the first "−" tap
  JUMPS the stroke from 10 to 50. Rotation/stroke badges show raw doubles
  ("22.5", "1.0").
  └─ clamp 10...200; format labels as Int/degrees

▌ MEDIUM    ·  Ludi Boards/Providers/Sports.swift:60
  Settings that do nothing for most boards: rotation affects only the 2
  vector soccer fields; line color/stroke affect 4 of 10; ImageBgView and
  Sol ignore everything. No user feedback about which settings apply.
  └─ acceptable for free v1 — but worth a line in the picker UI eventually

▌ MEDIUM    ·  Ludi Boards/views/Windows/BoardSettingsToolBar.swift:402
  Board picker never highlights the current board (isCurrentPlan is never
  set true; backgroundView @State never written), and the sheet relies on
  implicit environment inheritance for BEO-dependent minis —
  SoccerFieldFull/Half minis fatalError if ever rendered without BEO.
  └─ initialSelected: BEO.boardBgName; inject .environmentObject explicitly

▌ LOW       ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:154
  Dead settings machinery: boardStartPosX/Y (no readers or writers),
  setColor(red:green:blue:alpha:) overload (no callers), boardBgView()
  (no callers), deviceScreenBounds (written once, never read),
  closeWindow() (never called), colorOpacity/lineOpacity (round-trip-only),
  CAP load in CanvasMenuView (loaded, never read). ActivityPlan.width/height
  persisted but never connected to boardWidth/boardHeight (no writers).
  └─ prune opportunistically; wire width/height only when the feature is real

▌ LOW       ·  Ludi Boards/Providers/Sports.swift:43
  Sol default background is a fixed 5000×5000 image under a 5000×6000 board
  — bottom 1000pt of the default board has no background. Frozen
  UIScreen-@State sizing in the drawer/pickers misbehaves on iPad rotation
  and Split View.
  └─ center it (covered by the FieldOverlayView fix); revisit sizing post-v1
```

### Tradeoffs worth naming

Keeping board settings on the ActivityPlan row (rather than AppStorage) is the right call — it makes "a board" a real, shareable object and the paid Firebase tier inherits it for free. The cost is that the free flow must guarantee a default ActivityPlan exists, which the current code never does. The string-keyed background registry trades type safety for trivially easy board additions; that's fine at 10 entries. The per-sport view families (vector vs image) mean settings coverage will always be uneven — rotation on a raster image is cheap to add (`rotationEffect`), but nobody has decided whether image boards *should* rotate.

---

## Bottom line

Fix the loop, not the bar. The bar's controls are fine; what's missing is the read side (plan → BEO on load/switch), a guaranteed default ActivityPlan row, and a save that writes BEO truth instead of `Color.clear` residue. Add the FieldOverlayView centering fix so the field actually sits under the tools, normalize the color units once, and board settings go from "decorative" to "working feature" in one round. Everything else (image-board rotation, width/height editing, Firebase sync) is paid-tier or post-v1 work.

**Adjacent observations.** `_ActivityPlanBindingView` contains a complete, correct load/save board-settings editor — dead code, but worth mining if the settings UI is ever redesigned. The Wrlds target forks BoardEngineObject/BoardEngineView with the same fields; any schema decisions here will need mirroring when Wrlds migrates.
