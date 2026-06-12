**Target.** ViewEngine → Canvas → Board setup (CoreEngine ECViewEngine + app CanvasEngine/BoardEngine)
**Scope.** `CoreEngine/Sources/CoreEngine/ECViewEngine/` (full tree), `Ludi Boards/CanvasEngine/`, `Ludi Boards/BoardEngine/`, `Ludi Boards/LudiBoardsApp.swift`, package manifests
**Date.** 2026-06-11

---

## Update — 2026-06-12 — fixes applied (branch `audit/viewengine-canvas-board`)

Decisions taken with the user before editing: transform owner = **BEO**;
canonical board key = **currentActivityId**; Firebase = **fix paths, leave
push gated** (respects the free-mode gate); Realm pin + migration = **deferred**.

**Fixed**
- CRITICAL transform split — gestures now write `BEO`; removed `CanvasEngineControl`'s
  duplicate transform fields; zoom delta now reads/writes the same `BEO.lastScaleValue`.
- CRITICAL board identity — `MVEngineControl` filter + `BoardEngineView` line-save now
  use `currentActivityId`; removed the empty-roomId "show all tools" fallback.
- CRITICAL Firebase paths — per-object observer switched to the flat
  `managedViews/<viewId>` scheme (matches collection observer + updateFirebase);
  remote-delete now via `.value` non-existence instead of leaf `.childRemoved`.
  Push left commented (free-mode gate honored).
- HIGH property wrappers — `@ObservedObject = X()` → `@StateObject` at creation
  sites (BEO/UTO/DO/MVEngine); `@State var bounds` → plain var.
- HIGH basic-tool remote moves — start/end-zero guards now gated to `"shape"` tools.
- HIGH curve-center clobber — `updateRealm`/`updateRealmPos` take a `center:` param;
  center no longer derived from `start`.
- HIGH recording DispatchGroup — `enter()` now synchronous before scheduling, so
  Phase 2 waits for Phase 1; dead `currentDelay` removed.
- HIGH test pool balls — deleted.
- MEDIUM write funnel — removed unused `updateRealmPosition` (one fewer near-dup path).
- MEDIUM `animateToNextCoordinate` — guard fixed (`!isEmpty`, clear stack on drag);
  no more `removeFirst()` on empty.
- MEDIUM drop delegate — `as? String` guard; `@Binding/@State` → plain `let`;
  `dropDelegate` IUO + `[weak self]`; removed call-site force-unwrap.
- MEDIUM `BoardEngineById.swift` — deleted (zero refs).
- MEDIUM CanvasEngine dead code — ~400-line comment/experiment tail + in-body
  commented UI removed.
- MEDIUM subscription leak — `onAppear` listener wiring guarded (CanvasEngine +
  BoardEngineView).
- MEDIUM color defaults — board bg/field-line defaults normalized to 0–1.
- LOW infra `@Published` — dropped from tokens/handles/reference/cancellables in MVObject.
- LOW prints — removed the "YESSSS"/"ID!!!!!"/per-update position prints in scope.

**Deferred (need their own build-verified pass / collide with documented decisions)**
- HIGH Realm: `deleteRealmIfMigrationNeeded:true` + unpinned `master` — left alone
  per decision (collides with the v20-pin note); needs schemaVersion + migration block.
- LOW misspellings (`boardFeildLineStroke`, `boardFeildRotation`) — ripple across 10
  files; a rename pass of its own.
- LOW `SoccerToolProvider` — `@available(*, deprecated)` yet used by 5 live files;
  needs call-site migration to `ViewEngine` or a deliberate un-deprecation, not a move.
- MEDIUM `CanvasEngine`/`CoreCanvasControl` name shadowing — renaming touches CoreEngine
  public API; dead-code cleanup done, rename left for a public-API pass.
- HIGH deep reactivity — `@ObservedResults`/`@AppStorage` inside ObservableObjects:
  `@StateObject`+`bounds` done; fully migrating Realm results into Views (and removing
  the `resetTools` toggle workaround) is a cross-cutting refactor left for later.

**Build verification.** `xcodebuild` of the `Ludi Boards` scheme: **BUILD SUCCEEDED**,
0 errors, 0 new warnings in edited files. Getting there surfaced two project-level
issues outside the original Swift scope, both now fixed:
- `.pbxproj` had `Wrlds/BoardEngineView.swift` wrongly in the **Ludi Boards** target
  (duplicate `stringsdata`), present at HEAD before these edits — removed, plus the
  orphaned `BoardEngineById` entries left by the file deletion.
- `realm-cocoa` tracked `branch: master`, whose `realm-core` won't compile under
  Xcode 26.5 (`std::is_pod` specialization). Pinned to the **v20** line (20.0.4 →
  realm-core 20.1.4) per the documented Realm-pin decision. `deleteRealmIfMigrationNeeded`
  still untouched (deferred).

# Audit — ViewEngine → Canvas → Board

> **TL;DR.** The layered architecture (canvas → board → managed tools → factory) is a sound design mid-migration into CoreEngine, but right now the wiring is broken in three load-bearing places: canvas gestures mutate a state object the renderer never reads, "which board am I on" lives under three different AppStorage keys, and Firebase realtime sync is receive-only against two incompatible path schemes. The stack renders tools; it does not currently pan/zoom correctly or sync.

**Scope.** ~50 Swift files across CoreEngine ECViewEngine (CanvasEngine, TheNavStack, NavStack, ViewFactory, ECManagedViews, WindowViews), app-side CanvasEngine (7 files) and BoardEngine (4 files), app entry point, package manifests.
**Lines audited.** ~10,500 (≈2,600 read line-by-line, the rest mapped via subagent and spot-verified).

---

## Part 1 — Architectural breakdown

### Entry point and the canvas shell

The app boots straight into the canvas. `LudiBoardsApp.swift:27` instantiates `CanvasEngine()` — the **app's** `CanvasEngine` (`Ludi Boards/CanvasEngine/CanvasEngine.swift:50`), not CoreEngine's identically-named `public struct CanvasEngine` (`CoreEngine/Sources/CoreEngine/ECViewEngine/CanvasEngine/CanvasView.swift:13`). The local type shadows the imported one. The shell stacks two coordinate spaces:

```swift
// Ludi Boards/CanvasEngine/CanvasEngine.swift:149-163
GlobalPositioningZStack(coordinateSpace: CoreNameSpace.canvas.name, width: 20000, height: 20000) { cGps in
    if !CanvasControl.masterResetCanvas {
        BoardEngine()
            .environmentObject(self.BEO)
            .environmentObject(self.navTools)
    }
}
.offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
.scaleEffect(self.BEO.canvasScale)
.rotationEffect(Angle(degrees: self.BEO.canvasRotation))
```

This snippet is the heart of the biggest bug in the slice: the transform reads from `BEO` (`BoardEngineObject`), but the pan/zoom gestures a few lines down write to `CanvasControl` (`CanvasEngineControl`) — two unrelated objects (see Findings).

### State objects: three overlapping controllers

Canvas/board state is split across `CanvasEngineControl` (app, `CanvasEngine.swift:15-48`), `BoardEngineObject` (app, `BoardEngineObject.swift:15`, ~88 properties: user/session IDs, canvas transform, board colors, undo/redo, recording), and `CoreCanvasControl` (CoreEngine, unused blueprint). `BoardEngineObject` is the de-facto god object — it owns board appearance, tool history, recording capture/playback, and a copy of the canvas transform. Both app controllers carry `canvasScale`/`canvasOffset`/`canvasRotation`.

### BoardEngine: the render surface

`BoardEngine` (`BoardEngineView.swift:15`) renders the tool collection plus a drawing-preview overlay inside the 20k×20k canvas space:

```swift
// Ludi Boards/CanvasEngine/BoardEngineView.swift:35-40
MVEngine.Display(reset: self.$resetTools)

PoolBallManagedView(viewId: "test", activityId: self.BEO.currentActivityId, ballType: .eightBall)
PoolBallManagedView(viewId: "test1", activityId: self.BEO.currentActivityId, ballType: .solid1)
PoolBallManagedView(viewId: "test2", activityId: self.BEO.currentActivityId, ballType: .stripe9)
```

Three hardcoded test pool balls ship on every board. Tool lifecycle events arrive over `CodiChannel` broadcasts (`SESSION_ON_ID_CHANGE`, `TOOL_ON_CREATE`, `TOOL_ON_DELETE`), and creation toggles `resetTools` true→false to force a re-render — a workaround for the reactive gap described in Findings.

### ManagedViewEngine: Realm-driven tool collection

`ManagedViewEngine` (`CoreEngine/.../ECManagedViews/MVEngineControl.swift:27`) is the collection layer: it holds `@ObservedResults(ManagedView.self)`, filters by room, and fans each row out through the factory:

```swift
// CoreEngine/.../MVEngineControl.swift:44-58
@ObservedResults(ManagedView.self) public var allTools
public var boardManagedViews: Results<ManagedView> {
    if roomId.isEmpty { return allTools }
    return allTools.filter("boardId == %@", roomId)
}

@ViewBuilder
public func Display(reset: Binding<Bool> = .constant(false)) -> some View {
    if !reset.wrappedValue {
        ForEach(boardManagedViews) { item in
            if !item.isDeleted {
                ViewEngine.GenreBuilder(for: item.sport, in: item.toolType, as: item.subToolType, ...)
            }
        }
    }
}
```

Note the fallback: empty `roomId` ⇒ **all tools from every board render**. Also note `@ObservedResults` and `@AppStorage` live inside an `ObservableObject`, not a View — they don't drive SwiftUI invalidation from there.

### ManagedViewObject: per-tool state machine

Each rendered tool gets a `ManagedViewObject` (`CoreEngine/.../MVObject.swift:57`) via the `enableManagedViewTool` modifier (`ManagedToolView.swift`, `@StateObject MVO`). It's a ~33-`@Published`-property state machine that on init loads from Realm, observes Realm changes, listens for session switches, and attaches a Firebase observer (`MVObject.swift:147-158`). Remote moves are queued into a coordinate stack and replayed with animation — a genuinely nice idea for smooth multi-user playback (`MVObject.swift:309-341`).

Writes go two ways: `updateRealm()` on the main thread (`MVObject.swift:519`) and `updateRealmPosition()`/`updateRealmPos()` on a background queue with a fresh Realm (`MVObject.swift:560-607`). All `updateFirebase` call sites are commented out (`MVObject.swift:552, 573, 600`).

### ViewEngine factory: string → view routing

`ViewEngine` (`CoreEngine/.../ViewFactory/TheFactory.swift`) routes `(sport, toolType, subToolType)` strings into concrete views — shapes (lines, curves, circles, squares), ~91 general SF-symbol tools, 13 soccer tools, 15 pool balls. One place to look up every tool the app can draw; routing keys are raw strings end-to-end.

### Navigation: TheNavStack (active) vs NavStack (dead)

`NavWindowController` (`CoreEngine/.../TheNavStack/NavStackController.swift`) manages a view pool + back stack and renders `NavStackWindow` (split view on iPad, stack on iPhone), driven by `BroadcastTools` `.NavStackMessage` events. The older `NavStack/_NavStackObservable.swift` implementation has no references — dead. The app registers exactly two views into the pool: Home dashboard and SignUp (`CanvasEngine.swift:231-246`).

### Persistence and sync: Realm + Firebase RTDB

Realm is the source of truth (offline-first); Firebase RTDB is the intended realtime fan-out. The app boots with `deleteRealmIfMigrationNeeded: true` (`LudiBoardsApp.swift:20`). Two Firebase observer schemes coexist: per-object at `managedViews/<activityId>/<viewId>` (`MVObject.swift:627`) and collection-level at `managedViews` filtered by `boardId` (`MVEngineControl.swift:118-130`) — flat vs nested layouts (see Findings).

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` (realm-cocoa) | `branch: "master"` (resolved: realm-core 14.14.0) | Local persistence for ManagedView/actions/recordings, change notifications | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |
| `firebase-ios-sdk` (FirebaseDatabase, FirebaseAuth) | 10.29.0 (CoreEngine declares `from: "10.18.0"`) | RTDB realtime tool sync, auth gating of writes | https://firebase.google.com/docs/database/ios/start |
| `CoreEngine` (local SPM package) | local | Shared engine: ECViewEngine, broadcast bus, Realm helpers | — (this repo, `CoreEngine/`) |

Version note: the Realm dependency is **unpinned** (tracks master). Prior session memory says a Realm v20 pin matters and shouldn't be reverted — I don't know which state is authoritative on `main`; flagging rather than asserting.

---

## Part 2 — Honest assessment

### What's working

- **The layering is right** — screen-space chrome vs 20k×20k canvas space via `GlobalPositioningZStack`, board as a child of canvas, tools as factory-built children of board. That's the correct decomposition for this kind of app.
- **Offline-first shape is correct** — Realm as source of truth with Firebase as fan-out is the right architecture for collaborative boards on flaky networks; the bones are there even though the sync wiring is broken.
- **Coordinate-stack animation for remote moves** (`MVObject.swift:309-341`) — queuing remote positions and replaying them smoothly instead of teleporting tools is a genuinely good idea.
- **Undo/redo via `ManagedViewAction` absorb pattern** (`BoardEngineObject.swift:37-47`) — simple, append-only history; easy to reason about.
- **One factory for the whole tool catalogue** (`TheFactory.swift`) — 120+ tools routed in one place; adding a tool is a localized change.
- **The dead old NavStack actually is dead** — `NavStack/_NavStackObservable.swift` has zero references; the migration to TheNavStack completed cleanly on that axis.

### Findings

```
▌ CRITICAL  ·  Ludi Boards/CanvasEngine/CanvasEngine.swift:160
  pan/zoom gestures write CanvasControl.canvasOffset/Scale (lines 316,
  333) but the canvas renders BEO.canvasOffset/Scale/Rotation (lines
  160-162); nothing in the repo writes BEO's transform except NavPad
  helpers that are commented out — gestures cannot move the board.
  Zoom is doubly broken: delta divides by BEO.lastScaleValue (line
  332), which is never updated
  └─ pick ONE transform owner (BEO or CanvasControl), wire gestures
     and render to it, delete the other's transform fields

▌ CRITICAL  ·  CoreEngine/.../ECManagedViews/MVEngineControl.swift:46
  board identity lives under three AppStorage keys: currentActivityId
  (BEO + drop delegate), currentBoardId (BoardEngineView:21 + line
  save), currentRoomId (engine display filter). The filter falls back
  to ALL tools when currentRoomId is empty — every board's tools
  render on every board, and lines vs drops can tag different boardIds
  └─ one canonical key (registry-style), all three sites read it

▌ CRITICAL  ·  CoreEngine/.../ECManagedViews/MVObject.swift:627
  Firebase sync is internally inconsistent and push is disabled:
  per-object observer reads nested managedViews/<activityId>/<viewId>,
  collection observer + updateFirebase use flat managedViews/<id>
  (MVEngineControl:118, MVObject:676), and every updateFirebase call
  site is commented out (MVObject:552,573,600). Realtime collaboration
  is receive-only against a path nothing writes. Bonus: .childRemoved
  on a leaf node (line 630) fires on field removal, not node removal
  └─ pick one path scheme, re-enable push behind the auth gate, fix
     the childRemoved semantics

▌ HIGH      ·  Ludi Boards/LudiBoardsApp.swift:20
  deleteRealmIfMigrationNeeded: true in the production entry point —
  any schema change silently wipes every local board. This is the
  mechanism behind the known "branch-hop wipes device Realm data"
  └─ real migrations (schemaVersion + migration block) before release

▌ HIGH      ·  Ludi Boards/CanvasEngine/CanvasEngine.swift:57
  wrong property wrappers at the ownership boundary:
  @ObservedObject BEO = BoardEngineObject() and @ObservedObject
  MVEngine = ManagedViewEngine() (BoardEngineView:19) are re-created
  whenever the parent re-inits; and @ObservedResults/@AppStorage/
  @State live inside ObservableObjects (BoardEngineObject:17-20,
  MVEngineControl:31,41-44) where they don't trigger view updates —
  the TOOL_ON_CREATE reset-toggle hack (BoardEngineView:112-118)
  exists to paper over exactly this
  └─ @StateObject at creation sites; move Realm results/storage into
     Views or publish them properly

▌ HIGH      ·  CoreEngine/.../ECManagedViews/MVObject.swift:461
  remote position updates are dropped for basic tools: the observer
  guard returns if startX==0 && startY==0 — true for every dropped
  (non-line) tool, so other users' moves never apply
  └─ gate the guard by toolType (lines only)

▌ HIGH      ·  CoreEngine/.../ECManagedViews/MVObject.swift:531
  updateRealm clobbers the curve control point: centerX/centerY are
  assigned start?.x/start?.y (also updateRealmPos:592-593) — any call
  passing start corrupts curved-line geometry; the signature has no
  center parameter at all
  └─ add a center param or stop writing center from start

▌ HIGH      ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:340
  recording playback DispatchGroup misuse: notify() is registered
  immediately, but enter() happens inside asyncAfter(0.5) — group is
  empty at registration, so the action loop starts before initial
  state is applied; currentDelay (lines 338,352) is computed and
  never used
  └─ enter() synchronously before scheduling, or rewrite with
     async/await

▌ HIGH      ·  CoreEngine/Package.swift
  realm-cocoa tracks branch: "master" — unpinned, non-reproducible
  builds; conflicts with the prior decision to pin Realm (session
  memory says v20 pin, resolved file says realm-core 14.14.0 — I
  don't know which is authoritative on main)
  └─ pin to an exact version, reconcile with the v20 decision

▌ HIGH      ·  Ludi Boards/CanvasEngine/BoardEngineView.swift:37
  three hardcoded test pool balls (viewId "test"/"test1"/"test2")
  render on every board in the shipping view
  └─ delete

▌ MEDIUM    ·  CoreEngine/.../ECManagedViews/MVObject.swift:519
  dual write paths to the same ManagedView: main-thread safeWrite
  (updateRealm) vs background try Realm() writes (updateRealmPosition/
  updateRealmPos) — transactionally safe but last-write-wins ordering
  risk, and three near-identical write methods to drift apart
  └─ single write funnel

▌ MEDIUM    ·  CoreEngine/.../ECManagedViews/MVObject.swift:312
  animateToNextCoordinate guard is inverted: `!stack.isEmpty ||
  isDragging` proceeds when dragging with an empty stack →
  removeFirst() on empty array (crash); the Basic variant (line 293)
  does it correctly
  └─ `!stack.isEmpty && !isDragging`, clear stack on drag like Basic

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:500
  CustomDropDelegate force-casts droppedString as! String — a failed
  text drop crashes; BEO.dropDelegate! force-unwrap at
  BoardEngineView:65; @State/@Binding wrappers used in a non-View
  DropDelegate struct (undefined behavior territory)
  └─ guard-let the cast, drop the wrappers

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineById.swift:15
  dead code: zero references anywhere, duplicates BoardEngine with 25
  copied @State vars, file header says "BoardEngineView.swift"
  └─ delete

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/CanvasEngine.swift:109
  ~400 lines of commented-out UI and a grab-bag of unrelated
  draggable-modifier experiments (lines 382-723) living in the main
  canvas file; CoreEngine's CanvasView.swift body is likewise mostly
  empty blueprint that shares the public name CanvasEngine with the
  app's type — a shadowing footgun during the migration
  └─ delete or move to a scratch file; rename one of the two types

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineView.swift:84
  CodiChannel subscriptions added on every onAppear with no teardown
  — cancellables accumulate duplicate listeners across appearances
  └─ subscribe once (task/onFirstAppear) or clear on disappear

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:135
  board color defaults are 0-255 component values (48/128/20) fed to
  Color(red:green:blue:), which expects 0-1 — I think the default
  board background renders clamped near-white, not the intended green
  └─ store 0-1 components

▌ LOW       ·  CoreEngine/.../ECManagedViews/MVObject.swift:124
  @Published wraps NotificationTokens, DatabaseReference, handles and
  two cancellable sets (`cancellables` and `cancel`) — pointless
  objectWillChange churn on infra fields
  └─ plain vars

▌ LOW       ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:144
  public API misspellings (boardFeildLineStroke, boardFeildRotation,
  nofityToken) and debug noise ("YESSSS!!!" CanvasEngine.swift:172,
  "ID!!!!!" prints) across the slice
  └─ rename + strip prints before release

▌ LOW       ·  CoreEngine/.../ViewFactory/deprecated/
  SoccerToolProvider lives in deprecated/ but is referenced from 5
  live files (EVProtocols.swift:203, MVToolBar.swift:141, three
  window views) — the deprecation is aspirational
  └─ either graduate it out of deprecated/ or finish the removal
```

### Tradeoffs worth naming

The Realm + Firebase RTDB pairing buys offline-first behavior and cheap realtime fan-out at the cost of pushing all consistency responsibility into app code — and the three board-ID keys and two RTDB path schemes are exactly what it looks like when that responsibility gets dropped mid-refactor. The CoreEngine extraction ("generic → CoreEngine" graduation rule) is the right long-term move, but doing it incrementally means the app currently pays for both copies: duplicate `CanvasEngine` types, duplicate `CanvasMenuView`s, duplicate nav controllers. The per-tool `ManagedViewObject` with 33 published properties trades memory/update overhead for very simple tool views — defensible at this tool count, but it makes every rendered tool carry its own Firebase observer and Realm token, which will hurt on large boards.

---

## Bottom line

If this were mine I would freeze feature work on this slice and spend one focused batch on convergence, in this order: (1) pick the single owner of the canvas transform and make gestures + render agree — the app's core interaction is broken until then; (2) collapse `currentActivityId`/`currentBoardId`/`currentRoomId` into one key and remove the show-everything fallback; (3) decide the Firebase path scheme and re-enable push, or delete the observers and call the app single-user for now — receive-only sync against a dead path is worse than either choice; (4) delete the dead weight (BoardEngineById, test pool balls, commented blocks, old NavStack) so the next session sees one implementation per concept. The architecture doesn't need a rewrite — it needs the migration it's already in to be finished in one direction.

**Adjacent observations.** `Wrlds/CanvasEngine.swift` is a third near-copy of the canvas shell (dual-board + audio experiment) — fine as a sandbox, but it will drift; and `deleteRealmIfMigrationNeeded` interacts badly with the unpinned Realm master branch (a dependency bump alone can change schema handling under you).
