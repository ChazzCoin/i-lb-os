**Target.** NavStack window system (CoreEngine `ECViewEngine` — TheNavStack, NavStack, ViewFactory, CanvasEngine clones + app-side consumers)
**Scope.** NavStackController.swift, NavStackView.swift, _NavStackObservable.swift, _FloatingNavWindow.swift, WindowProvider.swift, NavStackFactory.swift, TheFactory.swift, ViewHolder.swift, NodeWindowController.swift, NodeStackWindow.swift, WindowHolder.swift, FloatingRoomView.swift, NavTools.swift, BroadcastTools.swift, ChannelProvider.swift, Queue.swift, GPS.swift (positioning core), Ludi Boards/CanvasEngine.swift, Wrlds/CanvasEngine.swift
**Date.** 2026-06-11

# Audit — NavStack window system

> **TL;DR.** The concept — a pool of views inside one floatable, resizable shell, summoned over a broadcast bus — is right for a canvas app, but the implementation has four real bugs in its core loop (FIFO back stack, dropped no-view messages, an every-other-message bus debounce, a dead public API) and has already forked into a second ~500-line copy that will drift.

**Lines audited.** ~2,900

---

## Part 1 — Architectural breakdown

### The controller — `NavWindowController`

One controller instance = one window shell. It owns a dictionary pool of view builders, an "active view" pointer, a back stack, size/float/lock state, drag position, keyboard state, and Realm persistence of its own geometry. It is an `ObservableObject` that views observe via `@EnvironmentObject`.

```swift
// CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackController.swift:156
@Published public var activeView: ManagedViewHolder? = nil
@Published public var viewPool: [String: ManagedViewHolder] = [:]
@Published public var backStack: CoreQueue<String> = CoreQueue()

@Published public var navSize: NavStackSize = .full
@Published public var mainState: NavStackState = .closed
@Published public var isLocked = true
@Published public var isFloatable: Bool = true
```

Navigation is "swap the active view": `navTo(viewId:)` looks up the pool and reassigns `activeView`; the window re-renders. There is no use of `NavigationStack` paths — the stack chrome is a shell around a swapped `AnyView`.

### The shell — `NavStackWindow`

The single SwiftUI view that renders whatever is active. It branches on horizontal size class — `NavigationSplitView` (sidebar + detail) on regular widths, `NavigationStack` on compact — then applies frame/position/offset from the controller and attaches the drag gesture when floating is enabled.

```swift
// CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackView.swift:27
if hSize == .regular {
    ModernSplitView()        // iPad / large
} else {
    CompactStackView()       // iPhone / compact
}
...
.frame(width: NAV.width, height: NAV.height)
.position(NAV.position)
.simultaneousGesture( NAV.isLocked || !NAV.isFloatable ? nil : DragGesture()... )
```

Toolbar buttons drive minimize (`mainState = .closed`) and size cycling (`toggleSize()` walks full_menu_bar → full → floating → back). A keyboard listener shifts the window up by half the keyboard height.

### Multi-size and floating

Six named presets, all computed from `UIScreen.main.bounds` at access time:

```swift
// NavStackController.swift:53
public enum NavStackSize: String, CaseIterable {
    case full, full_menu_bar, half,
         floatable_large, floatable_medium, floatable_small
    public var height: Double { /* UIScreen.main.bounds.height * factor */ }
}
```

`setSize` writes width/height/position, re-centers via `GlobalPositioningSystem` (which tracks the active window's frame + safe-area insets and answers "give me the point for `.centerRight`"), zeroes drag offsets, and persists. Floating mode = `isFloatable && !isLocked`, which arms the drag gesture.

### The message bus

All window control rides a global Combine `PassthroughSubject<Any, Never>` per channel (`CodiChannel.NavStackMessage`), wrapped by `BroadcastTools`. The payload is an untyped class:

```swift
// CoreEngine/Sources/CoreEngine/ECProviders/ChannelProvider.swift:38
public class NavStackMessage {
    public var navId: String = "master"      // which stack
    public var navAction: WindowAction?      // open/close/toggle the shell
    public var sidebarAction: WindowAction?
    public var size: NavStackSize?
    public var viewName: String?             // which pooled view
    public var viewAction: WindowAction?     // open/close/toggle that view
}
```

Senders are scattered and reference views by raw string: `MenuBarIcon` (CoreEngine/Sources/CoreEngine/ECViews/MenuBar/MenuBarIcon.swift:47), `CanvasMenuView`, `MVObject`, app toolbars ("mvsettings", "board settings", "toolbox"). The controller subscribes in `init` and routes navAction → shell state, viewAction → pool navigation.

### Registration

App code populates the pool imperatively at canvas `onAppear`:

```swift
// Ludi Boards/CanvasEngine/CanvasEngine.swift:234
navTools.addView(
    callerId: MenuBarProvider.home.tool.title,
    mainContent: { HomeDashboardView().environmentObject(self.BEO) },
    sideContent: { MenuListView(isShowing: .constant(true)) }
)
```

Builders are erased to `() -> AnyView` inside a `ManagedViewHolder` (one of five near-identical holder classes — see Findings). The controller also self-seeds a "profile" view in `preLoadWithCoreViews()`.

### Persistence — "DynaView"

Window geometry survives relaunch by writing into the same Realm `ManagedView` type used for canvas tools, keyed by the controller id (`"master"`): `toolType` holds the size preset string, `isLocked` holds `isFloatable`, x/y/startX/startY hold offsets and position. `loadDynaView()` restores on init; `saveDynaView()` fires on every size change and every drag tick.

### The clones

This subsystem exists 3–4 times:

- `NodeWindowController` + `NodeStackWindow` (CanvasEngine/, dated 2/3/26, the in-flight room migration) — a near-verbatim copy of `NavWindowController` with `Nav→Node` renames, an added `preloadedPool`, and `NodeStackSize` identical to `NavStackSize` value-for-value.
- `NavStackWindowObservable` (NavStack/_NavStackObservable.swift) — an older string-based ("full"/"half") size manager, still compiled, apparently unused by the new path.
- `_FloatingNavWindow.swift` — 100% commented out.
- Holder classes: `CoreViewHolder`, `ManagedViewHolder`, `ManagedViewRegistry`, `NodeViewHolder`, `CanvasViewHolder` — differing only in GPS namespace and `AnyView` wrapping.

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | `branch: master` (CoreEngine/Package.swift:21) | window-geometry persistence via `ManagedView` | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |

Everything else in this slice is system SwiftUI/Combine/UIKit. (Firebase is a CoreEngine dependency but isn't touched by the NavStack path.)

---

## Part 2 — Honest assessment

### What's working

- **The windowing model itself** — pool of named views + one floatable shell + bus-summoning is a sensible design for a canvas app where any tool can request a window without holding a controller reference. The shape is worth keeping.
- **Size-class adaptive chrome** — `NavigationSplitView` on regular, `NavigationStack` on compact ([NavStackView.swift:30](CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackView.swift:30)) is the right instinct and already half-modernized (topBarLeading/Trailing placements).
- **Main + sidebar pairing per view** — every pooled view declares a sidebar companion up front; the iPad split view gets content for free.
- **Geometry persistence across launches** — remembering size/float/position is the right feature; users get their window back where they left it.
- **GlobalPositioningSystem reads the real window frame** — [GPS.swift:250](CoreEngine/Sources/CoreEngine/ECViews/Parents/GPS.swift:250) pulls the foreground `UIWindowScene` frame and safe-area insets rather than trusting `UIScreen.main` (unlike the size enum — see Findings).

### Findings

```
▌ CRITICAL  ·  CoreEngine/Sources/CoreEngine/ECUtils/Queue.swift:18
  the back stack is a FIFO queue, so goBack() is wrong: dequeue()
  removes the OLDEST entry and peek() shows the second-oldest. After
  A→B→C, goBack lands on B by coincidence; the next goBack goes
  FORWARD to C and the pair oscillates B↔C forever; A is unreachable.
  The "// Remove current view" comment at NavStackController.swift:387
  shows the intent was LIFO. Same bug copied into
  NodeWindowController.goBack (NodeWindowController.swift:447).
  └─ use a real stack (elements.removeLast()/last, current on top),
     and skip enqueueing when navigating to the already-active view

▌ CRITICAL  ·  CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackController.swift:207
  any NavStackMessage without a viewName — or naming a view not yet
  in the pool — is silently dropped before navAction/size are read.
  This kills the documented API: NavWindowController.openNavStack()
  (line 144) sends navAction-only and can never open the window;
  size-only messages are dropped too.
  └─ process navAction/size independently of viewName; queue (or log)
     messages for unregistered views instead of swallowing them

▌ CRITICAL  ·  CoreEngine/Sources/CoreEngine/ECTools/BroadcastTools.swift:32
  the ignoreRequest flag in subscribeTo drops every second message
  arriving within 0.5s: handle one → set ignoreRequest=true → next
  event is consumed resetting the flag → third passes. Two distinct
  legitimate commands (e.g. "close settings, open chat") fired
  back-to-back lose the second. Every window/canvas subscription in
  the app rides this method.
  └─ delete the debounce; if echo-suppression is needed, tag messages
     with a senderId and have the sender ignore its own

▌ CRITICAL  ·  CoreEngine/Sources/CoreEngine/ECTools/NavTools.swift:13
  NavTools is a dead API: every method sends a WindowController object
  on the NavStackMessage channel, but all subscribers cast the payload
  to NavStackMessage (as? fails) — goTo/open/close/toggle silently do
  nothing. No call sites today, but it's the obvious public entry
  point in CoreEngine; the next consumer will reach for it and lose
  an hour. goToWindow (NavStackController.swift:47) half-overlaps it
  on a different channel.
  └─ make NavTools send NavStackMessage (and make it the ONLY way to
     send one), or delete it

▌ HIGH      ·  CoreEngine/Sources/CoreEngine/ECViewEngine/WindowViews/WindowHolder.swift:15
  multiple live NavWindowController instances all claim id "master":
  Wrlds/CanvasEngine.swift:19 creates one, then WindowManagerView
  (instantiated inside that same canvas, Wrlds/CanvasEngine.swift:82)
  creates another; FloatingRoomView.swift:18 and CanvasView.swift:17
  create more. All subscribe to the same channel (navId filter passes
  for every one) and all load/save the same Realm row keyed "master" —
  duplicate message handling and last-writer-wins geometry corruption.
  └─ require an explicit unique id per controller (no "master"
     default), or make the master stack a single shared instance

▌ HIGH      ·  CoreEngine/Sources/CoreEngine/ECViewEngine/CanvasEngine/NodeWindowController.swift:185
  NodeWindowController/NodeStackWindow is a ~500-line copy-paste of
  NavWindowController with renamed types (NodeStackSize is value-
  identical to NavStackSize). Every bug above now exists twice and
  the copies are already drifting (Node lost drag/persistence, gained
  preloadedPool). Plus five holder classes that differ only in GPS
  namespace. This is the single biggest threat to "robust and
  dynamic" — fixes won't propagate.
  └─ one generic WindowController parameterized by namespace/id;
     one holder type

▌ HIGH      ·  CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackController.swift:444
  geometry restore is partial and semantically inverted: loadDynaView
  restores only full / full_menu_bar / floatable_medium — half,
  floatable_large, floatable_small silently fall through to defaults —
  and the persisted field `isLocked` actually stores isFloatable
  (line 475), the OPPOSITE of the runtime invariant (floatable ⇒
  unlocked). isFloatable itself is never restored (the restore block
  is commented out, lines 457-462). Window state also piggybacks the
  canvas-tool ManagedView schema (toolType = a size string).
  └─ iterate NavStackSize(rawValue:) for restore; persist a dedicated
     small window-state object with honestly-named fields

▌ HIGH      ·  CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackController.swift:320
  masterResetTheWindow() sets masterResetNavWindow = true then false
  synchronously; SwiftUI renders once per runloop tick and only ever
  sees false, so the intended teardown/rebuild never happens. I'm
  confident from reading; not runtime-verified. Every size change,
  orientation change, and onAppear calls this no-op — meaning the
  system "works" without it and it should be deleted, or (if a real
  identity reset is needed) replaced with a .id(resetToken) modifier.
  └─ delete it, or flip the flag back asynchronously / use .id()

▌ HIGH      ·  CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackController.swift:151
  SwiftUI property wrappers misused inside an ObservableObject:
  @StateRealmObject, @ObservedObject (gps, broadcaster), @GestureState,
  and @Published cancellables only function inside Views. Consequence:
  GPS orientation updates never re-render the window through NAV, the
  class-level dragOffset is permanently .zero (see MEDIUM below), and
  self._dyna = StateRealmObject(...) reassignment (line 440) is
  undefined behavior territory.
  └─ plain `let gps`, plain var for dyna, drop the dead wrappers

▌ MEDIUM    ·  CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackController.swift:63
  all six size presets compute from UIScreen.main.bounds — wrong under
  iPad Split View / Stage Manager and stale across rotation, which is
  why rotation needs a 0.5s-delayed manual reset (NavStackView.swift:94).
  GPS already knows the real window size; the enum should take a
  container CGSize instead of reaching for the screen.
  └─ NavStackSize.size(in: CGSize) — derive from container geometry

▌ MEDIUM    ·  CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackView.swift:59
  saveDynaView() runs on every drag onChanged tick — one Realm write
  transaction per finger movement frame.
  └─ persist once in onEnded (the onEnded call at line 70 already
     covers it)

▌ MEDIUM    ·  CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackView.swift:42
  dead dual-path drag plumbing: NAV.isDragging is never set true (the
  gesture sets the local @State copy), and NAV.dragOffset is a
  @GestureState in a class so it never updates — the drag terms in
  .offset are permanently zero. Dragging works only because onChanged
  mutates offPos directly. Functional, but the dead path invites a
  future "fix" that breaks it.
  └─ delete isDragging/dragOffset from the controller; keep the
     offPos path

▌ MEDIUM    ·  CoreEngine/Sources/CoreEngine/ECViewEngine/TheNavStack/NavStackView.swift:74
  keyboard avoidance is magic-number heuristics: <100pt threshold,
  raise by height/2, lower by height*2. Behavior varies by device,
  keyboard, and floating-window position.
  └─ compute overlap between window frame and keyboard frame; shift
     by the overlap

▌ MEDIUM    ·  CoreEngine/Sources/CoreEngine/ECViewEngine/ViewFactory/ViewHolder.swift:65
  the pool stores () -> AnyView closures and navigation swaps the
  whole window content — SwiftUI identity/diffing and view state are
  reset on every navTo, and NavigationStack's own push/pop (path,
  system back gesture, transitions) is unused chrome.
  └─ if push/pop semantics matter, drive NavigationStack with a real
     path bound to backStack; keep AnyView only at the pool boundary

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/CanvasEngine.swift:185
  stringly-typed routing with casing patched at ~20 call sites:
  every pool access calls .lowercased() ad hoc; senders use
  "mvSettings" while listeners match "mvsettings"; "board settings"
  contains a space. One missed lowercased() = silent no-op window.
  └─ a WindowID newtype (or enum) that lowercases once at construction

▌ LOW       ·  Ludi Boards/CanvasEngine/CanvasEngine.swift:269
  force cast `controller as! WindowController` on a channel typed
  Any — one stray payload crashes the app.
  └─ as? with early return

▌ LOW       ·  CoreEngine/Sources/CoreEngine/ECViewEngine/NavStack/_NavStackObservable.swift:12
  three generations of dead/parallel code ship in the package:
  NavStackWindowObservable (old size system), _FloatingNavWindow
  (fully commented out), NavViewFactory (hardcoded 2-view switch),
  plus misleading copied file headers ("ManagedWindows.swift" atop
  NavStackController.swift).
  └─ delete the dead generation once the consolidation lands
```

### Tradeoffs worth naming

The broadcast-bus design buys real decoupling — a canvas tool buried five views deep can summon any window with one line, no environment plumbing — and that fits how the canvas grows organically. The cost is everything in this report's CRITICAL tier: untyped `Any` payloads, string IDs, silent drops, and no way to know a message went nowhere. The `AnyView` pool makes registration trivially dynamic (any view, registered at runtime) at the price of SwiftUI's diffing, state preservation, and navigation machinery. Persisting into `ManagedView` reused an existing Realm type instead of adding a migration — pragmatic at the time, but it welds window chrome to the canvas-tool schema you're actively migrating (per the in-flight room module work). None of these tradeoffs were wrong to take; they're just unpaid-for now that the system is load-bearing across two apps.

---

## Bottom line

Keep the architecture, rewrite the engine room. The model — named view pool, one floatable/resizable shell, bus summoning, geometry persistence — is genuinely good for what you're building, and the shell view is mostly fine. What's not robust is everything underneath: back navigation is built on a queue that isn't a stack, the bus drops every second rapid message by design, the no-view open API is dead on arrival, and the whole controller has now been copy-pasted into a Node variant that will drift. If this were mine I'd do one focused pass, in this order: (1) fix `CoreQueue`→ real stack, (2) remove the `ignoreRequest` debounce, (3) restructure the intake handler so navAction/size work without viewName, (4) collapse `NavWindowController`/`NodeWindowController` into one generic controller with required unique ids, (5) move sizing to container-relative and persistence to its own model. That's roughly a 600-line surgical rewrite inside CoreEngine — not an app rebuild — and it should land *before* the room migration adds more consumers to the Node copy.

**Adjacent observations.** ChannelProvider has crossed wires outside this scope: `TOOL_ON_DELETE` returns `ToolOnCreateChannel.shared` ([ChannelProvider.swift:245](CoreEngine/Sources/CoreEngine/ECProviders/ChannelProvider.swift:245)), so create and delete events share one subject; `ToolSubscriptionChannel`/`ToolOnMenuReturnChannel`/`ToolAttributesChannel` all instantiate `ToolOnDeleteChannel()` as their `shared`. Also `CoreEngine/Package.swift:21` pins realm-cocoa to `branch: "master"` — an unpinned dependency that contradicts the Realm v20 discipline noted in project memory.
