# TASK-018: Unify the four tool-creation paths (defaults + persistence)

**Phase:** Tool System Hardening · **Severity:** HIGH · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-tool-system.md)

## User story

As a **coach**, I want a tool to look and behave identically no matter how I add it — tap, drag, draw, or seed — so the board stays consistent and my tools sync the same way every time.

## Why this matters

The same tool gets different size, geometry, and colour depending on how it was created, and only one of the four paths pushes to Firebase. An equipment item tapped onto the board is 200×200 but dropped at 100×100 — same tool, different size. Tools made by tap/drag/seed never sync because they write straight to the local Realm with no push, while drawn tools do. Defaults are copy-pasted across three call sites, so any future change has to be made in three places or they drift again.

## Findings covered

- [`Ludi Boards/CanvasEngine/BoardEngineView.swift:286`](../../Ludi%20Boards/CanvasEngine/BoardEngineView.swift#L286) — DRAW writes via Firebase-synced `FusedTools.fusedCreator`; drag/tap/seed write direct to `BEO.realmInstance` with no push, so paths are not interchangeable. Fix: route every create path through one persistence helper.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:609`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift#L609) — smart-tool default geometry/colour is triplicated across `performDrop`, `addSmartTool`, and the seed. Fix: extract one factory (`ManagedView.makeSmartTool`) every path calls.
- [`Ludi Boards/Redesign/Panels.swift:560`](../../Ludi%20Boards/Redesign/Panels.swift#L560) — equipment TAP sets width/height=200 while DROP leaves the model default 100 (same tool, different size). Fix: both paths build through one factory (`ManagedView.makeEquipment`) so default size lives in one place.

## Scope

**In scope:**
- Pick ONE persistence helper for all four create paths (tap, drag, draw, seed).
- Extract ONE factory per tool category (e.g. `ManagedView.makeSmartTool`, `ManagedView.makeEquipment`) holding default geometry/size/colour; every path calls it.
- Make tap and drop produce identical equipment defaults.

**Out of scope:**
- Changing what the default geometry/size/colour values *are* (just consolidate the current intended defaults).
- Line/arrow create path styling (owned by TASK-005).
- Any new tool categories or library/rail UI changes.

## Files expected to change

- `Ludi Boards/CanvasEngine/BoardEngineObject.swift`
- `Ludi Boards/CanvasEngine/BoardEngineView.swift`
- `Ludi Boards/Redesign/Panels.swift`

## Acceptance criteria

- [ ] A smart tool created by tap, drag, draw, and seed has identical default geometry, size, and colour.
- [ ] An equipment item created by tap and by drop has identical size (no 200-vs-100 split).
- [ ] All four create paths persist through the same helper — persistence behaviour (Firebase push or not) is consistent across paths.
- [ ] Default geometry/size/colour is defined in exactly one place per tool category (no triplication across `performDrop`, `addSmartTool`, seed).

## Verification (build + sim)

1. `/build` clean.
2. iPad sim (headless ok): add the same equipment tool by tap and by drop, then by seed — all three appear at the same size/colour, and each created tool's `ManagedView` shows it went through the shared create path (consistent push behaviour).

## Open questions / risks

- Whether every path *should* push to Firebase, or whether the seed path intentionally stays local — confirm the intended single behaviour before unifying (don't silently start syncing seeded tools if that's unwanted).

## Outcome (2026-06-26) — DONE (defaults) / partial (persistence)
One factory: `RedesignToolCatalog.makeSmartTool`/`configureSmartTool` + `equipmentSize`. Tap-add, drag-drop and the seed share it; equipment tap==drop==200 now. **Deferred:** converging the persistence helper (draw uses Firebase-synced `fusedCreator`, others write direct) — latent for the free build (Firebase gated off when logged out); converge before the paid sync tier.
