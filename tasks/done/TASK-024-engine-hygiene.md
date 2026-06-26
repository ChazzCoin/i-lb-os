# TASK-024: Engine hygiene: extract DEBUG harness + model nits

**Phase:** Tool System Hardening · **Severity:** LOW · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-tool-system.md)

## User story

As a **developer**, I want **the production board view free of test scaffolding and the engine's small model/release nits cleaned up** so that **the shared board code is honest about what ships, and a stray `print`, an overstated migration comment, or a latent center-mapping bug can't bite later**.

## Why this matters

The production board view (`BoardEngineView`) carries ~140 lines of DEBUG seed/select/smart/library-add scaffolding — a 4th drifting copy of the create logic — interleaved with shipping code, which makes the view hard to read and easy to break. A `print()` ships unconditionally in release while its peers are DEBUG-gated. And two model nits (`updateRealm` deriving center from `start`, an overstated migration comment) are latent traps that cost nothing now but corrupt or mislead the moment a future caller leans on them. None of this is user-visible today; it's debt that compounds.

## Findings covered

- [`Ludi Boards/CanvasEngine/BoardEngineView.swift:147-283`](../../Ludi%20Boards/CanvasEngine/BoardEngineView.swift) — heavy DEBUG seed/select/smart/library-add scaffolding (a 4th drifting copy of create logic) lives in the shared production board view. Fix: move the harness into a DEBUG-only helper type/file.
- [`Ludi Boards/CanvasEngine/BoardEngineView.swift:83`](../../Ludi%20Boards/CanvasEngine/BoardEngineView.swift) — an unconditional `print()` ships in release (peers are DEBUG-gated). Fix: gate it behind `#if DEBUG` or delete it.
- [`Ludi Boards/LudiBoardsApp.swift:25`](../../Ludi%20Boards/LudiBoardsApp.swift) — `schemaVersion:2` empty `migrationBlock` comment overstates Realm's guarantees (additive-only). Fix: soften the comment to state the additive-only reality.
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift:530`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift) — `updateRealm` writes `centerX/Y` from the `start` argument (latent corruption if a future caller passes `start:`). Fix: center should only come from `lifeCenterX/Y`.
- [`CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift:37`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift) — width/height are `Int` so the size slider quantises board-space (note only). Fix: leave as `Int` unless sub-unit sizing matters; record the constraint.

## Scope

**In scope:**
- Extract the DEBUG seed/select/smart/library-add harness out of `BoardEngineView` into a DEBUG-only helper type/file.
- Gate or delete the unconditional release `print()`.
- Soften the `schemaVersion:2` migration comment to the additive-only truth.
- Fix `updateRealm` so center is derived only from `lifeCenterX/Y`, never from `start`.
- Note the `Int` width/height precision constraint inline (no type change).

**Out of scope:**
- Unifying the four create paths / persistence helpers (owned by the create-path consolidation task).
- Changing `width/height` to a floating-point type (deferred — only if sub-unit sizing is ever needed).
- Any selection / Properties / roster wiring (separate tasks).

## Files expected to change

- `Ludi Boards/CanvasEngine/BoardEngineView.swift`
- `Ludi Boards/LudiBoardsApp.swift`
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift`

## Acceptance criteria

- [ ] The production `BoardEngineView` body carries no DEBUG seed/select/smart/library-add scaffolding — it lives in a DEBUG-only helper type/file.
- [ ] No stray unconditional `print()` ships in the release path of `BoardEngineView`.
- [ ] `updateRealm` no longer derives `centerX/Y` from the `start` argument; center comes only from `lifeCenterX/Y`.
- [ ] The `schemaVersion:2` migration comment states the additive-only reality rather than implying a handled migration.
- [ ] The `Int` width/height precision constraint is noted inline; no behavioural change.
- [ ] Non-DEBUG build behaviour is unchanged (the harness only ran under DEBUG before).

## Verification (build + sim)

1. `/build` clean (both DEBUG and release configurations compile).
2. iPad sim (headless ok): launch the board with the redesign live — board renders and tools place/move exactly as before; with a DEBUG build the seed/harness still runs from its new home.

## Open questions / risks

- Harness extraction is a code-move: the risk is a behavioural drift if the seed/select code relied on `BoardEngineView`'s `self`/environment. Move it as a helper that takes the same dependencies explicitly so DEBUG behaviour is byte-identical.
- The `updateRealm` center fix is latent today (no current caller passes `start:`), so it can't be exercised at runtime — verify by reading the call sites, not by a sim observation.

## Outcome (2026-06-26) — DONE (core)
Gated the stray release `print`; corrected the schemaVersion migration comment (additive-only caveat); fixed `MVObject.updateRealm` so `centerX/Y` come from the center, not the `start` arg. **Deferred (cosmetic):** extracting the DEBUG seed/select harness to a separate file (it's already `#if DEBUG`-gated). Int width/height left as-is (noted).
