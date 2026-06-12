**Target.** Ludi Boards Canvas/Board tactical-board engine — the live rendering path the app boots.
**Scope.** `Ludi Boards/CanvasEngine/*`, `Ludi Boards/ManagedViews/*`, app entry, plus the CoreEngine types the live path binds to (`ManagedViewEngine`, `ViewEngine` builder, `ManagedView` model).
**Date.** 2026-06-11

---

# Audit — Ludi Boards Canvas/Board engine

> **TL;DR.** The data-driven tool engine underneath is genuinely good and worth keeping — but the board is not shippable today because it's frozen mid-refactor: the entire toolbar/menu layer is commented out, canvas pan/zoom is bound to a state object the view never reads, three test pool balls are hardcoded into every board, and the render filter keys off a different ID than tool creation. These are "finish the wiring" bugs, not design rot.

**Scope.** `CanvasEngine.swift`, `BoardEngineView.swift`, `BoardEngineObject.swift`, `BoardEngineById.swift`, `CanvasMenuView.swift`, `CanvasExtensions.swift`, `Gestures/TwoFingerPanView.swift`, `CanvasEngineVM.swift`, `ManagedViews/ManagedViewBoardTool.swift`, `ManagedViews/ManagedPopUpView.swift`, `ManagedViews/modifiers/lineModifier.swift`; CoreEngine `MVEngineControl.swift`, `MVEngineBuilder.swift`, `ECRealm/Models/ManagedView.swift`.
**Lines audited.** ~2,600 read in full, plus a mapped pass over MVObject / FusedTools / CodiChannel / Sports / RealmCore.

---

## Part 1 — Architectural breakdown

### App entry → CanvasEngine root

The app boots straight into the board. `LudiBoardsApp` configures Realm + Firebase and renders `CanvasEngine()` as the only scene. `CanvasEngine` is the root: it owns a `CanvasEngineControl` (canvas pan/zoom/rotation state), a `BoardEngineObject` (BEO — the board's central state), a `NavWindowController`, and orientation/user observables.

```swift
// Ludi Boards/LudiBoardsApp.swift:25
var body: some Scene { WindowGroup { CanvasEngine() } }
```

The root's job is canvas-level gestures (pan/zoom/rotate) wrapping the board. Everything above the board — menus, toolbar, settings, nav — is present in source but commented out (see Findings).

### Board layer — BoardEngine + BoardEngineObject

`BoardEngine` (in `BoardEngineView.swift`) is the live board view. It renders the field background, the managed-view tools via `MVEngine.Display(...)`, and a temporary draw-line overlay. `BoardEngineObject` is the single fat state object: board geometry, colors, the drop delegate, undo/history index, and the full record/playback animation engine.

```swift
// Ludi Boards/CanvasEngine/BoardEngineView.swift:35
MVEngine.Display(reset: self.$resetTools)
```

The board is a pure projection of Realm — it renders whatever `ManagedView` rows exist for the current board. That's the right shape: one source of truth, everything (undo, record, sync) hangs off it.

### Tool engine — ManagedViewEngine + ViewEngine builder

`ManagedViewEngine` (CoreEngine) holds `@ObservedResults(ManagedView.self)` and exposes `Display(reset:)`, which `ForEach`es the board's tools and hands each to a string-keyed builder. The builder switch is the extensibility seam: add a tool family = add an enum case.

```swift
// CoreEngine/.../MVEngineControl.swift:53
ForEach(boardManagedViews) { item in
    if !item.isDeleted {
        ViewEngine.GenreBuilder(for: item.sport, in: item.toolType,
                                as: item.subToolType, viewId: item.id,
                                activityId: item.boardId, bounds: self.bounds)
    }
}
```

`ViewEngine.ToolBuilder` (MVEngineBuilder.swift) routes `toolType` → `{general, shape, soccer, pool}` and `subToolType` → the concrete view (`LineDrawingManaged`, `ManagedViewTool`, etc.). Tool catalogs are typed enums (`ShapeTool`, `SoccerTool`, `PoolBallTool`, `GeneralTool`) — clean and self-describing.

### Data model — ManagedView (Realm)

`ManagedView` (CoreEngine `ECRealm/Models/ManagedView.swift`) is the persisted tool: position (`x/y`, line `startX/Y…endX/Y`), `width/height/rotation/lineDash`, RGBA color, `boardId`, `sport/toolType/subToolType`, and soft-delete (`isDeleted`). `ManagedViewAction` mirrors it for history; `RecordingAction` mirrors it for playback. `absorbAction`/`absorb` copy fields between them.

```swift
// CoreEngine/.../ECRealm/Models/ManagedView.swift:22
@Persisted public var boardId: String = ""
@Persisted public var sport: String = "tool"
@Persisted public var toolType: String = "shape"
@Persisted public var subToolType: String = "square"
```

Soft-delete + action-mirroring is the foundation for undo and (later) real-time sync. Good call.

### Tool editing — CodiChannel pub/sub

Per-tool settings (rotation, size, color, stroke, delete, lock) flow through `CodiChannel.TOOL_ATTRIBUTES` — a Combine `PassthroughSubject` bus. The popup (`PopupMenuView`, confusingly in `ManagedPopUpView.swift`) listens and writes back to Realm. Tools and the settings UI never reference each other directly.

```swift
// Ludi Boards/ManagedViews/ManagedPopUpView.swift:312
let va = ViewAtts(viewId: viewId, rotation: viewRotation)
CodiChannel.TOOL_ATTRIBUTES.send(value: va)
```

Decoupled and extensible — but stringly-typed with `as!` force-casts (see Tradeoffs).

### Persistence / Firebase split

Writes go through `FusedTools.fusedCreator` → Realm, then `saveToFirebase` *guarded* by `UserTools.userIsVerifiedForFirebaseRequest()`. The engine's Firebase observers guard on `isLoggedIn` + `roomId`. The drop delegate's Firebase write is commented out. **Net: a free, local-only (Realm-only) build is already the default path** — Firebase is an optional overlay, not a dependency of basic board rendering. This directly matches the "ship free first, add Firebase later" goal.

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | realm-core 14.14.0 (realm-cocoa pinned to revision `19b98b381c`) | Local persistence of `ManagedView`/`ManagedViewAction`/`ActivityPlan`/`Recording`; `@ObservedResults` reactive board | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |
| `FirebaseDatabase` (firebase-ios-sdk) | 10.29.0 | Optional realtime sync of tools (gated off for free build) | https://firebase.google.com/docs/database/ios/start |
| `Combine` | SDK | `CodiChannel` event bus, `@Published` state | https://developer.apple.com/documentation/combine |
| `SwiftUI` | SDK | Entire view/gesture layer | https://developer.apple.com/documentation/swiftui |
| `CoreEngine` | local (this repo) | Tool engine, builder, model, GPS/window system, channels | — internal — |

---

## Part 2 — Honest assessment

### What's working

- **The tool-render pipeline is the right architecture** — `ManagedView` (Realm) → `@ObservedResults` → `ManagedViewEngine.Display` → `ViewEngine.ToolBuilder` is clean and data-driven. Adding a tool type is a one-line enum case ([MVEngineBuilder.swift:124](CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift:124)). This is the part to be proud of.
- **Board is a pure projection of the DB** — the view renders Realm state and drag writes back to Realm. One source of truth, which is why undo/history/record can all hang off the same tables.
- **Firebase is genuinely optional at the data layer** — every Firebase write/observe is guarded by login/verification ([FusedTools.saveToFirebase], [MVEngineControl.swift:113](CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineControl.swift:113)). The free build needs no surgery here, just to keep users logged-out.
- **Soft-delete everywhere** (`isDeleted`) — right call for undo and future sync; no destructive hard deletes in the tool path.
- **Tool-settings decoupling via `CodiChannel`** — rotation/size/color/stroke/delete/lock all flow as messages, so the palette and the tool views stay independent.

### Findings

```
▌ CRITICAL  ·  Ludi Boards/CanvasEngine/CanvasEngine.swift:160
  Canvas pan/zoom/rotate is bound to the wrong object. The board reads
  .offset(BEO.canvasOffset) .scaleEffect(BEO.canvasScale)
  .rotationEffect(BEO.canvasRotation) (lines 160-162), but the drag/
  magnify gestures mutate CanvasControl.canvasOffset / .canvasScale
  (lines 316, 333) — a DIFFERENT ObservableObject that is never synced
  back to BEO. Defaults happen to match (offset 6000,6000; scale 0.1)
  so the board renders, frozen: it cannot be panned, zoomed, or rotated.
  └─ point the gestures and the transform at the SAME object (collapse
     CanvasEngineControl's canvas* fields into BEO, or read CanvasControl
     in the transform)

▌ CRITICAL  ·  Ludi Boards/CanvasEngine/CanvasEngine.swift:109
  The entire chrome layer is commented out. The "Screen" overlay block
  (lines 109-146) — CanvasMenuView (toolbar), MvSettingsBar, MenuBarStatic,
  navTools.getNavStackView(), tool picker — is all dead-commented. The
  live build shows ONLY field + tools + canvas gestures. There is no
  on-screen way to add a tool, draw a line, open settings, or navigate.
  This is the #1 release blocker.
  └─ re-enable a single minimal toolbar that (a) drops tools and
     (b) toggles draw mode; defer the rest

▌ HIGH      ·  CoreEngine/.../MVEngineControl.swift:45
  Render filter and create path disagree on the board ID. boardManagedViews
  filters by @AppStorage("currentRoomId") — empty => returns ALL tools from
  ALL boards (no isolation). But tools are created with boardId =
  currentActivityId (BoardEngineObject.swift:501) and lines with
  currentBoardId. So either every board shows every tool, or (if roomId is
  ever set != activityId) the board renders empty. Three overlapping IDs:
  currentRoomId / currentActivityId / currentBoardId.
  └─ unify on currentActivityId for both create and the engine filter

▌ HIGH      ·  Ludi Boards/CanvasEngine/BoardEngineView.swift:37
  Test scaffolding ships in the live board. Three hardcoded
  PoolBallManagedView(viewId: "test"/"test1"/"test2") render on EVERY
  board, every launch.
  └─ delete lines 37-40

▌ HIGH      ·  Ludi Boards/LudiBoardsApp.swift:20
  Realm set to deleteRealmIfMigrationNeeded: true. For a free, local-only
  release (no Firebase backup), any future app update that changes a
  @Persisted field silently DELETES every saved board, tool, activity, and
  recording the user made. User-facing data loss on update.
  └─ add a real migration block (or schemaVersion bump) before any release
     users are expected to keep data in

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:499
  Drop-created tools set only toolType, not subToolType or sport. Since
  ToolBuilder routes on toolType->family and subToolType->concrete view,
  a dropped tool with default sport "tool"/subToolType "square" likely
  routes to default: EmptyText() unless the drag payload is exactly a
  family name. (Medium confidence — did not trace the palette's drag
  payload string; the palette is commented out.)
  └─ verify the drag payload, set sport/toolType/subToolType explicitly
     on drop

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineById.swift:15
  BoardEngineById is a ~150-line near-duplicate of BoardEngine, referenced
  nowhere (dead). It uses local @State instead of BEO, so it will drift
  from the live view.
  └─ delete it, or make ONE board view the single source

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/CanvasEngine.swift:353
  Draw mode is unreachable. isDraw is only flipped by enableDrawing/
  toggleDrawingMode (353-375), which are called only from the commented-out
  toolbar. The draw gesture + saveLineData in BoardEngineView exist but
  can't be triggered.
  └─ wire a draw toggle into the re-enabled toolbar

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/CanvasEngine.swift:302
  gesturesAreLocked is never honored. Every `if gesturesAreLocked { return }`
  guard in the canvas drag/scale gestures is commented out (302, 319, 323,
  331, 337). Drawing mode sets the lock to stop canvas panning — but the
  canvas keeps panning, so once draw mode is re-enabled it will fight the
  draw gesture.
  └─ restore the lock guards (and have draw mode set it)

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/CanvasEngine.swift:24
  Canvas state is duplicated on two objects. canvasWidth/Height/Offset/
  Scale/Rotation/lastScaleValue exist on BOTH CanvasEngineControl (24-40)
  and BoardEngineObject (103-109). This duplication is the root cause of
  the CRITICAL pan/zoom bug.
  └─ pick one owner for canvas transform state

▌ LOW       ·  Ludi Boards/ManagedViews/ManagedViewBoardTool.swift:26
  Dead + would-not-compile: ManagedViewBoardTool is referenced nowhere and
  calls .enableMVT(...), which is defined NOWHERE in the repo. If this file
  is in the build target it won't compile; if it compiles, the file is
  excluded — either way it's dead.
  └─ delete the file

▌ LOW       ·  Ludi Boards/CanvasEngine/Gestures/TwoFingerPanView.swift:12
  Dead files cluttering the engine: TwoFingerPanView.swift (fully
  commented), modifiers/lineModifier.swift (fully commented),
  CanvasEngineVM.swift (empty), ToolObservers/ManagedViewManager.swift +
  ToolHistoryObserver.swift (commented).
  └─ delete

▌ LOW       ·  Ludi Boards/ManagedViews/ManagedPopUpView.swift:41
  Filename/type mismatches slow navigation: ManagedPopUpView.swift defines
  PopupMenuView (header says "MvPopup.swift"); BoardEngineById.swift header
  says "BoardEngineView.swift".
  └─ rename files to match their primary type

▌ LOW       ·  CoreEngine/.../ECRealm/Models/ManagedView.swift:19
  Three-way model drift (expected, per migration). ManagedView is defined
  canonically in CoreEngine (public, @Persisted) AND again in
  Wrlds/Realm/models/ManagedView.swift (@objcMembers, legacy style). Ludi
  Boards uses the CoreEngine copy; the Wrlds one is a separate target's
  straggler.
  └─ graduation-rule cleanup once Wrlds migrates onto CoreEngine
```

### Tradeoffs worth naming

- **Huge-canvas-at-0.1-scale** (20000×20000 space, scale 0.1, offset 6000,6000) buys an effectively-infinite pan/zoom surface with simple absolute coordinates, but the magic numbers leak everywhere — the settings popup compensates with `.scaleEffect(6.0)`, a 2000×3000 frame, and `position.y + 1000` ([ManagedPopUpView.swift:131-137](Ludi Boards/ManagedViews/ManagedPopUpView.swift:131)). Fragile to retune.
- **Realm-as-truth, Firebase-as-overlay** is exactly right for a free→paid split. The cost: "offline mode" isn't a single switch — it's a dozen scattered `isLoggedIn` / `userIsVerified` guards. For the free release that's fine; before the paid tier, centralize it.
- **CodiChannel pub/sub** decouples the UI nicely but is untyped (`Any` payloads, `as! ViewAtts` force-casts). Flexible now, crash-prone as channels multiply. Worth a typed wrapper before it grows.
- **One fat BoardEngineObject** (530 lines: geometry + colors + drop + undo + record/playback) is easy to reach from any subview but is the thing most likely to become unmaintainable. Don't split it for the free release; do flag it.

---

## Bottom line

Keep the engine — it's the good part, and it's the part that's hard to get right. The board isn't shippable today, but not because the design is wrong: it's stalled mid-refactor (canvas state was being moved BEO → CanvasEngineControl, the chrome was being rebuilt, and neither got finished). The fast path to a free tactical board, in order: **(1)** re-enable one minimal toolbar that drops a tool and toggles line-draw; **(2)** make the canvas gestures and the board transform read the *same* object so pan/zoom works; **(3)** unify on `currentActivityId` for both tool creation and the engine's render filter; **(4)** delete the three hardcoded test balls; **(5)** replace `deleteRealmIfMigrationNeeded` with a real migration so updates don't wipe users' boards. That's days of focused wiring, not a rewrite. Everything below the chrome — tools, model, persistence, the Firebase-optional split — is ready.

**Adjacent observations.** The undo/history and record/playback systems in `BoardEngineObject` are substantial and mostly built, but currently unreachable from the (commented-out) UI — worth knowing they're *not* greenfield when you get to them. And the `Sports`/board-background registry ([Ludi Boards/Providers/Sports.swift](Ludi Boards/Providers/Sports.swift)) is the seam for "what fields exist" — relevant when you decide which sports the free version ships with.
