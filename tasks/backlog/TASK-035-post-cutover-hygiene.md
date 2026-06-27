# TASK-035: Post-cutover hygiene: RedesignPreviewEntry framing + Library entry affordance

**Phase:** SQ — Squad / Roster · **Severity:** LOW · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-squad-add-player-drawer.md)

## User story
As a **coach**, I want **a discoverable way to open the Library and a codebase that describes itself honestly** so that **I can find the tool library without hunting for a stray toggle, and the next contributor isn't misled by a file header that lies about what the file is**.

## Why this matters
`RedesignPreviewEntry.swift` was the redesign's throwaway preview/harness host before RD-6. At the RD-6 cutover it became the live root, but its header still says "NOT the app's @main" and "Removed at RD-6 cutover." That framing is now false — the file is the shipping entry, and anyone reading it cold will draw the wrong conclusion about whether it's safe to delete or touch.

Separately, the only production way to open the Library drawer is the bottom-right "Library" capsule button — a leftover from the DEBUG state-switcher, not a deliberate piece of chrome. It sits next to a `#if DEBUG` "Clear" button, styled as a debug affordance. There is no rail or top-bar entry for the Library, so the Library's discoverability rests entirely on a control that was never designed to be the production entry point. Neither issue is a bug; both are post-cutover debt that reads as broken to a fresh set of eyes.

## Findings covered
- [`Ludi Boards/Redesign/RedesignPreviewEntry.swift:5`](../../Ludi%20Boards/Redesign/RedesignPreviewEntry.swift) — header still reads "Isolated entry for the redesigned board. NOT the app's @main … Reached in the running app via a DEBUG affordance … Removed at RD-6 cutover." The file is now the live root (it was promoted at the RD-6 cutover — commit `b97cba6`). Fix: rewrite the header to state plainly that this is the live tactical-board root, drop the "NOT @main" and "Removed at RD-6 cutover" lines, and keep an accurate note about the render harness / source provenance.
- [`Ludi Boards/Redesign/RedesignPreviewEntry.swift:117`](../../Ludi%20Boards/Redesign/RedesignPreviewEntry.swift) — the only production entry to the Library drawer is the bottom-right `Button(state.libraryOpen ? "Done" : "Library") { state.toggleLibrary() }` inside `stateSwitcher`, sitting beside a `#if DEBUG` "Clear" button. It's a debug-switcher leftover with no rail/top-bar affordance. Fix: either (a) give the Library a real chrome affordance (rail or top-bar button) and demote/remove the floating toggle, or (b) consciously keep the toggle as the production entry and document that decision in the header + remove the "debug switcher" framing so it doesn't read as accidental.

## Scope
**In scope:**
- Correct the `RedesignPreviewEntry.swift` file header so it describes the file's actual post-cutover role.
- Resolve the Library entry affordance: add a deliberate chrome entry, or formally keep + document the existing toggle.

**Out of scope:**
- The roster / squad work (TASK-028..032), the team-entity decision (TASK-033), and the migration block (TASK-034 — no code action now).
- The `BoardScreenState.panel` priority chain — it is sound; do not touch the state machine.
- Any redesign of the Library drawer contents itself.

## Files expected to change
- `Ludi Boards/Redesign/RedesignPreviewEntry.swift`
- (only if option (a) is chosen) `Ludi Boards/Redesign/Components.swift` — for a top-bar/rail Library affordance.

## Acceptance criteria
- [ ] The `RedesignPreviewEntry.swift` header no longer claims the file is "NOT the app's @main" or that it was "Removed at RD-6 cutover"; it states the file is the live tactical-board root.
- [ ] The header still accurately notes the render-harness usage and the design-handoff source, if those remain true.
- [ ] The Library is reachable in a Release build via a deliberate affordance — either a new rail/top-bar control, or the existing toggle explicitly documented as the intended production entry (no longer framed as a debug switcher).
- [ ] If the floating toggle is kept, the surrounding `stateSwitcher` comment/framing is updated so it no longer reads as a debug-only leftover; if it is replaced, the toggle is removed from the production (non-DEBUG) path.
- [ ] No behavior regression: the `#if DEBUG` "Clear" button and the panel state machine still work.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim — scheme "Ludi Boards", bundle `io.ludi.sol`: in a Release config, confirm the Library drawer can be opened from chrome (or the documented toggle), opens to the library panel, and "Done" / re-tap closes it back to the Squad panel. Confirm the file header reads correctly on inspection.

## Open questions / risks
- Affordance fork: a real rail/top-bar Library button is the right long-term answer but touches `Components.swift` chrome and is a visual decision; keeping the toggle is zero-risk but leaves a debug-shaped control in production. Pick one before implementing — they imply different change surfaces.
- Low blast radius, but `RedesignPreviewEntry.swift` is the live root — header-only edits are safe; any change to `stateSwitcher` must preserve the existing toggle behavior and the DEBUG "Clear" path.
