# TASK-038: Sync Properties close (X) with clearing the tool selection anchors

**Phase:** FB — Functional board · **Severity:** HIGH · **Size:** small · **Depends on:** TASK-021, TASK-004 · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **the tool's selection ring to disappear the moment I press the X to close the Properties panel** so that **the board never shows a tool ringed as "selected" while its Properties are gone — the panel and the on-canvas selection stay in sync.**

> Verbatim: "When I press the X to close Properties, it must also remove the circle anchors on the tool itself — both should be in sync."

## Why this matters
Closing Properties and clearing the on-canvas selection are conceptually one action, but today they are wired through two layers that can fall out of step. The X button's `onClose` only calls `state.clearSelection()` ([Panels.swift:519](../../Ludi%20Boards/Redesign/Panels.swift)), which nils the UI-side `state.selectedToolId` and hides the panel. The lime selection ring, however, is rendered by the engine keyed on the shared `selectedManagedViewId` AppStorage key ([ManagedToolView.swift:118](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/ManagedToolView.swift) / [MVObject.swift:73](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift)). Those two are only reconciled by a one-directional bridge in `RedesignPreviewEntry` ([RedesignPreviewEntry.swift:70-72](../../Ludi%20Boards/Redesign/RedesignPreviewEntry.swift)). The result the user is reporting: the panel closes but the ring lingers. The desired state is that pressing X clears **both** layers in the same action so the ring vanishes with the panel, every time.

## Findings / current state
- [`Ludi Boards/Redesign/Panels.swift:519`](../../Ludi%20Boards/Redesign/Panels.swift) — the Properties X button is wired as `onClose: { state.clearSelection() }`. It clears only the UI-side selection (`state.selectedToolId`) and never touches the engine's `selectedManagedViewId`. This is the close action the user is pressing; it owns the close but only clears one of the two layers. **Change:** have `onClose` clear the engine selection too (write `""` to the `selectedManagedViewId` AppStorage key), so both layers drop synchronously on the same tap.
- [`CoreEngine/.../ManagedToolView.swift:117-130`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/ManagedToolView.swift) — the lime selection ring (TASK-004) renders only `if MVO.selectedManagedViewId == viewId`. So the ring is gated purely on the engine key — clearing `selectedManagedViewId` to `""` is sufficient and necessary to make the ring disappear. Nothing changes here; this is the consumer the fix must satisfy.
- [`CoreEngine/.../MVObject.swift:73`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift) — `selectedManagedViewId` is an `@AppStorage("selectedManagedViewId")` property; the engine reads/writes it as plain UserDefaults state. There is no published `clearSelection()` on the engine object — selection is mutated by writing the key (see `toggleMenuWindow` at [MVObject.swift:184-201](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift), which sets/clears the key unconditionally). The fix follows the same pattern: write `""` to the AppStorage key.
- [`Ludi Boards/Redesign/RedesignPreviewEntry.swift:70-72`](../../Ludi%20Boards/Redesign/RedesignPreviewEntry.swift) — the only state→engine sync today: `onChange(of: state.selectedToolId) { if newId == nil, !engineSelectedId.isEmpty { engineSelectedId = "" } }`. This SHOULD clear the engine when the panel closes, but it is an indirect, async `onChange` reaction with a guard, and the symptom shows the ring still lingers — so the close action must not rely on this bridge alone. The bridge stays as the engine→state path (tool tap opens Properties at [line 64-67](../../Ludi%20Boards/Redesign/RedesignPreviewEntry.swift)); the fix makes the close path direct rather than waiting on this reaction.
- [`Ludi Boards/Redesign/RedesignPreviewEntry.swift:42`](../../Ludi%20Boards/Redesign/RedesignPreviewEntry.swift) — `@AppStorage("selectedManagedViewId") private var engineSelectedId: String = ""` is the existing, proven write site for the engine key from the UI side. Any UI-layer clear should reuse this exact key so the fix is consistent with the established bridge.

## Scope
**In scope:**
- Make the Properties X close action clear **both** layers synchronously: the UI `state.selectedToolId` (via `state.clearSelection()`) **and** the engine `selectedManagedViewId` (write `""` to the `@AppStorage("selectedManagedViewId")` key).
- Ensure the lime selection ring ([ManagedToolView.swift:118](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/ManagedToolView.swift)) disappears in the same frame as the panel.
- Keep the existing engine→state open path ([RedesignPreviewEntry.swift:64-67](../../Ludi%20Boards/Redesign/RedesignPreviewEntry.swift)) intact and loop-free.

**Out of scope:**
- Any Firebase wiring. Selection state is local AppStorage/UserDefaults only; do not introduce remote sync. (Firebase remains OUT everywhere — Firebase-ready, not Firebase-wired.)
- Reworking the selection bridge architecture or removing the `RedesignPreviewEntry` `onChange` paths beyond what's needed to make close synchronous.
- The legacy `anchorsAreVisible` debug anchors / `toggleMenuWindow` flow ([MVObject.swift:184-201](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift)) — the redesign ring is keyed on `selectedManagedViewId`, not `anchorsAreVisible`; do not touch the legacy path.
- Behavior of selecting a different tool (that path already routes through the engine key).

## Files expected to change
- `Ludi Boards/Redesign/Panels.swift` (the `onClose` closure at line 519 — primary fix site)
- Possibly `Ludi Boards/Redesign/RedesignPreviewEntry.swift` (only if the engine-key clear is best threaded through the bridge rather than written directly in Panels)

## Acceptance criteria
- [ ] Selecting a tool shows the lime ring and opens Properties (unchanged).
- [ ] Pressing the X in Properties closes the panel **and** removes the lime ring on the tool in the same action — no lingering ring.
- [ ] After closing via X, `selectedManagedViewId` is `""` (engine selection cleared) and `state.selectedToolId` is `nil`.
- [ ] Tapping a tool, closing with X, then tapping a different tool selects the new tool cleanly (only the new tool is ringed; no phantom ring on the previous tool).
- [ ] No selection feedback loop is introduced (selecting a tool does not immediately re-clear; closing does not re-open).
- [ ] No change to the legacy `anchorsAreVisible` path or to non-redesign selection behavior.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim — scheme **"Ludi Boards"**, bundle **io.ludi.sol**, verified headlessly per the project's background-simulator convention:
   - Place/select a tool: confirm the lime ring appears and Properties opens.
   - Press X: confirm the panel closes **and** the ring disappears together (single tap, no residual ring).
   - Repeat with a second tool to confirm selection swaps cleanly and no phantom ring remains.

## Open questions / risks
- **Where does the clear live — Panels.swift or RedesignPreviewEntry?** Recommendation: put it in `Panels.swift` `onClose` (line 519). The panel owns the close action and should synchronously clear both the UI state and the engine key in one closure, rather than depend on the async `onChange` bridge that is already in place yet leaves the ring lingering. Reuse the same `@AppStorage("selectedManagedViewId")` key the bridge uses.
- **Direct AppStorage write vs. an engine method?** There is no published `clearSelection()` on the engine; the established pattern (`toggleMenuWindow`, [MVObject.swift:184-201](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift), and the bridge at [RedesignPreviewEntry.swift:71](../../Ludi%20Boards/Redesign/RedesignPreviewEntry.swift)) is to write the AppStorage key directly. Recommendation: follow that pattern — write `""` to the key; do not add a new engine API for this small fix.
- **Guard against clearing when already nil/empty?** The existing `toggleMenuWindow` sets the key unconditionally, so an unconditional clear on close is consistent and safe. Recommendation: clear unconditionally — simpler and matches the codebase, and writing `""` to an already-empty key is a no-op for the ring.

## Outcome (2026-06-26) — DONE (build verified)
Added `@AppStorage("selectedManagedViewId") engineSelectedId` to `EnginePropertiesPanel` and made `onClose` set it to `""` before `state.clearSelection()`, so the on-canvas lime ring drops in the same action as the panel rather than relying on the async `onChange` bridge. Build clean.
