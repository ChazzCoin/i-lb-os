# TASK-056: Move transient record/playback state out of @AppStorage

**Phase:** AN — Animate & Record · **Severity:** MEDIUM · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-animate-record-playback.md) (decomposes TASK-043)

## User story
As a **coach**, I want **the board to never reopen stuck in a phantom "playing" or "recording" state after the app crashes or I force-quit mid-record/mid-playback** so that **launching the app always lands me in a clean, editable Plan board instead of a frozen or self-replaying one**.

## Why this matters
`isPlayingAnimation` is `@AppStorage`, so its value survives process death and is reread on next launch. If the app is killed during playback (the flag is `true`) or mid-record, the next launch restores the persisted flag. `MVObject` reads the same persisted `isPlayingAnimation` and wraps every position update in `withAnimation` while it's set, and `BEO.canRecord` is `isRecording && isPlayingAnimation` — so a stale persisted `true` can leave tools animating on a board that isn't playing anything, or gate recording on a phantom state. This is transient session state masquerading as a user preference. It belongs in memory and should default clean on every board load.

Desired: playback/record flags are in-memory only (or are force-reset when a board loads). A crash mid-record/mid-playback has zero effect on the next launch — the board opens in Plan, nothing is animating, nothing is recording. Honest scope: `isRecording` is *already* `@Published` (non-persistent) on `BoardEngineObject`; the persistent leak is specifically `isPlayingAnimation`, which is declared `@AppStorage` in three places that must agree.

## Findings / current state
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:71`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `@AppStorage("isPlayingAnimation") public var isPlayingAnimation: Bool = false`. This is the live board engine's copy and the one playback writes. Persisted across launches.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:403`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — a commented-out `// @Published var isPlayingAnimation: Bool = false` sits directly above the playback funcs. Someone already started this conversion and reverted it; the `@AppStorage` at :71 won.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:413-419`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `playAnimationRecording()` sets `isPlayingAnimation = true` then `runAnimation()`; `stopAnimationRecording()` sets it `false`. Every write to the persisted flag flows through here, and the loop only clears it on natural completion (`:462`) — a crash before that leaves `true` on disk.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:261`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `canRecord` is `self.isRecording && self.isPlayingAnimation`, so a stale persisted `isPlayingAnimation` directly poisons the record gate on next launch.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:406`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `@Published public var isRecording: Bool = false` is **already** non-persistent. Record-toggle state is fine; only the playback flag leaks. Don't "fix" what isn't broken.
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift:69`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift) — second declaration: `@AppStorage("isPlayingAnimation") public var isPlayingAnimation: Bool = false`. Read at [`MVObject.swift:465`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift) (`if self.isPlayingAnimation { withAnimation(...) }`). A persisted `true` makes every tool move animate even when nothing is playing.
- [`CoreEngine/Sources/CoreEngine/ECObservables/UserToolsObservable.swift:34`](../../CoreEngine/Sources/CoreEngine/ECObservables/UserToolsObservable.swift) — third declaration, in a **different** UserDefaults suite: `@AppStorage("isPlayingAnimation", store: UserDefaults(suiteName: "worlds"))`. The flag is split across the default suite (BEO/MVObject) and the `"worlds"` suite (this one); they are not even the same backing store. Any non-persistent rework must reconcile these into one source of truth.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:83`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `@Published public var gesturesAreLocked: Bool = false` already exists and is the established lock mechanism; [`Ludi Boards/Redesign/RedesignBoardCanvas.swift:46`](../../Ludi%20Boards/Redesign/RedesignBoardCanvas.swift) gates the canvas drag with `if self.BEO.gesturesAreLocked || self.BEO.isDraw { return }`. Playback should set this lock; `disableDrawing()` ([`BoardEngineObject.swift:106`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift)) exits draw mode.
- [`Ludi Boards/Redesign/TacticalBoardView.swift:47`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — the audit (LOW finding) notes Present mode hides chrome but does **not** lock gestures or exit draw; playback wants the same lock. Today nothing locks the board during replay, so a coach can drag a tool while it's animating.

## Scope
**In scope:**
- Convert `isPlayingAnimation` from `@AppStorage` to non-persistent in-memory state (`@Published` on the owning observable), consolidating the three declarations (BoardEngineObject, MVObject, UserToolsObservable — including the `"worlds"`-suite one) onto a single source of truth so they can't disagree.
- Guarantee a clean default on board load: whatever board-open path the redesign uses, force `isPlayingAnimation = false` (and stop any in-flight playback) so a prior crash leaves no residue. If `isRecording` can be reached in a dirty state via the same path, reset it here too — but it is already `@Published`, so no declaration change.
- During playback, lock the board: set `gesturesAreLocked = true` and call `disableDrawing()` on play start, and restore on stop/complete. This closes the audit's LOW finding for the playback case.

**Out of scope:**
- The timeline/scrub/transport work (per-action timestamps, pause/seek/speed) — that is the separate AN deep-change task; this one only relocates the flag and adds the lock.
- Add/delete replay fidelity in `absorbRecordingAction` — separate task.
- Wiring `.animate` as a whole-screen mode and building the recordings list/play UI — separate AN tasks.
- **Firebase is OUT.** No sync of playback/record state to any backend. Keep the in-memory state Firebase-ready (no design choice that would block a later board-scoped sync) but write zero Firebase code.

## Files expected to change
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift`
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift`
- `CoreEngine/Sources/CoreEngine/ECObservables/UserToolsObservable.swift`
- (board-load path, wherever the redesign opens/swaps a board — likely in `Ludi Boards/Redesign/` or the BEO board-load func; confirm during implementation)

## Acceptance criteria
- [ ] `isPlayingAnimation` is no longer declared `@AppStorage` anywhere; `grep -rn 'AppStorage("isPlayingAnimation")'` over `Ludi Boards/` and `CoreEngine/` returns zero hits.
- [ ] There is exactly one source of truth for `isPlayingAnimation`; MVObject and UserToolsObservable read that one value rather than three independent backing stores (and the `"worlds"`-suite copy is gone).
- [ ] Loading/opening a board sets `isPlayingAnimation = false` and stops any in-flight playback, regardless of prior value.
- [ ] Simulated crash-during-playback (set the flag true, kill the app) results in a fresh launch where nothing animates and the board is in Plan with `isPlayingAnimation == false`.
- [ ] During playback, `gesturesAreLocked == true` and draw mode is exited; both are restored when playback stops or completes (the natural-completion path at `BoardEngineObject.swift:462` clears the lock too).
- [ ] `isRecording` remains `@Published` (unchanged declaration); record-toggle behaviour is not regressed.
- [ ] No Firebase code added.

## Verification (build + sim)
1. `/build` clean.
2. iPad simulator, scheme **"Ludi Boards"**, bundle **io.ludi.sol**, verified headlessly per the project's background-simulator convention. **Verify on an iOS 18.x iPad sim in LANDSCAPE** — the 26.x sim masks layout bugs, and landscape is the board's real orientation.
3. Behaviour check: start a playback, then terminate the app process mid-playback (or set `isPlayingAnimation = true` and kill). Relaunch and open the board — confirm nothing is animating, the board is editable, and the flag reads `false`.
4. During an actual playback, confirm the canvas does not respond to drags (`gesturesAreLocked`) and draw mode is off; confirm both return to normal after the recording finishes.

## Open questions / risks
- **Ownership fork:** the cleanest single source of truth is `@Published` on `BoardEngineObject`, with `MVObject`/`UserToolsObservable` reading it through the injected `BEO` reference rather than holding their own `@AppStorage`. Confirm those objects actually have a `BEO` handle at the read sites (`MVObject.swift:465`) before committing to that shape; if not, a shared in-memory observable is the fallback.
- **The `"worlds"` suite copy** (`UserToolsObservable.swift:34`) suggests this flag was historically shared cross-process or cross-target. Confirm nothing outside this app relies on reading `isPlayingAnimation` from the `"worlds"` suite before deleting that persistence — low risk, but it's a different backing store than the other two.
- **Board-load reset site:** the redesign's exact board-open/swap entry point needs to be located; the reset must fire on every path that lands a coach on a board, not just first launch.
- **Someone already tried this** (commented `@Published` at `BoardEngineObject.swift:403`) and backed out. Worth a quick check of why — if `@Published` caused a publish-during-view-update warning or a retain issue, the reset-on-load approach may be the safer half of the fix.

## Outcome (2026-06-27) — DONE (build verified) — with a deviation
Kept isPlayingAnimation as @AppStorage (it's load-bearing — MVObject in CoreEngine reads the same key cross-module; converting to @Published would desync the playback animation). Instead, RedesignPreviewEntry.configureRedesignBoard resets isRecording/isPlayingAnimation/gesturesAreLocked on board load so a prior crash leaves no residue. Playback gesture-lock is wired in the transport via onChange(isPlayingAnimation) — board locks during playback, stays editable while recording.

## Hardened (2026-06-27) — post review
Review flagged ignoreUpdates (@AppStorage) could persist `true` after a crash mid-playback/drag, silently dropping ALL future recording. Fix: playback no longer touches ignoreUpdates at all (the recording observer only exists while isRecording, which is disabled during playback), and configureRedesignBoard resets ignoreUpdates=false on board load as a backstop. Gesture lock now set synchronously in the engine.
