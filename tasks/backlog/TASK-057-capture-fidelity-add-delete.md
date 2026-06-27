# TASK-057: Capture fidelity — reliable add/delete/sequence capture

**Phase:** AN — Animate & Record · **Severity:** MEDIUM · **Depends on:** TASK-055 · **Source:** [audit](../../docs/audits/2026-06-26-animate-record-playback.md) (decomposes TASK-043)

## User story
As a **coach**, I want **every tool I add, move, or delete while recording to be captured in the order I did it** so that **the playback I watch back is a faithful, sequenced reproduction of what I drew — not just whatever Realm happened to notice.**

## Why this matters
Capture is "best effort," not guaranteed. `startRecordingObserver()` attaches a single Realm collection observer to the board's `ManagedView`s; the initial-state snapshot is taken synchronously inside the observer's `.initial` callback, and from then on only `.update` *modifications* are recorded. A tool created in the window between `startRecording()` and the observer firing, or a tool inserted/removed while recording, is not turned into a `RecordingAction` at all — the `.update` branch reads only `modifications`, never `insertions` or `deletions`. Rapid batched Realm writes can also collapse or reorder into one notification, so the `orderIndex` sequence drifts from the real user sequence. Today this is partly masked because replay ignores adds/deletes anyway (TASK-055 fixes the replay side); once replay honors add/delete, any gap in *capture* becomes a visible "the tool I added never showed up" bug. Desired state: the recording is a complete, correctly-ordered log of move + add + delete, with a per-action timestamp stamped at capture time so TASK-054's timeline has real data to seek against.

## Findings / current state
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:521`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `startRecordingObserver()` is the *only* capture path. It looks up the board's `ManagedView`s and attaches one `.observe` token (`recordingNotificationToken`). Capture lifecycle is gated solely by attaching/invalidating this token.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:531`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — the `.initial(let results)` branch snapshots every current tool as an `isInitialState = true` `RecordingAction`. This runs *inside* the observer callback, asynchronously on the main queue, so any tool created between `startRecording()` (`:476`) and this callback firing races the snapshot.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:544`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — the `.update(let results, _, _, let modifications)` branch iterates `modifications` only. The `RealmCollectionChange` also carries `insertions` and `deletions` (the second and third positional args, currently discarded as `_`) — **adds and deletes are never captured as actions.** A delete is only ever seen if it surfaces later as a modification to `isDeleted` on a still-observed object, which is not guaranteed.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:549`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — sequencing is `currentRecordingIndex += 1` per modified object inside one notification; order is Realm's modification order within a batch, not user-action order. There is no per-action time offset stamped here.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:545`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `if self.ignoreUpdates { return }` is the feedback guard. Any explicit mutation-site capture added by this task must respect the same `ignoreUpdates` discipline so playback writes don't self-record.
- [`CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift) — `RecordingAction` carries `isInitialState`, `orderIndex`, and the denormalised geometry/colour/flag fields (including `isDeleted`) via `absorb(from:)`, but **no timestamp field.** There is no `actionType` (move vs add vs delete) — type is implied, not recorded.
- [`CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift:112`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift) — `absorbRecordingAction(from:saveRealm:)` (the replay consumer) copies geometry/colour/`isDeleted` only; it does not create or destroy tools. This is TASK-055's surface — listed here only to show what a captured add/delete must eventually feed into.

## Scope
**In scope:**
- Audit and prove the actual capture gaps with a reproducible recording (add a tool mid-record, delete a tool mid-record, do a fast batch of moves) and confirm what does/doesn't land as `RecordingAction` rows.
- Capture **insertions** and **deletions** reliably: either by reading the `insertions`/`deletions` index sets in the `.update` branch (`BoardEngineObject.swift:544`), or — if the observer proves lossy/mis-ordered — by capturing add/delete/move explicitly at the `ManagedView` mutation sites, gated by `ignoreUpdates`.
- Close the initial-snapshot race so a tool created in the `startRecording()`→observer-attach window is captured exactly once (in the snapshot *or* as an add, never both, never neither).
- Guarantee `orderIndex` reflects user-action order, monotonic and gap-free across a recording session.
- Add a per-action capture timestamp (time offset from `startTime`) on `RecordingAction` so TASK-054's scrub/seek has real data. Stamp it at capture time.
- Record enough to distinguish add / move / delete on replay (an `actionType` or equivalent), so TASK-055 can act on it.

**Out of scope:**
- Replay behavior — creating/removing tools on playback is TASK-055; consuming timestamps for scrub/seek is TASK-054. This task only makes capture faithful and writes the data those tasks read.
- Transport controls, recordings list, mode gating (TASK-052 / TASK-053 / TASK-056).
- Moving `isPlayingAnimation`/`isRecording` out of `@AppStorage` (separate audit MEDIUM finding).
- **Firebase: OUT.** Keep the existing `// TODO: FIREBASE` markers; new schema fields must be Firebase-ready (plain persisted scalars, board-scoped) but **no** sync code, listeners, or writes are added here.

## Files expected to change
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` — capture path: `.update` insertions/deletions, snapshot-race fix, ordering, timestamp stamping (`startRecordingObserver` ~:521, `startRecording` ~:476).
- `CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift` — `RecordingAction`: add timestamp/time-offset field and an action-type discriminator; extend `absorb(from:)` if the type derives from the source.
- Possibly the `ManagedView` add/delete mutation sites (only if explicit mutation-site capture is chosen over observer-index capture) — identify before touching; gate with `ignoreUpdates`.

## Acceptance criteria
- [ ] A recording session that adds a tool mid-record produces a `RecordingAction` for that add, replayable in order (data present even though replay lands in TASK-055).
- [ ] A recording session that deletes a tool mid-record produces a delete `RecordingAction` (not silently dropped).
- [ ] A tool created between `startRecording()` and the observer attaching is captured exactly once — never duplicated, never missed.
- [ ] `orderIndex` is monotonic and gap-free across a full session and matches the order the user performed the actions.
- [ ] Every `RecordingAction` carries a capture timestamp / time offset from the recording start.
- [ ] Add / move / delete are distinguishable on a captured action (explicit type, not inferred).
- [ ] `ignoreUpdates` still suppresses playback-originated writes from being recorded — no self-recording regression.
- [ ] No Firebase calls added; new fields are plain persisted scalars; existing `// TODO: FIREBASE` markers untouched.

## Verification (build + sim)
1. `/build` clean.
2. Headless iPad simulator per the project's background-simulator convention — scheme **"Ludi Boards"**, bundle **io.ludi.sol**. **Verify on an iOS 18.x iPad simulator in LANDSCAPE** — the 26.x simulators mask layout bugs and can mask the timing of the observer race; use 18.x.
3. With a recording active: place a new tool, move several tools quickly, then delete a tool. Stop recording and inspect the persisted `RecordingAction` rows (count, `orderIndex` sequence, action types, timestamps) — confirm the add and the delete are both present and ordered correctly, and the move batch did not collapse or reorder.

## Open questions / risks
- **Observer-index vs mutation-site capture.** Reading `insertions`/`deletions` from the existing observer is the smaller diff but inherits Realm's batching/ordering (a fast burst can still arrive as one notification with no intra-batch user order). Capturing at the mutation sites is faithful and seek-able but is more code and must find *every* add/delete path. Decide based on what the step-3 repro proves about batching — don't pick blind.
- **Timestamp source.** `startRecording()` uses `DispatchTime.now()` for duration (`:501`). Reuse that clock for per-action offsets so timestamps and `recordingDuration` share a basis; mixing `Date()` and `DispatchTime` will drift.
- **Migration.** Adding fields to `RecordingAction` is a Realm schema change — coordinate with TASK-034 (schema migration guard). Old recordings will have nil/zero timestamps; decide whether TASK-054 falls back to `orderIndex` spacing for legacy rows.
- **Initial-snapshot dedup.** Closing the race may mean snapshotting synchronously inside `startRecording()` before the token attaches, then having the observer skip the `.initial` pass — needs care so the two paths don't both write the same tool.
