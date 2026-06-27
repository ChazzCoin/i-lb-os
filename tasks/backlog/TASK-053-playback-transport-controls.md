# TASK-053: Playback transport controls (play / pause / restart) wired to the engine

**Phase:** AN — Animate & Record · **Severity:** HIGH · **Depends on:** TASK-051, TASK-052 · **Source:** [audit](../../docs/audits/2026-06-26-animate-record-playback.md) (decomposes TASK-043)

## User story
As a **coach**, I want **a play / pause / restart control in Animate mode that actually drives the recorded animation** so that **I can replay a captured sequence to my players on demand, instead of pressing Record and having nothing ever play back**.

## Why this matters
The engine can already replay a recording — `playAnimationRecording()` exists and works — but on the live board it is **dead code**. Its only caller was the retired `BoardSettingsToolBar`; the redesign's `EngineControlPill` kept only the record toggle and dropped every play affordance. So a coach can capture a recording and there is no button anywhere that plays it. `.animate` is a dead enum case that renders the default Plan screen. Desired: tapping Animate switches the whole screen into a record/playback surface, and a transport (play, pause/resume, restart) for the selected recording calls `BEO.playAnimationRecording()` / `BEO.stopAnimationRecording()`, with the engine's `isPlayingAnimation` flag surfaced into `BoardScreenState` so the UI reflects whether something is playing. This reconnects the orphaned play path and replaces the dead caller.

## Why this matters

## Findings / current state
- [`Ludi Boards/Redesign/Models.swift:61-62`](../../Ludi%20Boards/Redesign/Models.swift) — `EditorMode` is `plan / animate / present`. `.animate` exists in the enum but no code branches on it; selecting it changes nothing on screen.
- [`Ludi Boards/Redesign/TacticalBoardView.swift:47`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — the entire mode→screen relationship is one boolean: `let presenting = state.mode == .present`, and `if !presenting {` (line 56) gates the rail / right panel / context toolbar / control pill. There is no `.animate` branch and no playback-state plumbing. This is the seam Animate must hook, mirroring how `.present` flips the chrome.
- [`Ludi Boards/Redesign/BoardScreenState.swift:31`](../../Ludi%20Boards/Redesign/BoardScreenState.swift) — `@Published var mode: EditorMode` is the source of truth for mode, but the state object holds **no playback state** (no selected recording id, no is-playing). The UI cannot reflect play state today because nothing observable carries it.
- [`Ludi Boards/Redesign/Components.swift:402-421`](../../Ludi%20Boards/Redesign/Components.swift) — `EngineControlPill` (struct at :402) wires exactly one action: `onRecord: { BEO.isRecording ? BEO.stopRecording() : BEO.startRecording() }` (:418). No play, no pause, no restart, no recordings selection.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:413-418`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `playAnimationRecording()` sets `isPlayingAnimation = true` then calls `runAnimation()`; `stopAnimationRecording()` (:417) sets the flag back to `false`. **This is the play path the transport must drive.** It is currently orphaned on the live board.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:421-473`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `runAnimation()` steps `RecordingAction`s back onto live tools on a dispatch loop with fixed ~0.5–1s delays, bailing early at each step when `!isPlayingAnimation`. One-shot start→finish; clearing the flag (via `stopAnimationRecording()`) is what halts it. Sets `isPlayingAnimation = false` (:462) when the loop completes.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:71`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `@AppStorage("isPlayingAnimation") public var isPlayingAnimation: Bool = false`. The flag is **persistent** — a crash/quit mid-playback leaves a stale `true` on next launch. (Hardening this is the audit's MEDIUM at :71; see risks.)
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:388`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `recordingsByActivity` returns the board-scoped `RecordingAction` rows; this is how the transport identifies what to replay.
- [`CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift) — `Recording` + `RecordingAction` are `orderIndex`-sequenced snapshots with **no timestamps**. Transport here is play/pause/restart only; true scrub/seek needs a time model that does not exist yet (out of scope, see TASK on timeline).
- [`CoreEngine/.../Models/ManagedView.swift:112`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift) — `absorbRecordingAction(...)` replays geometry/colour only; it does **not** add or remove tools. Replay fidelity for add/delete is a separate finding and is out of scope here.

## Scope
**In scope:**
- Surface `BEO.isPlayingAnimation` into `BoardScreenState` (an observable `isPlaying` mirror) so the transport UI reflects play state without reading `@AppStorage` directly from the view.
- A transport control set in Animate mode: **Play** (calls `BEO.playAnimationRecording()` for the selected recording), **Pause/Resume**, and **Restart** (stop + replay from the first `orderIndex`).
- Drive **stop** via `BEO.stopAnimationRecording()`; pause must halt the running `runAnimation()` loop (it already bails when `isPlayingAnimation` is false).
- The Animate toggle switches the **entire screen** into record/playback mode: Plan chrome (rail, Library, Squad, draw tools) hidden; only the animation / record / playback surface visible. Mirror the `presenting` gate at `TacticalBoardView.swift:47` with an `.animate` branch.
- Play/restart act on a single selected recording (the one surfaced by TASK-052's recordings list); if no recording is selected, the transport is disabled, not crashing.

**Out of scope (Firebase-ready only — Firebase OUT everywhere):**
- Scrub / seek slider and any per-action timestamp / timeline model (the models are `orderIndex`-only; deferred).
- Replay fidelity for tool add/delete (`ManagedView.absorbRecordingAction` geometry-only limitation).
- The recordings list / load UI itself (TASK-052) and the record-capture path (TASK-051).
- Moving `isPlayingAnimation` off `@AppStorage` permanently — note it as a risk; do the minimal reset-on-load if it blocks correct behavior, but the full migration is its own task.
- Any Firebase sync of recordings — local Realm only. Keep `Recording`/`RecordingAction` board-scoped and denormalised so they stay Firebase-ready, but wire nothing to Firebase.
- Speed control, looping.

## Files expected to change
- `Ludi Boards/Redesign/TacticalBoardView.swift` — add the `.animate` whole-screen gate alongside the `presenting` check.
- `Ludi Boards/Redesign/Components.swift` — the transport control view (play / pause / restart), wired to `BEO`.
- `Ludi Boards/Redesign/BoardScreenState.swift` — surface `isPlaying` (mirror of `BEO.isPlayingAnimation`) and the selected-recording reference the transport acts on.
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` — only if pause/resume needs a method beyond `play`/`stop`, and minimal reset-on-board-load for the stale `isPlayingAnimation` flag if it interferes.

## Acceptance criteria
- [ ] Selecting **Animate** hides all Plan chrome (rail, Library, Squad, draw tools) and shows only the animation/record/playback surface — Plan and Present screens are unaffected.
- [ ] With a recording selected, **Play** calls `BEO.playAnimationRecording()` and the recorded tools animate to their captured positions on the board.
- [ ] **Pause** halts the running animation (the `runAnimation()` loop stops advancing); **Resume** continues playback.
- [ ] **Restart** replays the selected recording from the first `orderIndex`.
- [ ] The transport reflects engine state: the Play control shows playing vs. stopped from `BoardScreenState.isPlaying` (mirroring `BEO.isPlayingAnimation`), not a local-only guess.
- [ ] When playback reaches the end, `isPlayingAnimation` returns to `false` and the transport returns to its idle/play state automatically.
- [ ] With no recording selected, the transport is disabled and does not crash.
- [ ] `playAnimationRecording()` now has a live caller; the dead-code path from the retired `BoardSettingsToolBar` is no longer the only one (no revival of `BoardSettingsToolBar`).
- [ ] Firebase is untouched; recordings remain local Realm and board-scoped.

## Verification (build + sim)
1. `/build` clean — no warnings introduced in the touched files.
2. Headless iPad simulator per the project's background-simulator convention: scheme **"Ludi Boards"**, bundle **io.ludi.sol**. Build, install, and launch on the sim without attaching a window.
3. **Verify on an iOS 18.x iPad simulator in LANDSCAPE** — the 26.x sim masks layout bugs in the Animate chrome swap, so 18.x landscape is the gate.
4. On a board with at least one recording: switch to Animate (confirm Plan chrome is gone), select a recording, Play (confirm tools animate), Pause/Resume, Restart, and let it run to completion (confirm the transport returns to idle). Confirm Plan and Present modes are unchanged.

## Open questions / risks
- **Stale `isPlayingAnimation` (`BoardEngineObject.swift:71`).** It is `@AppStorage`-persisted; a crash mid-playback persists `true`. If this surfaces as a transport stuck in "playing" on launch, do a minimal reset-on-board-load here; the full migration off `@AppStorage` is a separate (audit MEDIUM) task — do not scope-creep into it.
- **Pause semantics on a dispatch loop.** `runAnimation()` is a fire-and-forget dispatch chain that bails when `isPlayingAnimation` is false. "Pause" likely means clear the flag (halt) and "Resume" means re-enter the loop — but resume-from-current-position needs the loop to remember where it was. If the existing loop can't resume mid-sequence, decide: pause==stop+restart-on-resume (cheap, acceptable for v1) vs. add a resume cursor (more engine work). Pick before implementing.
- **Selected-recording source.** This task assumes TASK-052 provides the selected recording into `BoardScreenState`. If TASK-052 hasn't landed the selection model, agree the minimal shared field (e.g. `selectedRecordingId`) so the two tasks don't define it twice.
- **`@AppStorage` vs `@Published` mirror.** Surfacing `isPlayingAnimation` into `BoardScreenState` means two sources of truth (the AppStorage flag the engine writes, and the published mirror the UI reads). Keep the engine flag authoritative and mirror one-way into state to avoid feedback loops.
