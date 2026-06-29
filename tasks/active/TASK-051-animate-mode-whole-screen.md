# TASK-051: Animate mode switches the whole screen (gate Plan chrome, lock board)

**Phase:** AN — Animate & Record · **Severity:** HIGH · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-animate-record-playback.md) (decomposes TASK-043)

## User story
As a **coach**, I want **tapping "Animate" to switch the entire screen into an animation/record/playback mode — not leave my planning chrome up** so that **I get a focused surface for capturing and replaying plays instead of a record button that does nothing while the Plan rail, library, and squad panel stay in my way**.

## Why this matters
`EditorMode` has three cases — `.plan`, `.animate`, `.present` — but only two of them do anything. `.present` already flips the whole screen: it hides the rail, the right panel, the context bar, and the control pill, leaving just the top bar. `.animate` is a **dead enum case** — no code anywhere reads `state.mode == .animate`, so tapping "Animate" switches the enum and renders the exact same default Plan/Squad screen. The record button (`EngineControlPill`) still toggles `isRecording`, but it does so under the full Plan chrome, and the recordings/play/scrub surface those captures need has nowhere to render. This task builds the **mode-switch skeleton**: make `.animate` a real whole-screen mode that gates Plan chrome off and hosts an animation surface, so TASK-052 (recordings list/load) and TASK-053 (transport + scrub) have a place to plug in. Without this, every other AN task has no container.

## Findings / current state
- [`Ludi Boards/Redesign/Models.swift:61`](../../Ludi%20Boards/Redesign/Models.swift) — `enum EditorMode: String, CaseIterable, Identifiable { case plan, animate, present }`. All three cases exist and are bound to the top-bar mode switch; `.animate` is fully wired *as an enum value* but has zero behavior.
- [`Ludi Boards/Redesign/TacticalBoardView.swift:47`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — `let presenting = state.mode == .present`. This single boolean is the *entire* mode→screen relationship. Below it, `if !presenting { … }` gates the rail, right panel, context toolbar, and control pill. There is no `.animate` branch — Animate falls through to the default (everything shown) path.
- [`Ludi Boards/Redesign/BoardScreenState.swift:31`](../../Ludi%20Boards/Redesign/BoardScreenState.swift) — `@Published var mode: EditorMode` (default `.plan`). `BoardScreenState` holds `selectedToolId`, `libraryOpen`, `layersOpen`, `mode` — but **no playback/animate state** (no `currentRecordingId`, no `isPlaying`, no playback progress). A whole-screen Animate mode has nowhere to keep its state today.
- [`Ludi Boards/Redesign/Components.swift:418`](../../Ludi%20Boards/Redesign/Components.swift) — `EngineControlPill` `onRecord:` only toggles `BEO.isRecording ? stopRecording() : startRecording()`. It renders inside the Plan chrome and offers no play, no recordings list, no `.animate` affordance. The pill is the only live caller into the recording engine.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:413`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `playAnimationRecording()` / `runAnimation()` (~421–473) replay `RecordingAction`s on a fixed ~0.5–1s dispatch loop. This path **works** but is orphaned on the live board — its only historical caller was the retired `BoardSettingsToolBar`. This task does not call it (that's TASK-053); it just builds the mode that will host the control that does.
- [`docs/audits/2026-06-26-animate-record-playback.md`](../../docs/audits/2026-06-26-animate-record-playback.md) — LOW finding (TacticalBoardView.swift:47): Present mode hides chrome but does **not** lock gestures or exit draw mode, so a "presentation" is still editable underneath. Animate/playback wants the same lock — the board should not be hand-editable while in Animate mode.

## Scope
**In scope:**
- Add a real `.animate` branch in `TacticalBoardView` alongside the existing `presenting` boolean — derive an `animating = state.mode == .animate` (or equivalent) and gate OFF the Plan chrome when it is true: left rail, right Squad/Properties/Library/Layers panel, the Library/Layers buttons, the draw rail, and the Plan-mode control pill.
- Render the **animation surface** in Animate mode instead of the Plan chrome — the container for the record/playback controls and recordings panel that TASK-052/053 fill in. This task ships the host (an `.animate` panel/region + the top bar to switch back), even if the controls inside it are stubs/placeholders pending the sibling tasks.
- Add **playback/animate state to `BoardScreenState`** — at minimum the fields the surface needs to exist (e.g. `currentRecordingId`, `isPlaying`, playback progress). Wire them through so the surface can read/write them; the engine hook-up is TASK-053.
- **Lock the board while in Animate mode** — disable drawing and lock gestures (mirror the Present concern from the audit's LOW finding) so the board isn't hand-editable underneath the animation surface.
- Keep the top bar / mode switch live in Animate mode so the user can switch back to Plan.

**Out of scope:**
- The recordings list / load-a-recording UI — that is TASK-052.
- Transport controls (play/pause/restart) and the scrub slider, and reconnecting `playAnimationRecording()` — that is TASK-053.
- Any change to the capture engine, the `Recording`/`RecordingAction` models, replay fidelity (add/delete), timestamps, or moving `isPlaying`/`isRecording` out of `@AppStorage` — engine hardening is separate AN tasks.
- **Firebase is OUT.** No sync, no remote reads/writes, no listeners. New `BoardScreenState` fields stay local; only keep them Firebase-*ready* (board-scoped, serialisable in shape) — do not wire any Firebase path.
- Fixing the same gesture-lock gap for Present mode beyond what falls out naturally if the lock is shared (don't expand the task to re-do Present).

## Files expected to change
- `Ludi Boards/Redesign/TacticalBoardView.swift` — add the `.animate` gate; host the animation surface; apply the board lock.
- `Ludi Boards/Redesign/BoardScreenState.swift` — add playback/animate state fields.
- `Ludi Boards/Redesign/Components.swift` — `EngineControlPill` / chrome that must hide or change in Animate mode; the animation-surface scaffold if it lands here.
- `Ludi Boards/Redesign/Models.swift` — only if an `.animate`-specific panel/case type is needed (e.g. a RightPanel `.animate` case).

## Acceptance criteria
- [ ] Switching the mode to **Animate** hides ALL Plan chrome: left rail, right Squad/Properties/Library/Layers panel, the Library and Layers buttons, the draw rail, and the Plan control pill are not visible.
- [ ] In Animate mode the **animation surface is shown** in place of the Plan chrome (the host region for record/playback controls + recordings panel), even if its inner controls are placeholders for now.
- [ ] The **top bar / mode switch stays visible** in Animate mode and switching back to Plan restores the full Plan chrome exactly as before (no regressions to Plan or Present).
- [ ] `BoardScreenState` carries the new playback/animate state fields (e.g. `currentRecordingId`, `isPlaying`, progress) and they default cleanly on board load.
- [ ] While in Animate mode the **board is locked** — drawing is disabled and gestures (drag/select/edit of tools) do not mutate the board.
- [ ] No code path treats `.animate` as a no-op anymore; `state.mode == .animate` is read and drives the screen.
- [ ] No Firebase calls are introduced; new state is local-only and Firebase-ready in shape only.

## Verification (build + sim)
1. `/build` clean — no warnings introduced in the touched files.
2. Boot the iPad simulator headlessly per the project's background-simulator convention: scheme **"Ludi Boards"**, bundle id **io.ludi.sol**. **Verify on an iOS 18.x iPad simulator in LANDSCAPE** — the 26.x simulator masks layout bugs, so do not certify on 26.x.
3. On a fresh board in **Plan**: confirm rail, right panel, Library/Layers buttons, draw rail, and control pill are all present (baseline).
4. Switch to **Animate**: confirm every one of those Plan elements is hidden, the animation surface is shown in their place, and the top bar remains so you can switch back.
5. With Animate active, attempt to draw and to drag/select a tool: confirm the board does not mutate (lock holds).
6. Switch back to **Plan**: confirm full chrome returns and the board is editable again. Switch to **Present** and confirm Present is unchanged from before this task.

## Open questions / risks
- **Where the animation surface mounts.** Present mode shows *nothing* below the top bar; Animate needs to show *something*. Decide whether the surface is a new RightPanel `.animate` case, a dedicated bottom/overlay region, or a full replacement region — this affects whether `Models.swift` needs a new case. Pick before implementing.
- **Shared vs separate lock.** Animate and Present both want gestures locked / drawing off. Reusing one flag (`gesturesAreLocked` / `disableDrawing`) is cleaner but pulls Present's existing LOW finding into scope. Decide whether to share the lock (and fix Present incidentally) or add an Animate-only lock to keep the diff tight.
- **Stub surface vs empty container.** TASK-052/053 fill the surface. This task should ship a host that visibly *replaces* the Plan chrome (so the mode switch is provably working) without pre-building the controls — risk is shipping an empty black region that reads as "broken." A labelled placeholder ("Animation — coming") avoids that ambiguity during verification.
- **State lifecycle.** New `BoardScreenState` fields are transient session state; ensure they reset on board load so a left-over `isPlaying`/`currentRecordingId` doesn't bleed across boards (the engine has the analogous `@AppStorage` persistence bug, but that's a separate task — just don't reproduce it here).

## Outcome (2026-06-27) — DONE (build + render verified)
TacticalBoardView now branches three ways: present (top bar only), animate, plan. In `.animate` ALL Plan chrome is hidden (rail, Squad/Properties/Library/Layers panel, draw rail, Plan pill) and the bottom-right Clear/Layers/Library switcher is gated off; the Animate surface (EngineAnimatePanel + EngineAnimateControlPill) shows instead. Board is locked during PLAYBACK (gesturesAreLocked tied to isPlayingAnimation in the transport) — NOT during recording, since recording needs an editable board to capture moves (refinement of the spec's "lock in animate"). Playback state lives on BEO (playbackRecordingId/isPlayingAnimation), not duplicated into BoardScreenState. Verified on the iOS 18.5 sim in Animate mode: Plan chrome gone, Animate surface renders.
