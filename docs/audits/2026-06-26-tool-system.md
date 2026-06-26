**Target.** The tactical-board tool system — model, catalog/routing, render dispatchers, authoring, selection/Properties wiring.
**Scope.** `ManagedView.swift`, `RosterPlayer.swift`, `MVEngineBuilder.swift`, `MVEngineControl.swift`, `MVObject.swift`, `ManagedToolView.swift`, `SoccerPlayerToolView.swift`, `SmartTools.swift`, `Lines/{LineToolView,CurvedLineToolView}.swift`, `BoardEngineObject.swift`, `BoardEngineView.swift`, `Panels.swift`, `TacticalBoardView.swift`, `RedesignPreviewEntry.swift`, `ColorProvider.swift`, `LudiBoardsApp.swift`, `Wrlds/Realm/models/ManagedView.swift`.
**Date.** 2026-06-26
**Method.** 7 parallel subsystem finders + an adversarial verify pass (49 agents); 42 raw findings → 39 confirmed, 3 dropped. One HIGH re-verified by hand.

---

# Audit — tactical-board tool system

> **TL;DR.** The render pipeline is clean and genuinely extensible — adding a tool family is a one-line route. But the *editing* layer the redesign bolted on top is half-wired: smart tools can't be selected at all, the Properties panel silently mis-edits every non-token tool, the roster feature is dead outside DEBUG, and the four tool-creation paths disagree on defaults and even on whether they sync to Firebase. None of it is data-loss; most of it is "the new tools look right but don't respond right."

**Lines audited.** ~4,700 across 18 files.

---

## Part 1 — Architectural breakdown

### Model — `ManagedView` as the universal tool row

Every tool is one `ManagedView` Realm row: geometry (`x/y`, `startX/Y…endX/Y`, `centerX/Y`, `width/height/rotation`), routing (`sport/toolType/subToolType`), RGBA + `toolColor` name, soft-delete, and the RD-5 roster link (`playerId/jerseyNumber/teamSide`). `ManagedViewAction` mirrors it for history.

```swift
// ManagedView.swift:56 — denormalised roster link
@Persisted public var playerId: String = ""
@Persisted public var jerseyNumber: Int = 0
@Persisted public var teamSide: String = ""
```

One flat row for 30+ tool types is the right call — it's why undo/history/sync hang off one table. The cost: every renderer reaches into the same fields and *interprets* them differently (a line's `width` is a stroke; a disc's is a diameter), which is the root of most Part-2 findings.

### Catalog & routing — the extensibility seam

`ToolCategory` enums (`ShapeTool`/`SoccerTool`/`PoolBallTool`/`GeneralTool`/`SmartTool`) are the catalog. The **live** render path is the string router:

```swift
// MVEngineBuilder.swift:96 — ToolBuilder (the path MVEngine.Display actually uses)
case "shape":  ShapeTool.Build(name: subtype, …)
case "soccer": SoccerTool.Build(name: subtype, …)
case "tactic": SmartTool.Build(name: subtype, …)
default:       EmptyText()
```

Adding a family is one enum + one `case`. Clean. There is also a **second, enum-based** `buildToolView`/`GenreBuilder(for: Genre)` path that is dead and incomplete (see Findings).

### Render dispatchers — four families, four mechanisms

- **Tokens** (`SoccerPlayerToolView`, equipment images) → `ManagedViewTool` + `enableManagedViewTool` (position/frame/rotation, the lime selection ring, drag).
- **Lines** (`LineDrawingManaged`, `CurvedLineDrawingManaged`) → own anchor/drag/delete, render a `Path`.
- **Smart/tactical** (`SmartToolManaged`) → one dispatcher reads `start/center/end` from the row and switches on `subToolType`, board-scaling decorations off stroke width `w`.

`ManagedViewObject` (MVO) is the per-tool state object that loads/observes the row. Each family wires its own subset of MVO's gestures and persistence — there is no shared base, so selection, scaling, and drag-persistence are re-implemented (inconsistently) per family.

### Authoring — four create paths

`CustomDropDelegate.performDrop` (drag), `EngineLibraryPanel.addTool`/`addSmartTool` (tap), `BoardEngineView.saveLineData` (draw), plus DEBUG seeds. Each builds a `ManagedView` independently.

### Selection / Properties — the redesign bridge

Selection is a single global `@AppStorage("selectedManagedViewId")` reflected into `BoardScreenState` (`RedesignPreviewEntry.swift`), which opens `EnginePropertiesPanel`. The panel reads/writes `width/rotation/toolColor` back to the row.

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | realm-core 20.1.4 | Tool persistence (`ManagedView`/`RosterPlayer`/history), `@ObservedResults` reactive board | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |
| `FirebaseDatabase` | 10.29.0 | Optional tool sync — **only** the draw path routes through it (`FusedTools.fusedCreator`) | https://firebase.google.com/docs/database/ios/start |
| `SwiftUI` / `Combine` | SDK | Views, gestures, `CodiChannel` event bus, `@AppStorage` selection | https://developer.apple.com/documentation/swiftui |

---

## Part 2 — Honest assessment

### What's working

- **The string render pipeline is genuinely extensible** — `ManagedView` → `MVEngine.Display` → `GenreBuilder` → `ToolBuilder` → concrete view. Smart Tools proved it: a new family was one enum + one `case` (`MVEngineBuilder.swift:99`).
- **One flat row as source of truth** — undo/history/record all hang off `ManagedView`/`ManagedViewAction`; soft-delete everywhere, no hard deletes in the tool path.
- **The smart-tool dispatcher is a tidy pattern** — one `SmartToolManaged` reads geometry and switches on subtype, instead of 13 managed wrappers (`SmartTools.swift:199`).
- **Board-as-projection** — the board renders whatever rows exist for the activity; create paths just write rows. Right shape.

### Findings

```
▌ HIGH    ·  SmartTools.swift:203
  Smart (tactic) tools can never be SELECTED. The double-tap calls
  MVO.toggleMenuWindow() without first setting anchorsAreVisible — and
  toggleMenuWindow() only writes selectedManagedViewId when anchorsAreVisible
  is already true (MVObject.swift:181), else it CLEARS it. So tactic tools'
  Properties panel never opens and their selection state never sets.
  └─ flip MVO.anchorsAreVisible before toggleMenuWindow (as the line tools do),
     or give the redesign a dedicated single-tap selection setter

▌ HIGH    ·  Panels.swift:104
  The roster feature is dead outside DEBUG. The Squad "Add player" button is a
  bare FooterButton with no Button/action (contrast Duplicate/Delete at :277),
  and the only RosterPlayer-creation code is seedRosterIfNeeded, which is
  #if DEBUG + gated on REDESIGN_SEED=1. In release: empty squad, place() never
  reached, no playerId links ever formed.
  └─ wire the Add-player button to create a RosterPlayer, or move seeding out
     of #if DEBUG

▌ HIGH    ·  Panels.swift:350-365
  The Properties panel is NOT tool-family-aware and silently mis-edits every
  non-token tool: SIZE rewrites mv.width — which for lines/smart tools is the
  STROKE width, not a size (and also writes the unused mv.height); ROTATION
  no-ops on lines/shapes (they recompute rotation from geometry and ignore
  mv.rotation); TEAM COLOUR writes the NAME field toolColor, but lines/smart
  render from RGBA, so the colour visibly doesn't change.
  └─ branch Properties by tool family (token vs line vs smart); for line/smart
     expose a stroke control + write colorRed/Green/Blue (not just toolColor)

▌ HIGH    ·  SoccerPlayerToolView.swift:42-63  +  BoardEngineObject.swift:359
  Changing a disc's colour in Properties does nothing visible — two reasons.
  (1) SoccerPlayerToolView reads colour ONCE in onAppear and never observes the
  row. (2) The intended escape hatch, BEO.refreshBoard(), is a no-op: it toggles
  a flag no view reads, so it never forces a re-render.
  └─ have tool views observe Realm (or key on a colour value via .id), and
     either make the board subtree depend on the refresh flag or delete it

▌ HIGH    ·  BoardEngineView.swift:286  (+ BoardEngineObject.swift:606)
  The four create paths disagree on persistence. The DRAW path writes through
  FusedTools.fusedCreator (Firebase-synced, default newRealm()); drag/tap/seed
  write directly to BEO.realmInstance with no Firebase push. So drawn lines sync
  and everything else doesn't — the create paths are not interchangeable.
  └─ pick ONE persistence helper for all create paths

▌ HIGH    ·  SmartTools.swift:320
  Smart-tool drag never sets MVO.isDragging, so a Realm observation firing
  mid-drag (the tool reloads its persisted start/end) fights the in-flight drag
  and makes the tool jump. The line tools guard this with isDragging/ignoreUpdates.
  └─ set MVO.isDragging=true on drag start, false in onEnded before persist()

▌ MEDIUM  ·  ManagedToolView.swift:117  +  SmartTools.swift:199
  Selection feedback is inconsistent across families. The lime ring lives only
  in enableManagedViewTool (tokens). Lines, curved lines and smart tools get no
  ring — smart tools show only anchor dots, and single-point smart tools
  (offside/spotlight/focus/ladder/badge) give NO visible selection feedback.
  └─ factor the lime ring into a shared modifier keyed on selectedManagedViewId

▌ MEDIUM  ·  Panels.swift:116  +  ManagedView.swift:56
  The denormalised roster link has no write-back. place() copies number/team/
  playerId once; the disc renders from mv.jerseyNumber while Properties reads
  name live from RosterPlayer — two sources of truth that diverge if a player's
  number changes. Latent today (no roster-edit UI), live the moment one lands.
  └─ pick one authority: resolve via playerId at render, or sync on roster edit

▌ MEDIUM  ·  MVEngineBuilder.swift:85
  Dead + incomplete route. The enum buildToolView(_:)/GenreBuilder(for: Genre)
  path only handles .soccer/.pool → EmptyText for everything else, and the Tool
  enum it switches on has no smart/tactic case. The live path is the string
  router; this one is never exercised and would mis-render if it were.
  └─ delete the enum buildToolView/Genre trio, or complete + adopt it

▌ MEDIUM  ·  BoardEngineObject.swift:609  +  Panels.swift:560  +  BoardEngineView
  Create-path defaults are triplicated and already drifted. Smart-tool default
  geometry/colour appears in performDrop, addSmartTool and the seed; equipment
  TAP sets width/height=200 while equipment DROP leaves the model default 100,
  so the same cone is a different size depending on how you add it.
  └─ extract one factory (ManagedView.makeSmartTool / makeEquipment) all paths call

▌ MEDIUM  ·  SmartTools.swift:206
  subType and jersey are read once in onAppear and never observed; a remote/
  local change to subToolType or jerseyNumber doesn't re-render the tool.
  └─ promote them to MVO @Published synced in observeFromRealm

▌ MEDIUM  ·  SmartTools.swift:228
  Curve-arrow control point can't be edited: only start/end anchors render and
  persist; center is never recomputed, so the curve's bend is frozen at its
  default offset.
  └─ add a third anchor for the control point (3-point tools)

▌ MEDIUM  ·  SmartTools.swift:202
  Gesture priority is fragile: whole-tool move is highPriorityGesture while
  anchors are plain .gesture — anchor drags can be swallowed by the move
  depending on hit-test order.
  └─ make anchors highPriorityGesture; move lower-priority/simultaneous

▌ MEDIUM  ·  MVObject.swift:180
  Selection is a DOUBLE-tap toggle with legacy mvSettings side effects: no
  single-tap select, and double-tapping a selected tool deselects it. Brittle as
  the redesign's primary selection gesture.
  └─ add an idempotent single-tap selection setter for the redesign

▌ MEDIUM  ·  Panels.swift:334
  Rotation round-trip mishandles negative angles: a negative mv.rotation yields
  a negative slider value, pushing the knob off the track.
  └─ normalise the fraction into [0,1)

▌ MEDIUM  ·  SmartTools.swift:287
  OffsideLine height/centre are hardcoded to 6000 / y=3000, decoupled from
  BEO.boardHeight and from the tool's own start.y — wrong if the board resizes.
  └─ derive height/centre from board bounds, not a literal

▌ MEDIUM  ·  BoardEngineView.swift:147-283
  Heavy DEBUG seed/select/smart/library-add scaffolding (a 4th, drifting copy of
  the create logic) lives inside the shared production board view.
  └─ move the harness into a DEBUG-only helper type/file

▌ MEDIUM  ·  SmartTools.swift:101  +  Brand (app)
  Design tokens are re-hardcoded as raw hex in CoreEngine (lime CBDB2A, teal
  3E7167, danger F0726B…) with no link to the app's Brand palette holding the
  same values — they will drift.
  └─ add Color.brandLime etc. to CoreEngine's ColorProvider and reference it

▌ MEDIUM  ·  MVEngineBuilder.swift:163
  ShapeTool.Build(name:) is the only static builder with no bounds: param, so
  shape tools never receive board bounds (soccer/pool/general/smart do).
  └─ add bounds: and thread it, or document why shapes self-manage bounds

▌ LOW  ·  ColorProvider.swift:31
  RGBA scale ambiguity: model colour defaults are 0–255 but colorFromRGBA wants
  0–1, so any tool relying on the model default renders white/clamped.
  └─ normalise on read, or change defaults to 0–1

▌ LOW  ·  Wrlds/Realm/models/ManagedView.swift:11
  An orphan @objcMembers ManagedView (missing the roster trio + ~16 fields)
  exists in the Wrlds target. Not compiled today (not in pbxproj Sources) →
  dead, but a schema-collision trap if ever added to a shared Realm.
  └─ delete it or make Wrlds depend on CoreEngine's model

▌ LOW  ·  MVEngineBuilder.swift:99
  SmartTool.Build ignores its name/subtype argument — SmartToolManaged re-reads
  subToolType from the row. Hidden coupling; the static signature is misleading.
  └─ pass subtype in, or drop the unused params

▌ LOW  ·  MVEngineBuilder.swift:93
  (type, subtype) pairs are unvalidated: a mismatched pair silently renders the
  wrong builder or EmptyText with no log.
  └─ assert/log on the default EmptyText fallthroughs

▌ LOW  ·  MVEngineBuilder.swift:31
  The whole nav-genre branch (string GenreBuilder case "nav", enum NavBuilder)
  is dead in the board path — sport is never "nav".
  └─ drop or document

▌ LOW  ·  TacticalBoardView.swift:137
  A dead static contextToolbar (non-functional icons) sits beside the wired
  RedesignContextToolbar; duplicate/delete logic is duplicated between views.
  └─ delete the static one; factor duplicate/delete onto BEO

▌ LOW  ·  RedesignPreviewEntry.swift:63  +  MVObject.swift:73
  selectedManagedViewId is one global key persisted across launches; the initial
  bridge honours a stale id even if that tool was deleted/another board.
  └─ validate the persisted id against realm on appear; clear on activity change

▌ LOW  ·  SoccerPlayerToolView.swift:57
  A palette-spawned soccer player (empty teamSide + empty toolColor) renders a
  fixed hardcoded fill, ignoring any persisted colour.
  └─ default teamSide/toolColor on spawn, or derive fill from RGBA

▌ LOW  ·  MVObject.swift:530
  updateRealm writes centerX/Y from the `start` argument (not center) — latent
  corruption if a future caller passes start:.
  └─ center should only come from lifeCenterX/Y

▌ LOW  ·  SmartTools.swift:217-296
  The "~8× board upscale" is not a real constant — every decoration uses a
  different ad-hoc multiple of w, no upper clamp, plus magic 6000/0.02.
  └─ named board-scale constants + a clamp on w

▌ LOW  ·  BoardEngineView.swift:83  /  LudiBoardsApp.swift:25  /  ManagedView.swift:37
  Minor: an unconditional print() ships in release (peers are DEBUG-gated); the
  schemaVersion:2 empty migrationBlock comment overstates Realm's guarantees
  (additive-only); width/height are Int so the size slider quantises board-space.
  └─ gate the print; soften the comment; leave Int unless sub-unit sizing matters
```

### Tradeoffs worth naming

- **One flat `ManagedView` for every tool** is what makes the pipeline extensible and undo/sync uniform — but it forces every renderer to *reinterpret* shared fields, and that's the source of the Properties-mis-edit and width-means-different-things findings. The fix isn't a new model; it's a tool-family-aware editing layer over the one model.
- **Per-family render dispatchers with no shared base** kept each family simple to write but means selection, scaling, drag-persistence and observation are re-implemented four times, inconsistently. A shared "managed tool" protocol (selection ring + drag-persist + observe) would collapse half the Findings.
- **Realm-as-truth, Firebase-as-optional** is right for the free build — but it's applied inconsistently (only the draw path syncs), so "optional" is currently "accidental."
- **The redesign was built additively over the live engine** (DEBUG hooks, parallel context toolbars, denormalised roster) — fast and non-destructive, but it's left two of several things (selection, Properties, roster) wired for the *demo* path and not the *real* one.

---

## Bottom line

The foundation is sound — keep the model and the string pipeline. The work to do is the **editing/interaction layer**, and it clusters: (1) fix smart-tool selection (one line — flip `anchorsAreVisible`), which unblocks Properties for the whole tactic family; (2) make Properties tool-family-aware so SIZE/ROTATION/COLOUR stop silently no-opping on lines and smart tools; (3) make `refreshBoard()` real (or have tool views observe Realm) so colour edits show; (4) pick one create path / persistence helper and one default-geometry factory; (5) wire the roster "Add player" button so the feature exists in release. Items 1–3 are small and high-leverage — they turn "the new tools look right but don't respond" into "they work." The dead routes (enum `buildToolView`, nav genre, Wrlds dup, static contextToolbar) are safe to delete whenever. Nothing here is a rewrite; it's finishing the wiring the redesign started.

**Adjacent observations.** The `selectedManagedViewId` global + cross-launch persistence is a smell beyond the tool layer — it's the single point the whole selection UX rests on, and it's a UserDefaults string. Worth promoting to an in-memory published selection on `BEO` (with AppStorage only as a fallback) before more features lean on it.
