**Target.** Equipment tools (SoccerTool family) end-to-end on the redesign board.
**Scope.** `CoreEngine/.../MVEngineBuilder.swift` (SoccerTool enum + `playerSubtypes` + `Build`), `.../ManagedViews/SoccerPlayerToolView.swift`, `.../MVEngineControl.swift` (Display dispatch), `Ludi Boards/Redesign/Panels.swift` (Equipment tab + `addTool`), `Ludi Boards/Assets.xcassets/tools_soccer_*.imageset`.
**Date.** 2026-06-27

# Audit — Equipment tools

> **TL;DR.** Create + dispatch + assets are all correct — the bug is the player/equipment split: `playerSubtypes` wrongly includes `dummy`, `running`, `walking`, `steps`, so those four figures (which have their own SVG assets) render as the random-numbered jersey **disc** instead. Five of the 13 Equipment items become player circles; only `jersey` should.

**Scope.** SoccerTool enum/Build/playerSubtypes, SoccerPlayerToolView, the Equipment tab + addTool, the asset catalog
**Lines audited.** ~220

---

## Part 1 — Architectural breakdown

### Create + dispatch — correct
Tapping an Equipment cell makes a `soccer` ManagedView and the board routes it back through `SoccerTool.Build`:

```swift
// Ludi Boards/Redesign/Panels.swift  (addTool, equipment branch)
mv.sport = "tool"; mv.toolType = "soccer"; mv.subToolType = subType   // e.g. "tools_soccer_running"
mv.x = 2500; mv.y = 3000; mv.width = RedesignToolCatalog.equipmentSize

// MVEngineControl.swift:68 → GenreBuilder → ToolBuilder
case "soccer": SoccerTool.Build(name: subtype, …)
```

The subtype is the correct rawValue, and the render path resolves it — nothing wrong here.

### The player/equipment split — the bug
`SoccerTool.Build` sends "player subtypes" to the disc and everything else to its image. But the player set is too broad:

```swift
// MVEngineBuilder.swift:218-235
static let playerSubtypes: Set<String> = [
    "tools_soccer_jersey", "tools_soccer_dummy",
    "tools_soccer_running", "tools_soccer_walking", "tools_soccer_steps"
]
…
if playerSubtypes.contains(name) {
    return AnyView(ManagedViewTool(…) { SoccerPlayerToolView(viewId: viewId) })  // disc
}
return AnyView(ManagedViewTool(…) { Image(name).resizable() })                   // equipment image
```

`dummy`, `running`, `walking`, `steps` each have their own figure SVG in the asset catalog (`tools_soccer_running.svg`, etc.), but they're in `playerSubtypes`, so they never reach `Image(name)` — they render as the jersey disc.

### Why the disc looks "random"
The disc shows a deterministic placeholder number derived from the view id when no jersey number is set:

```swift
// SoccerPlayerToolView.swift:28
private var number: Int { mv.jerseyNumber > 0 ? mv.jerseyNumber : Self.placeholderNumber(viewId) }
```

So every `running`/`walking`/`dummy`/`steps`/`jersey` you drop is a circle with a different placeholder number — exactly "random new player icon tools."

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | 20.0.4 | `ManagedView` equipment persistence | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |
| `CoreEngine` | local SPM | `SoccerTool`, `SoccerPlayerToolView`, dispatch | in-repo `CoreEngine/` |
| `SwiftUI` | iOS SDK | `Image(name)` (SVG asset) + the disc | https://developer.apple.com/documentation/swiftui |

---

## Part 2 — Honest assessment

### What's working

- **Create + subtype wiring is correct** — equipment writes the right `soccer`/subtype/size; `addTool` is fine. `Panels.swift addTool`.
- **Dispatch is correct** — `MVEngine.Display` → `SoccerTool.Build(name:)` routes by subtype. `MVEngineControl.swift:68`.
- **Equipment SVGs exist** — every `tools_soccer_*` imageset (cone, goal, ball, flag, ladder, mat, lines, and the four figures) is populated. `Ludi Boards/Assets.xcassets`.

### Findings

```
▌ HIGH      ·  CoreEngine/.../MVEngineBuilder.swift:220-223
  playerSubtypes includes tools_soccer_dummy / running / walking / steps. These
  are distinct figures with their own SVG assets, but the set forces them to
  render as the jersey disc — so tapping Running/Walking/Dummy/Steps (and Jersey)
  all drop random-numbered player circles instead of the figure. This is "most
  equipment creates random player icons."
  └─ shrink playerSubtypes to just ["tools_soccer_jersey"] — the only true
     numbered-circle player (aligns with the "one circle-player tool" request);
     dummy/running/walking/steps then render their figure SVGs via Image(name)

▌ MEDIUM    ·  Ludi Boards/Assets.xcassets/tools_soccer_*.imageset/Contents.json
  The SVG imagesets declare three scale slots (1x/2x/3x) each pointing at an SVG,
  with no "preserves-vector-representation". Xcode SVG support expects a single
  universal vector entry — this layout can render blank or mis-scaled. Couldn't
  verify rendering headlessly; check on device that cone/goal/ball/flag/ladder
  actually show after the HIGH fix unmasks them.
  └─ if equipment images are blank, convert imagesets to single-scale vector
     ("Single Scale" + Preserve Vector Data)

▌ LOW       ·  CoreEngine/.../MVEngineBuilder.swift:198 (shortCone)
  case shortCone = "tools_soccer_mat" — the rawValue ("mat") doesn't match the
  case name; the in-code comment already flags it. Renders the mat asset, just
  mislabeled. Cosmetic.

▌ LOW       ·  CoreEngine/.../MVEngineBuilder.swift:211 (displayName)
  SoccerTool.displayName does substring(from: 5) → "Tools Soccer Tall Cone" minus
  5 chars = " Soccer Tall Cone" (leading space, keeps "Soccer"). The redesign
  Library uses RedesignToolCatalog.toolLabel instead, so it's not user-visible
  there — but the enum method is wrong for any other caller.
  └─ return a clean label
```

### Tradeoffs worth naming

TASK-004 chose to render "player" subtypes as one clean jersey disc for a uniform redesign look — a reasonable call when the only player tool people cared about was the numbered token. But it conflated *figures* (running/walking/dummy/steps poses) with *the player token*. Those figures aren't players-with-numbers; they're distinct equipment with their own art. The redesign's uniform-disc instinct is right for **jersey** and wrong for the other four. Narrowing `playerSubtypes` to `jersey` keeps the clean disc where it belongs and lets the figures be themselves.

---

## Bottom line

One-line root cause, one-line fix: remove `dummy`/`running`/`walking`/`steps` from `playerSubtypes` so only `jersey` renders as the numbered disc; the four figures then render their existing SVGs and the "everything is a random player circle" problem is gone. Then verify on device whether the equipment SVGs actually paint — if they're blank, the imageset scale-slot layout (MEDIUM) is a second, asset-side fix. Do the HIGH first; it's the one the user is hitting.

**Adjacent observations.** This is the same class of bug as the pool audit — a render-routing decision that didn't match the tool's real identity. After this, every SoccerTool subtype maps to its intended visual (jersey→disc, the rest→their SVG).
