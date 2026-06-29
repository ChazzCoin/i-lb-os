**Target.** Squad roster panel, "Add player" flow, and the right-hand side drawer in the Canvas/Board redesign.
**Scope.** `Ludi Boards/Redesign/Panels.swift`, `RosterPlayer.swift`, `BoardScreenState.swift`, `TacticalBoardView.swift`, `Components.swift`, `RedesignPreviewEntry.swift`, plus the roster seed in `CanvasEngine/BoardEngineView.swift` and `refreshBoard()` in `BoardEngineObject.swift`.
**Date.** 2026-06-26

# Audit — Squad / Add player / Side drawer

> **TL;DR.** The drawer plumbing is clean and the place-on-board path works, but the "Add player" button is half-wired: it persists a player and then never tells the view to redraw, so tapping it looks like a no-op. The roster model underneath it has no edit, no delete, no away-side path, and no real population route outside a DEBUG seed.

**Scope.** `Redesign/Panels.swift`, `Redesign/RosterPlayer.swift`, `Redesign/BoardScreenState.swift`, `Redesign/TacticalBoardView.swift`, `Redesign/Components.swift`, `Redesign/RedesignPreviewEntry.swift`, `CanvasEngine/BoardEngineView.swift` (seed), `CanvasEngine/BoardEngineObject.swift` (`refreshBoard`)
**Lines audited.** ~1,750

---

## Part 1 — Architectural breakdown

### Side-drawer state machine

The right drawer is a pure derived state. `BoardScreenState` holds three inputs (`selectedToolId`, `libraryOpen`, `mode`) and resolves which panel shows:

```swift
// Ludi Boards/Redesign/BoardScreenState.swift:40
var panel: RightPanel {
    if libraryOpen { return .library }
    if selectedToolId != nil { return .properties }
    return .squad
}
```

This is the seam the whole feature hangs off. It's a clean priority chain — Library wins, then a selection shows Properties, otherwise Squad. The consequence worth internalising: **Squad is the resting/default panel, not something you summon.** There is no "Squad" button anywhere. You see the roster only when nothing is selected and the Library is closed.

### Panel host + render gating

`TacticalBoardView` composes the chrome and switches the drawer body off `state.panel`, choosing engine-wired vs. mockup variants by a single flag:

```swift
// Ludi Boards/Redesign/TacticalBoardView.swift:126
@ViewBuilder private var rightPanel: some View {
    switch state.panel {
    case .squad:      if useEngineCanvas { EngineSquadPanel(state: state) } else { SquadPanel() }
    case .properties: if useEngineCanvas { EnginePropertiesPanel(state: state) } else { PropertiesPanel() }
    case .library:    if useEngineCanvas { EngineLibraryPanel() } else { LibraryPanel() }
    }
}
```

Every panel has a dumb preview twin and a live `Engine*` twin. The split is consistent and is why the SwiftUI previews still render with no `BoardEngineObject`. Good discipline.

### Squad panel — read path

`EngineSquadPanel` reads the roster with a synchronous Realm query inside `body`, partitioned by side, and maps each `RosterPlayer` to the view-model `SquadPlayer`:

```swift
// Ludi Boards/Redesign/Panels.swift:72
private func roster(_ side: String) -> [RosterPlayer] {
    Array(BEO.realmInstance.objects(RosterPlayer.self)
        .filter("boardId == %@ AND teamSide == %@", BEO.currentActivityId, side)
        .sorted(byKeyPath: "orderIndex"))
}
```

`Array(...)` snapshots the live `Results`. SwiftUI will only re-run `body` when an observed object publishes — and a Realm write here publishes nothing. This is the root of the Add-player bug (see Findings).

### Squad panel — write paths

Two writes hang off the panel: `place(_:)` (tap a roster row → spawn a linked jersey `ManagedView`) and `addPlayer()` (footer button → create a `RosterPlayer`).

```swift
// Ludi Boards/Redesign/Panels.swift:113
private func addPlayer() {
    let home = roster("home")
    let nextNumber = (home.map(\.number).max() ?? 0) + 1
    BEO.realmInstance.safeWrite { r in
        let p = RosterPlayer()
        p.boardId = BEO.currentActivityId
        p.teamSide = "home"            // <-- always home
        p.number = nextNumber
        p.name = "Player \(nextNumber)"
        p.position = "—"
        p.orderIndex = home.count
        r.create(RosterPlayer.self, value: p, update: .all)
    }
    // <-- no BEO.refreshBoard()
}
```

`place()` ends with `BEO.refreshBoard()`; `addPlayer()` does not. That asymmetry is the bug.

### The roster model

`RosterPlayer` is a board-scoped Realm object — a squad belongs to a board, not to a reusable team:

```swift
// Ludi Boards/Redesign/RosterPlayer.swift:14
public class RosterPlayer: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var boardId: String = ""
    @Persisted public var teamSide: String = "home"
    @Persisted public var number: Int = 0
    @Persisted public var name: String = ""
    @Persisted public var position: String = ""
    @Persisted public var orderIndex: Int = 0
}
```

No team name, no formation, no squad entity. Registered additively at `schemaVersion: 2` in `LudiBoardsApp.swift:28` with an empty migration block.

### `refreshBoard` — the redraw mechanism

```swift
// Ludi Boards/CanvasEngine/BoardEngineObject.swift:359
func refreshBoard() {
    self.boardRefreshFlag = false
    self.boardRefreshFlag = true
}
```

`boardRefreshFlag` is `@Published`, so flipping it fires `BEO.objectWillChange` and re-runs every view observing `BEO` — including `EngineSquadPanel`, which re-fetches the roster. This is the implicit refresh that `place()`/`delete()`/`duplicate()` rely on and `addPlayer()` is missing.

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | 20.0.4 (realm-cocoa) | Persistence for `RosterPlayer` + `ManagedView`; live queries, `safeWrite` | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |
| `CoreEngine` | local SPM package | `BoardEngineObject`, `ManagedView`, `ViewEngine.Tool.SmartTool`, board canvas | (in-repo: `CoreEngine/`) |
| `SwiftUI` | iOS SDK | All panels, drawer composition, state objects | https://developer.apple.com/documentation/swiftui |

---

## Part 2 — Honest assessment

### What's working

- **Drawer resolution is a clean derived value** — `BoardScreenState.panel` is a single readable priority chain; no scattered booleans fighting each other. `Redesign/BoardScreenState.swift:40`.
- **Preview/engine twin split is disciplined** — every panel renders without a `BoardEngineObject`, so SwiftUI previews and the simctl render harness keep working. `Redesign/TacticalBoardView.swift:126`.
- **`place()` is correctly wired** — denormalises number/side onto the jersey `ManagedView`, keeps `playerId` for the Properties linked-player, and refreshes. `Redesign/Panels.swift:128`.
- **Selection bridge is defensively coded** — the `selectedManagedViewId` rehydration validates the id (exists, not deleted, same board) before ringing a selection, instead of trusting stale AppStorage. `Redesign/RedesignPreviewEntry.swift:54`.

### Findings

```
▌ CRITICAL  ·  Ludi Boards/Redesign/Panels.swift:113
  addPlayer() writes a RosterPlayer but never calls BEO.refreshBoard(),
  and EngineSquadPanel reads the roster as a snapshot Array in body
  (not @ObservedResults). Nothing publishes -> the new player does NOT
  appear. Tapping the audited feature's main button looks like a no-op
  (the row only shows up after an unrelated refresh).
  └─ append BEO.refreshBoard() to addPlayer(), or switch the panel to
     @ObservedResults(RosterPlayer.self) so the live query drives redraw

▌ HIGH      ·  Ludi Boards/Redesign/Panels.swift:120
  addPlayer() hardcodes teamSide = "home". In a release build the roster
  is only otherwise populated by the DEBUG seed (REDESIGN_SEED=1), so the
  AWAY squad can never be filled in production, and HOME players land as
  "Player N" / position "—" with no way to edit name, number, or position.
  └─ add an away-side path and a minimal edit affordance (name/number/pos)

▌ HIGH      ·  Ludi Boards/CanvasEngine/BoardEngineView.swift:160
  The only roster population path, seedRosterIfNeeded(), is #if DEBUG and
  gated on REDESIGN_SEED=1. Production ships an empty squad, and the panel
  has no empty state -> two header rows ("HOME · 4-3-3" count 0, "AWAY ·
  4-4-2" count 0) with no rows and no guidance.
  └─ add an empty-state ("No players yet — Add player to start") and a
     real first-run population path

▌ MEDIUM    ·  Ludi Boards/Redesign/Panels.swift:128
  place() never checks whether a roster player already has a disc on the
  board. Each tap spawns another jersey linked to the same playerId, so a
  single roster person can be placed N times with no dedup or toggle.
  └─ guard on existing ManagedView with this playerId, or make the tap a
     place/remove toggle

▌ MEDIUM    ·  Ludi Boards/Redesign/Panels.swift:93
  Formation labels "HOME · 4-3-3" and "AWAY · 4-4-2" are hardcoded in
  both SquadPanel and EngineSquadPanel regardless of real roster. Count is
  live; the formation string is fabricated -> misleading once a user edits
  the squad.
  └─ derive from positions or drop the formation text until it's real

▌ LOW       ·  Ludi Boards/Redesign/Components.swift:134
  Squad/team name is hardcoded "U-12 Squad" in TopBar and passed literally
  by EngineTopBar (comment: "roster name lands in RD-5" — it didn't). No
  squad/team entity exists; RosterPlayer is board-scoped only.
  └─ introduce a squad/team name or read it from the activity

▌ LOW       ·  Ludi Boards/Redesign/Panels.swift:123
  addPlayer() sets orderIndex = home.count. Harmless today (no delete
  path), but the moment roster deletion lands this collides on the next
  insert after a mid-list removal.
  └─ use (max(orderIndex) + 1) when a delete path is added

▌ LOW       ·  Ludi Boards/LudiBoardsApp.swift:29
  Empty migrationBlock at schemaVersion 2. Fine while changes stay
  additive; the code comment already flags (TASK-024) that any rename/
  remove/retype on RosterPlayer or ManagedView will throw at launch.
  └─ no action now; populate the block on the first non-additive change
```

### Tradeoffs worth naming

The roster is deliberately **board-scoped, not a reusable team**. `RosterPlayer.boardId` means each activity carries its own squad — simple, no cross-board entity to manage, and it matches the "deferred roster model (RD-5)" framing in the file header. The cost is that there's no concept of "my U-12 team" persisting across activities; build a lineup on one board and it doesn't follow you to the next. That's an acceptable scaffold choice, but it's a choice — the hardcoded "U-12 Squad" breadcrumb papers over the fact that no squad identity actually exists yet.

The second real tradeoff is the **snapshot-in-`body` read vs. `@ObservedResults`**. Reading `Array(results)` keeps the panel a plain `View` and dodges Realm/SwiftUI lifecycle quirks, but it forfeits automatic redraw and forces every writer to remember `refreshBoard()`. The CRITICAL finding is exactly the failure mode that choice invites. `@ObservedResults` would make the roster self-refreshing and delete a whole class of "forgot to refresh" bugs.

---

## Bottom line

The drawer architecture is sound and most of it is genuinely well-built — don't touch the state machine or the twin-panel split. The work is in the roster itself: ship the one-line `refreshBoard()` fix (or move to `@ObservedResults`) so Add-player stops looking broken, then decide whether the roster is a real feature or still a scaffold. If it's real, it needs away-side add, edit, delete, an empty state, and a place/remove toggle — that's a focused batch, not a rewrite. If it's still a scaffold for RD-5, at least add the empty state and the refresh so the visible no-op doesn't read as a bug to anyone testing the branch.

**Adjacent observations.** The Library drawer's only production entry is the bottom-right "Library" toggle in `RedesignPreviewEntry.swift:117` (a leftover from the debug switcher); there's no rail/top-bar affordance for it, and the file header still calls itself "NOT the app's @main" even though it now is. Worth a cleanup pass on that file's framing post-cutover.
