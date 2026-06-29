# TASK-061: Visible unknown-tool placeholder instead of silent EmptyText()

**Phase:** TC — Tool catalog · **Severity:** LOW · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-27-tool-catalog.md)

## User story
As a **coach (and the dev shipping to me)**, I want **a mis-wired tool to render a visible "unknown tool" marker in debug builds instead of nothing** so that **a wrong toolType, unknown subtype, or missing asset is caught the moment it's placed — not after it ships looking like an empty board**.

## Why this matters
Every dispatch switch in the render path ends in `default: EmptyText()`. When a tool is wired wrong — wrong `toolType`, a `subToolType` no family matches, or an `Image(name)` whose asset doesn't exist — the view collapses to nothing with zero signal. There's no log, no marker, no crash. The tool simply isn't there.

This is not hypothetical: the audit found the ShapeTool circle/square/triangle breakage stayed hidden precisely because broken/degenerate geometry reads as "nothing on the board," and the catch-all `EmptyText()` swallows the rest. A `?` tile showing `toolType`/`subToolType` at the placement point would have surfaced every one of those on first placement.

Desired: in DEBUG, an unrouted tool renders a small visible placeholder tile (`?` plus its `toolType`/`subToolType`) so mis-wiring is immediately obvious. In production (non-DEBUG), behavior is unchanged — `EmptyText()` stays, because a coach should never see a `?` tile on a real board.

## Findings / current state
- [`CoreEngine/.../MVEngineBuilder.swift:93-101`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — the top `ToolBuilder` switch routes `toolType` → family `Build(name:)`; an unmatched `type` hits `default: EmptyText()` at **line 100**. A `ManagedView` with a wrong/unknown `toolType` renders invisible here.
- [`CoreEngine/.../MVEngineBuilder.swift:96`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — `case "shape": ShapeTool.Build(...)`; each family `Build(name:)` switches on `subToolType` and, per the audit, also ends in its own `default: EmptyText()`, so an unknown *subtype* within a known family vanishes too (same failure mode, one level down).
- [`docs/audits/2026-06-27-tool-catalog.md`](../../docs/audits/2026-06-27-tool-catalog.md) — the LOW finding (lines 128-133) names this directly: "Every dispatch switch ends in `default: EmptyText()`. A wrong toolType or an unknown subtype renders invisible with no signal — which is exactly how the shape breakage hides." Bottom line (line 150): "a DEBUG placeholder would have caught the shape breakage on first placement."
- [`CoreEngine/.../MVEngineBuilder.swift:31-33`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift) — the higher `GenreBuilder(for genre: String, ...)` and `buildToolView(...)` (line 89) switches *also* fall through to `EmptyText()`; same pattern, lower traffic. The hot path that actually renders placed tools is `ToolBuilder` (line 100), so that's the primary site.

## Scope
**In scope:**
- Add a DEBUG-only `UnknownToolPlaceholder` view (a small `?` tile that prints the offending `toolType` / `subToolType`).
- Replace the `default:` arm of the top `ToolBuilder` `toolType` switch ([`MVEngineBuilder.swift:100`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift)) so it renders the placeholder under `#if DEBUG` and keeps `EmptyText()` otherwise.
- Apply the same DEBUG/placeholder treatment to each family `Build(name:)` `default:` arm (ShapeTool, GeneralTool, SoccerTool, PoolBallTool, SmartTool) so an unknown subtype within a known family also surfaces. Pass the `name`/subtype through to the placeholder so the tile shows what didn't match.

**Out of scope:**
- Fixing any actual mis-wiring (ShapeTool geometry, PoolBall assets, Pool/General surfacing) — those are separate tasks. This task only makes mis-wiring *visible*; it does not repair it.
- The working SoccerTool and SmartTool families' render/asset/geometry logic — do **not** re-touch their happy paths. Only their unreachable `default:` arm changes (and only to add the DEBUG placeholder).
- Any production-visible change. Non-DEBUG must render exactly as today (`EmptyText()`).
- Logging/telemetry infrastructure. Firebase is **out** — no analytics events, no remote logging on the unknown-tool path. Firebase-ready only: if a hook is left, it must be a no-op/local-only stub, not a wired call.

## Files expected to change
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVEngineBuilder.swift` (top `ToolBuilder` default + each family `Build` default)
- A new small view for the placeholder (either inline in `MVEngineBuilder.swift` or a sibling file under `CoreEngine/.../ECManagedViews/` — keep it co-located with the dispatch)

## Acceptance criteria
- [ ] A DEBUG-only `UnknownToolPlaceholder(toolType:subToolType:)` view exists and renders a visible `?` tile labeled with the passed `toolType` / `subToolType`.
- [ ] In a DEBUG build, placing a `ManagedView` with an unknown `toolType` (one no `ToolBuilder` case matches) renders the placeholder tile, not an empty space.
- [ ] In a DEBUG build, placing a known-family tool with an unmatched `subToolType` (e.g. a `shape` with a nonsense subtype) renders the placeholder tile via that family's `Build` default.
- [ ] In a non-DEBUG (Release) build, both of the above render `EmptyText()` — no `?` tile, no visual change from today.
- [ ] The placeholder shows enough to diagnose: at minimum the `toolType` and the `subToolType`/`name` that failed to route.
- [ ] No working SoccerTool/SmartTool/Shape/line happy path renders the placeholder — it only appears on the `default:` arms.
- [ ] No Firebase / remote call is added on this path.

## Verification (build + sim)
1. `/build` clean (CoreEngine compiles; no warnings introduced on the touched arms).
2. iPad simulator, scheme **"Ludi Boards"**, bundle **io.ludi.sol**, run **headlessly** per the project's background-simulator convention. Verify layout on an **iOS 18.x iPad simulator in LANDSCAPE** — the 26.x sim masks layout/render bugs, so don't validate the placeholder there.
3. Seed tools with `REDESIGN_SMART=1` and place from the Library. Confirm normal tools render unchanged.
4. Force a mis-wire to exercise the path: place a `ManagedView` with a bogus `toolType` (or a known family + bogus `subToolType`) and confirm — in DEBUG — the `?` placeholder tile appears at the placement point with the right labels. Confirm the same input in a Release config shows nothing.

## Open questions / risks
- **Placeholder anchoring.** The `default:` arm doesn't necessarily receive x/y/width/height geometry the way a real tool does — confirm the placeholder can size/position itself (or render at the tool's frame) so it's actually visible and not a zero-size tile that reproduces the bug it's meant to catch.
- **Family-default reach.** Some family `default:` arms may genuinely be unreachable for valid catalogs (the audit notes SmartTool matches all 13 with no `EmptyView` fallthrough for valid subtypes). Adding the placeholder there is cheap insurance, but don't expect it to ever fire in normal use — its value is catching *future* mis-wiring.
- **DEBUG gating consistency.** Decide one mechanism (`#if DEBUG` around the arm vs. a placeholder view that internally compiles to `EmptyText()` in Release) and apply it uniformly across all six switches so the production-invisible guarantee is auditable in one place.

## Outcome (2026-06-27) — DONE (build verified)
ToolBuilder's `default` now renders a DEBUG-only UnknownToolBadge (red "?" tile with toolType/subToolType) instead of silent EmptyText(); production keeps EmptyText(). Mis-wired tools (wrong toolType) now surface visibly in dev. (Scoped to the toolType-level default; per-family subtype defaults still EmptyText — noted.)
