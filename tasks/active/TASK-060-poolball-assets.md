# TASK-060: PoolBall renders invisible — missing ball image assets

**Phase:** TC — Tool catalog · **Severity:** MEDIUM · **Depends on:** TASK-059 · **Source:** [audit](../../docs/audits/2026-06-27-tool-catalog.md)

## User story
As a **coach**, I want **a pool ball I place from the Library to actually show up on the board** so that **I can lay out pool/billiards drills instead of dropping invisible tools that look like nothing happened**.

## Why this matters
`PoolBallTool.Build(name:)` renders an `Image(name)` where `name` is the ball-number string (`"0"`–`"15"`, plus `"8"`). There is no imageset named `0`/`1`/…/`15` in the asset catalog, so SwiftUI resolves each to an empty image and every pool ball renders invisible. Today this is **latent** — the redesign Library has no Pool tab, so PoolBall is unreachable (only Equipment/Shapes/Tactics tabs exist, per TASK-040). But the moment Pool is surfaced (TASK-059), every ball a coach places will be a transparent, zero-content `ManagedViewTool` — placeable, selectable, draggable, and completely invisible. This is the exact "I placed it and nothing appeared" failure the `default: EmptyText()` dispatch is designed to hide. Pool must render before it is surfaced; TASK-060 makes the pixels exist, TASK-059 makes the tab exist.

## Findings / current state
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift:231`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — `enum PoolBallTool: String` declares 16 cases whose raw values are the ball-number strings: `solid1 = "1"` … `solid7 = "7"`, `stripe9 = "9"` … `stripe15 = "15"`, `eightBall = "8"`, `que = "0"`. `var name: String { rawValue }`, so the render name for each ball is literally `"0"`–`"15"`.
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift:267`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — the static `Build(name:viewId:activityId:bounds:)` (the one the dispatch calls) renders `Image(name).resizable()` inside a `ManagedViewTool`. The instance `Build` at line 263 does the same with `Image(self.name)`. Both resolve the asset by ball-number string.
- [`Ludi Boards/Assets.xcassets`](../../Ludi%20Boards/Assets.xcassets) — no imageset is named `0`/`1`/…/`15`. The catalog has `baseball.imageset`, `basketball.imageset`, `pool_table.imageset`, `tool_football.imageset`, `tools_soccer_soccer_ball.imageset`, etc. — nothing that satisfies `Image("0")`…`Image("15")`. Every pool ball therefore resolves to an empty image and renders invisible.
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift:98`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — `case "pool": …PoolBallTool.Build(name: subtype, …)` is wired in the `ToolBuilder` dispatch, so the render path is correct end-to-end; the only missing piece is the pixels. The switch ends in `default: EmptyText()` (line 100) — there is no "unknown/missing asset" placeholder, which is why a missing imageset fails silently rather than showing a fallback.
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/Shapes/PoolBallToolView.swift:14`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/Shapes/PoolBallToolView.swift) — `PoolBallType` already carries per-ball intent that a drawn fallback could use directly: numbered cases (`solid1…solid7`, `stripe9…stripe15`, `eightBall = 8`, `que = 0`) and a `color` mapping per ball. This is the data a numbered-circle fallback needs; it does not need new assets to know each ball's color/number.
- Surfacing is the sibling task: PoolBall (16) and GeneralTool (71) are not surfaced in the redesign Library at all (audit Part 2, MEDIUM). TASK-059 surfaces Pool; this task ensures it renders when surfaced.

## Scope
**In scope:**
- Make a placed pool ball render visibly for all 16 subtypes (`"0"`–`"15"`, incl. `"8"`). Two acceptable approaches — pick one:
  1. **Assets** — add 16 imagesets to `Ludi Boards/Assets.xcassets` named exactly `0`,`1`,…,`15` so `Image(name)` resolves, OR
  2. **Drawn fallback** — replace the `Image(name)` render in `PoolBallTool.Build` with a drawn numbered circle (solid vs stripe by ball number, color from the existing `PoolBallType.color` mapping), removing the asset dependency entirely.
- Whichever is chosen, the render must be consistent for both the static `Build(name:…)` (line 267) and the instance `Build(viewId:activityId:)` (line 263) so tap-add and any catalog/icon path agree.

**Out of scope:**
- **Firebase / persistence** — OUT. Keep the change Firebase-ready only (no sync calls); rendering reads the local `ManagedView` as today.
- Surfacing the Pool tab in the redesign Library — that is **TASK-059** (this task depends on it landing for end-to-end verification, but does not add the tab).
- GeneralTool (71) surfacing/rendering — separate finding.
- **Do not re-touch the working SoccerTool (13) or SmartTool (13) families** — they render/asset/icon/interact correctly per the audit; no edits there.
- ShapeTool circle/square/triangle geometry and the dragged-shape size branch — separate tasks; do not fold in.

## Files expected to change
- `Ludi Boards/Assets.xcassets` (approach 1: add 16 ball imagesets `0`–`15`), and/or
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift` (approach 2: swap the `Image(name)` render in `PoolBallTool.Build` for a drawn fallback; touch both the static and instance `Build`)
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/Shapes/PoolBallToolView.swift` (only if the drawn fallback is extracted/reused here)

## Acceptance criteria
- [ ] Placing each of the 16 pool ball subtypes (`"0"`,`"1"`,…,`"15"`, including `"8"`) produces a **visible** view on the board — none render as an empty/transparent tile.
- [ ] The 8-ball (`"8"`) and the cue/`que` ball (`"0"`) are visually distinguishable from each other and from the numbered solids/stripes.
- [ ] Solids (`1`–`7`) and stripes (`9`–`15`) are visually distinct from one another (if drawn fallback: stripe banding or equivalent; if assets: the imagesets reflect it).
- [ ] The render is identical whether produced by the static `Build(name:…)` (MVEngineBuilder.swift:267) or the instance `Build` (line 263) — no path renders blank.
- [ ] If the asset approach is taken, all 16 imagesets exist in `Ludi Boards/Assets.xcassets` with names matching the raw values exactly (`0`–`15`); no `Image("N")` resolves empty.
- [ ] No change to SoccerTool or SmartTool rendering; no Firebase/sync code added.
- [ ] A placed pool ball remains selectable / movable / deletable (the `ManagedViewTool` wrapper behavior is unchanged).

## Verification (build + sim)
1. `/build` clean.
2. Launch the iPad simulator scheme **"Ludi Boards"** (bundle `io.ludi.sol`), verified headlessly per the project's background-simulator convention.
3. Verify layout on an **iOS 18.x iPad simulator in LANDSCAPE** — the 26.x sim masks rendering bugs; do not verify only on 26.x.
4. Seed tools with `REDESIGN_SMART=1` (or place from the Library once TASK-059 surfaces the Pool tab). Place several pool balls — at minimum `0` (cue), `8`, a solid (`1`–`7`), and a stripe (`9`–`15`) — and confirm each renders visibly and distinctly, not as an invisible/empty tile.
5. Confirm a placed ball can be selected, dragged, and deleted.

## Open questions / risks
- **Assets vs drawn fallback.** Assets give richer visuals but add 16 imagesets to maintain and ship; the drawn fallback needs no art, stays in sync with `PoolBallType.color`, and removes the silent-missing-asset failure mode entirely — but must reproduce solid/stripe/number legibly at small board sizes. Pick one before implementing; they imply different change surfaces (asset catalog vs `MVEngineBuilder.swift`).
- **Name collision risk (asset approach).** Imagesets named `0`–`15` are bare numeric names; confirm Xcode accepts them and that nothing else in the catalog or `Image(...)` call sites resolves a bare digit to the wrong asset.
- **Dependency ordering.** End-to-end "place from Library" verification needs TASK-059 (Pool tab) landed. If TASK-059 is not yet merged, verify via the `REDESIGN_SMART=1` seed / direct `ManagedView` placement so this task can be validated independently.
- **`EmptyText()` default still swallows mis-wiring.** This task fixes Pool specifically; it does not add the DEBUG unknown-tool placeholder (audit LOW). Worth a follow-up so the next missing-asset case isn't invisible too.

## Outcome (2026-06-27) — DONE (build verified)
Instead of adding 16 binary assets, PoolBallTool.Build now renders the existing drawn PoolBallIcon(ballType:) (already used by BuildIcon) instead of the missing Image(name) — so pool balls draw (number + solid/stripe colour) rather than rendering invisible.
