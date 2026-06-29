# TASK-054: Playback timeline + scrub slider (per-action timestamps)

**Phase:** AN — Animate & Record · **Severity:** MEDIUM · **Depends on:** TASK-053, TASK-057 · **Source:** [audit](../../docs/audits/2026-06-26-animate-record-playback.md) (decomposes TASK-043)

## User story
As a **coach**, I want **to scrub a recorded animation to any moment and see a progress readout while it plays** so that **I can pause on the exact frame I'm explaining instead of re-watching the whole thing start-to-finish every time**.

## Why this matters
Playback today is one-shot. `runAnimation()` steps `RecordingAction`s onto live tools on a hardcoded dispatch loop — a 3s lead-in, then a fixed ~0.5–1s delay per action ([BoardEngineObject.swift:421-473](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift)). There is no pause, no seek, no scrub, no speed control, and no honest progress bar. It *can't* have one, because the log is sequenced by `orderIndex` (an `Int`), not by time — there is no per-action time offset to position against ([Recording.swift:27](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift)). The desired state: a real time model on the recording so the transport can show elapsed/total, a scrub slider that seeks to any moment, and a replay loop that honors a target time rather than firing on fixed wall-clock delays.

## Findings / current state
- [`CoreEngine/.../Models/Recording.swift:20`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift) — `RecordingAction` is an ordered snapshot log: `orderIndex: Int` (`:27`) sequences the rows, and `dateCreated: String` (`:28`) is a wall-clock creation stamp via `TimeProvider.getCurrentTimestamp()`. There is **no relative time offset** field — nothing says "this action happened 4.2s into the recording," so playback has no time axis to seek along. MEDIUM in the audit.
- [`CoreEngine/.../Models/Recording.swift:15`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift) — `Recording.duration: Double` exists on the header but is unused by the replay loop; it's a natural home for total recording length once the capture stamps times.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:413`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `playAnimationRecording()` just sets `isPlayingAnimation = true` and calls `runAnimation()`; one-shot, start→finish.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:421`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `runAnimation()` is a `DispatchQueue.main.asyncAfter` chain: `initialDelay = 1.0`, a `+3.0` lead-in, `+0.5` per initial-state row, then `currentDelay += 1.0` / `nextDelay += 1.0` per action. Delays are hardcoded wall-clock, not derived from recorded time. The only exit is flipping `isPlayingAnimation` to false mid-loop — there is no notion of "jump to time T".
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:71`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `isPlayingAnimation` is `@AppStorage`; there is no `playbackProgress` / `currentTime` / `targetTime` state for a slider to bind to. (Persistence of this flag is a separate MEDIUM finding; out of scope here.)
- [`CoreEngine/.../Models/ManagedView.swift:112`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift) — `absorbRecordingAction(from:saveRealm:)` replays geometry/colour onto an existing tool. This is the per-action apply that a seek must call to reconstruct state at a target time. (It does not add/remove tools — separate finding/task.)
- [`Ludi Boards/Redesign/Components.swift:402`](../../Ludi%20Boards/Redesign/Components.swift) — `EngineControlPill` only wires `onRecord` to toggle `isRecording` (`:418`). There is no play control, no scrub slider, no progress readout anywhere in the redesign transport — the surface this task adds the slider to is assumed to exist from TASK-053.

## Scope
**In scope:**
- Add a per-action **relative time offset** to `RecordingAction` (e.g. `timeOffset: Double`, seconds from recording start) so the log has a real time axis. Stamp it at capture time (the capture path is owned by **TASK-057**; this task defines the field and the seek/playback consumer).
- Populate `Recording.duration` from the last action's offset so total length is known without scanning every row.
- Add transient playback state on the engine/`BoardScreenState` — `currentTime` (or `progress` 0…1) and a `targetTime` for seeking — for the slider and readout to bind to. Keep it non-persistent.
- Add a **scrub slider + progress readout** (elapsed / total, e.g. `0:04 / 0:12`) to the Animate transport surface delivered by TASK-053.
- Make the replay honor a **target time**: seeking to T applies the latest snapshot per `toolId` at or before T (replays the prefix up to T), and resumes/plays forward from there rather than from a fixed lead-in.
- Drive playback timing from recorded offsets instead of the hardcoded `+0.5`/`+1.0` dispatch deltas.

**Out of scope:**
- **Firebase / any sync — OUT everywhere.** The new `timeOffset` field must be Firebase-ready (a plain `@Persisted` scalar on the board-scoped model, denormalised like the rest of `RecordingAction`), but no sync code is written here.
- Replaying tool **add/remove** during seek (separate audit finding / task) — seek reconstructs geometry/colour state only, matching what `absorbRecordingAction` does today.
- Moving `isPlayingAnimation`/`isRecording` out of `@AppStorage` (separate MEDIUM finding).
- The capture instrumentation that produces accurate offsets — owned by **TASK-057**; this task consumes the field and falls back to even spacing if offsets are absent.
- Speed control, loop, and the recordings-list/load UI (other AN-phase tasks).
- Migrating existing recordings that have no `timeOffset` — new field defaults to `0.0`; legacy recordings fall back to `orderIndex`-even spacing.

## Files expected to change
- `CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift` — add `timeOffset` to `RecordingAction`; ensure `absorb(from:saveRealm:orderIndex:)` carries it.
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` — time-driven replay, seek-to-time, progress/target-time state; rework `runAnimation()`/`playAnimationRecording()`.
- `Ludi Boards/Redesign/BoardScreenState.swift` — playback progress / target-time published state (if not already added by TASK-053).
- `Ludi Boards/Redesign/Components.swift` (or the TASK-053 Animate transport view) — scrub slider + progress readout, bound to the engine.

## Acceptance criteria
- [ ] `RecordingAction` has a relative `timeOffset` (seconds from recording start), `@Persisted`, defaulting to `0.0`, and it round-trips through `absorb(from:)`.
- [ ] `Recording.duration` reflects the last action's `timeOffset` after a recording is captured (length is known without rescanning rows).
- [ ] The Animate transport shows a scrub slider and an elapsed/total readout that update as playback advances.
- [ ] Dragging the slider seeks: the board reconstructs the state at the target time (latest snapshot ≤ T per `toolId`) and continues forward from there — not from a fixed 3s lead-in.
- [ ] Playback timing is derived from recorded `timeOffset`s, not the hardcoded `+0.5`/`+1.0` dispatch deltas.
- [ ] A recording captured under TASK-057's stamped path plays back at recorded pacing; a legacy recording with all-zero offsets still plays (even-spaced fallback) without crashing.
- [ ] Seeking and the progress readout introduce no persistent state — quitting mid-playback leaves no "scrub position" behind on next launch.

## Verification (build + sim)
1. `/build` clean.
2. Headless iPad simulator per the project's background-simulator convention — scheme **"Ludi Boards"**, bundle **io.ludi.sol**. Verify on an **iOS 18.x iPad simulator in LANDSCAPE** (the 26.x sim masks layout bugs):
   - Enter Animate, record a short session moving a couple of tools, stop.
   - Play it back: confirm the progress readout advances and the slider tracks.
   - Drag the slider to ~50% and confirm the board jumps to that moment's tool positions, then plays forward from there.
   - Confirm the scrub slider and readout render correctly in landscape (not clipped/overlapping the transport).

## Open questions / risks
- **Capture timing dependency (TASK-057).** This task is only as good as the offsets TASK-057 stamps. If TASK-057 isn't landed, decide whether to ship with the `orderIndex`-even-spacing fallback as the visible behavior or hold the slider behind a "real offsets present" check. Sequencing the two matters.
- **Seek cost.** Reconstructing state at time T by replaying the prefix is O(actions before T) per drag tick. For long recordings a continuous drag could thrash Realm writes — may need to debounce the seek apply, or snapshot keyframes. Measure before optimizing.
- **`dateCreated` vs `timeOffset`.** `RecordingAction.dateCreated` is a wall-clock string; tempting to derive offsets from it, but capture batching (the Realm observer fires on Realm's schedule, not the user's) makes those stamps unreliable for pacing. Prefer an explicit monotonic offset stamped at capture (TASK-057) over diffing `dateCreated`.
- **Duration source of truth.** `Recording.duration` exists but is currently unwritten — confirm nothing else already reads it before repurposing it as the playback total.

## Outcome (2026-06-27) — DONE (build verified; review pending)
RecordingAction.timeOffset added. BEO playback rewritten to be time-based + seekable: playbackTimeline() (real offsets, or even-spacing fallback for legacy timeOffset==0 recordings), seekPlayback(to:) applies the prefix state, playAnimationRecording schedules each action at its offset with a Timer advancing playbackTime. Animate transport (Components.swift) gains a scrub Slider bound to seekPlayback + an elapsed/total readout. Full play-through timing is interaction-level (on-device).

## Hardened (2026-06-27) — post adversarial review
Adversarial review (24 findings) flagged the hybrid Timer+DispatchWorkItem playback as the root of 2 CRITICAL + several HIGH issues (clock drift, double-apply, restart glitch, in-flight cancel races). Rewrote playback as a SINGLE-timer loop: one Timer is the sole clock, advances playbackTime by real wall-elapsed and applies actions via a monotonic cursor (no workitems, no rebuild on resume, pause/resume continues from cursor). Gesture lock set synchronously in play/stop (not via coalescing onChange). restart() is synchronous. deinit invalidates the timer. Known residual (acceptable): seek rebuilds the full prefix synchronously — fine for short recordings, could jank on very long ones.
