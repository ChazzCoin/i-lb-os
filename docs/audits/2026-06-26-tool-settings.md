**Target.** Tool settings surface (per-tool and per-board settings, Properties panel, control pill, legacy MvSettingsBar).
**Scope.** `MvSettingsToolBar.swift`, `BoardSettingsToolBar.swift`, `ToolBarSettings.swift`, `MVSettingsView_DEPRECATED.swift`, `Redesign/Panels.swift`, `Redesign/Components.swift`, `Redesign/TacticalBoardView.swift`, `Redesign/BoardScreenState.swift`, `CanvasEngine/CanvasMenuView.swift`.
**Date.** 2026-06-26

---

# Audit — Tool Settings

> **TL;DR.** The redesign's Properties panel looks complete but its most important controls — size and rotation sliders — are purely decorative and respond to no touch input; everything else is correctly wired except redo, which does undo again.

**Lines audited.** ~1,600

---

## Part 1 — Architectural breakdown

### Legacy per-tool settings: `MvSettingsBar`

`MvSettingsBar` opens when any tool is double-tapped in the `CanvasEngine` (legacy) path. The double-tap fires a `NavStackMessage("mvsettings", .toggle)` on `CodiChannel`; `CanvasEngine.onAppear` subscribes and flips `CanvasControl.mvSettingsWindowIsVisible`. The bar reads and writes one selected `ManagedView` through a `ManagedViewO` observable object. It adapts its content to tool family — circle/shape get dash and color, general tools get rotation, line tools get arrow-head toggle.

```swift
// MvSettingsToolBar.swift:168–179
if tool.isCircle {
    if let umv = self.BEO.realmInstance.findByField(ManagedView.self,
           value: self.BEO.toolBarCurrentViewId) {
        self.BEO.realmInstance.safeWrite { r in
            umv.width = Int(CGFloat(umv.width - 10).bounded(byMin: 50, andMax: 400))
        }
    }
} else {
    viewSize = (viewSize - 10).bounded(byMin: 50, andMax: 400)
    tool.width = Int(viewSize); tool.height = Int(viewSize)
    tool.saveToRealm()
}
```

Circle and non-circle resize travel two different code paths, leaving local `viewSize` out of sync with Realm for circle tools.

### Legacy board settings: `BoardSettingsBar`

Embedded inside `CanvasMenuView`'s "Board Settings" disclosure group — always mounted, not modal. Controls: canvas lock, delete-all, animation recording, undo, tool history, board picker (sheet), field rotation, line stroke, background color, and field line color. Writes `ActivityPlan` to Realm on each change. `loadFromRealm()` seeds from the live `BEO` state rather than re-reading Realm, which is correct — `BEO` is the in-memory source of truth for board presentation.

### Redesign Properties panel: `EnginePropertiesPanel`

The live panel in the redesign path. `BoardScreenState` routes `panel → .properties` whenever `selectedToolId != nil` and `libraryOpen == false`. `EnginePropertiesPanel` owns the engine binding: `loadFromTool()` maps `ManagedView` fields to local slider state, and `writeSize` / `writeRotation` / `pickColor` / `delete` / `duplicate` all write back to Realm directly. The `isLine` heuristic (`toolType == "shape" || toolType == "tactic"`) gates rotation visibility and clamps the size range.

```swift
// Panels.swift:350–358
size: Binding(get: { size }, set: { size = $0; writeSize($0) }),
rotation: Binding(get: { rotation }, set: { rotation = $0; writeRotation($0) }),
```

The `Binding`'s `set` calls `writeSize` / `writeRotation`. That would work — if the binding's setter were ever triggered.

### `SliderRow` — the broken link

`SliderRow` renders a custom capsule track + a `Circle` thumb offset by `w * value`. No `DragGesture` is attached anywhere in the view. The thumb positions itself correctly for the initial loaded value, but touching it does nothing.

```swift
// Panels.swift:461–473
GeometryReader { geo in
    let w = geo.size.width
    ZStack(alignment: .leading) {
        Capsule().fill(.white.opacity(0.1)).frame(height: 6)
        if !centered {
            Capsule().fill(Brand.lime).frame(width: w * value, height: 6)
        }
        Circle().fill(.white).frame(width: 16, height: 16)
            .shadow(color: .black.opacity(0.5), radius: 3, y: 2)
            .offset(x: w * value - 8)
    }
}
.frame(height: 16)
// — no .gesture(...) here or on any parent in SliderRow —
```

Because `writeSize` and `writeRotation` are only called via the binding setter, and the setter is never triggered, **neither size nor rotation can be changed from the Properties panel**.

### Control pill: `EngineControlPill`

Zoom %, lock, undo, zoom out/in, scope (reset), and record — all correctly wired to `BEO`. One control is mis-wired.

### Panel state machine: `BoardScreenState`

Clean. `library > properties > squad` priority. `select()` closes library; `toggleLibrary()` clears selection. Panel routing in `TacticalBoardView.rightPanel` exhaustively matches all three cases.

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | 10.x | Per-tool and per-board persistence; Realm-object observation | https://www.mongodb.com/docs/realm/sdk/swift/ |

---

## Part 2 — Honest assessment

### What's working

- **Panel routing is sound** — `BoardScreenState`'s priority logic (`library > properties > squad`) is correct; `select` / `clearSelection` / `toggleLibrary` transition cleanly without leaking state.
- **Color picking in `EnginePropertiesPanel`** — writes both `toolColor` (string key, for disc renderers) and RGBA components (for line/tactic renderers) in one atomic write; Realm observers (TASK-017) propagate the change without needing `refreshBoard`.
- **Duplicate and delete** — both work correctly, with soft-delete (`isDeleted = true`) and an offset copy at `+300,+300`.
- **BoardSettingsBar persistence** — writes the live `BEO` state to `ActivityPlan` rather than its stale local picker values; the comment at `saveToRealm()` makes this explicit.
- **Properties "close" wiring** — `onClose: { state.clearSelection() }` collapses back to Squad correctly.
- **`EngineSquadPanel.addPlayer()`** — correctly auto-increments jersey number and inserts a Realm object rather than being a no-op.
- **`isLine` family check** — correctly hides rotation and adjusts size range for shape/tactic tools; the `showRotation: !isLine` gate prevents a meaningless rotation slider on lines.

### Findings

```
▌ CRITICAL  ·  Panels.swift:461–474
  SliderRow has no DragGesture — the size and rotation sliders in
  EnginePropertiesPanel render correctly but respond to no touch input.
  writeSize() and writeRotation() are never called; tool size and rotation
  cannot be changed from the Properties panel in the live redesign path.
  └─ add a DragGesture to SliderRow that computes value = clamp(drag.x / geo.size.width, 0, 1)
     and writes through the binding on .onChanged

▌ HIGH      ·  Components.swift:325
  EngineControlPill wires onRedo to BEO.undoLastToolAction() — the
  forward-arrow button in the control pill does a second undo, not redo.
  └─ either wire to a real redo method when one exists, or relabel the
     button to clarify it's a placeholder (as noted in TASK-026 out-of-scope)

▌ HIGH      ·  Components.swift:150–159
  SportChip is hardcoded to "Soccer · Full" regardless of the active board
  or sport. The redesign's top bar always says the same thing.
  └─ derive from BEO.boardBgName (the registry board name) or the
     ActivityPlan's sport field; at minimum display the active board name
     from BEO.boardBgName

▌ MEDIUM    ·  MvSettingsToolBar.swift:103–110
  The "Duplicate" button passes systemName: "add" — not a valid SF Symbol
  (should be "square.on.square" or "plus"). The button renders no icon,
  so it's invisible to users. The title also has a typo ("Duplicatee").
  └─ change systemName to "square.on.square"; fix the typo

▌ MEDIUM    ·  MvSettingsToolBar.swift:408–413
  startRestartSession() is defined and contains the observeFromRealm()
  call, but it is never invoked from onAppear or any lifecycle hook.
  The Realm notification token is never started, so real-time Realm
  changes (from a collaborator or another code path) never reflect in
  the open settings bar until it's dismissed and re-opened.
  └─ call startRestartSession() from onAppear (or call observeFromRealm()
     directly); this is legacy-path only but still affects solo use

▌ LOW       ·  MVSettingsView_DEPRECATED.swift:1–395
  100% commented-out dead file (~395 lines). Still compiled by Xcode.
  └─ delete the file and remove from the project target

▌ LOW       ·  ToolBarSettings.swift:29–31
  ToolBarSettingsPicker has an empty ForEach body — it instantiates
  SoccerToolProvider.allCases then renders nothing. Dead view, never
  referenced outside this file.
  └─ delete or replace with a real implementation if still needed
```

### Tradeoffs worth naming

`SliderRow` is a custom-drawn slider rather than a SwiftUI `Slider` — the motivation is obvious (pixel-perfect match with the design's capsule + thumb shape). But the tradeoff is that you have to implement the gesture yourself, which didn't happen. A SwiftUI `Slider` with a custom style would get the gesture for free. The custom path is fine but it's all-or-nothing: draw it and wire it, or ship a broken control.

The two parallel settings surfaces (legacy `MvSettingsBar` + redesign `EnginePropertiesPanel`) coexist cleanly because they're in different entry points — `CanvasEngine` legacy vs `TacticalBoardView` redesign. The architectural boundary is sound. The cost is maintenance: both surfaces now accumulate bugs independently, and the legacy bar has the mis-wired observer (MEDIUM above) that the redesign path correctly avoids.

---

## Bottom line

Ship the `SliderRow` drag gesture today — it's a missing ~8-line implementation that makes the redesign's core "change tool size/rotation" flow actually work. Everything else in the Properties panel is correctly wired; only the interactive layer is absent. The redo mis-wire is the next most visible user-facing bug (two consecutive taps of the forward arrow does double-undo). The hardcoded sport chip is cosmetic but slightly embarrassing. The legacy `MvSettingsBar` issues (invisible duplicate button, dead observer) are lower priority since the redesign is the live path.

**Adjacent observations.** `CanvasMenuView` still drives `ToolList` with `ViewEngine.Tool.ShapeTool = [.circle, .square, .triangle]` (shape drawing) alongside `SoccerTool` / `PoolBallTool` / `GeneralTool` — this legacy tool picker is still the only place to add shapes to the board (not in Library's equipment tab). Worth noting when Library is next extended.
