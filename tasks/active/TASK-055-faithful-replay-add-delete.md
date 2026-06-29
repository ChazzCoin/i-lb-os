# TASK-055: Faithful replay — honor adds and deletes during playback

**Phase:** AN — Animate & Record · **Severity:** HIGH · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-animate-record-playback.md) (decomposes TASK-043)

## User story
As a **coach**, I want **a recorded session to replay exactly what I did — including tools I added or deleted mid-recording** so that **the playback I show my players matches what actually happened on the board, not just the discs that happened to exist the whole time**.

## Why this matters
Today replay only moves tools that already exist. `runAnimation()` looks each recorded action up by `toolId` with `safeFindByField` and only acts when a matching `ManagedView` is found — so a tool that was **added** mid-recording is never created on replay, and the `isDeleted` flag is faithfully *copied* onto the live tool but nothing ever **hides or removes** it. The result: any recording that isn't pure movement replays wrong. A coach who drags in a new cone, or clears a disc, to make a point will watch a playback where that never happens. The audit flags this as a HIGH "replay is unfaithful for any session that isn't pure movement." This is an engine-level correctness bug, independent of the Animate-mode UI work — it can land on its own.

## Findings / current state
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:434`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — initial-state loop does `realmInstance.safeFindByField(ManagedView.self, value: item.toolId) { obj in obj.absorbRecordingAction(...) }`. The closure only runs when a tool with that `toolId` already exists; there is **no else branch that creates one**, so a recorded tool absent from the current board is silently skipped.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:456`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — the second (movement) loop has the same `safeFindByField`-only shape, with the same "missing tool ⇒ no-op" gap. Adds captured mid-recording never materialize here either.
- [`CoreEngine/.../ManagedView.swift:112`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift) — `absorbRecordingAction(from:saveRealm:)` writes geometry + RGBA + flags onto an **existing** `ManagedView`. Line 133 does `self.isDeleted = managedView.isDeleted` — the delete state is copied into the model but `absorbRecordingAction` does nothing to remove the tool or take it off the canvas. It is purely a field copy on a tool that is assumed to already be present.
- [`CoreEngine/.../Models/Recording.swift:20`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift) — `RecordingAction` already carries everything needed to reconstruct a tool: `toolId`, `boardId`, `isInitialState`, `orderIndex`, full geometry, `sport`/`toolType`/`toolColor`/`toolSize`, and `isDeleted` (line 51). `RecordingAction.absorb(from: ManagedView)` ([Recording.swift:64](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift)) copies all of these at capture time, so the data to re-create a missing tool is present — only the replay side fails to use it.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:521`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — capture is a Realm collection observer; the audit notes capture of adds/deletes is "best effort" (MEDIUM finding). This task assumes the action rows exist and fixes the **replay** side; capture-fidelity hardening is out of scope here.

## Scope
**In scope:**
- In `runAnimation()` (both the initial-state pass and the movement pass), when `safeFindByField` finds **no** existing `ManagedView` for a `RecordingAction.toolId`, **create** one on the current board from the action and absorb its state — so adds mid-recording appear on replay.
- Honor `isDeleted` during replay: when an action's `isDeleted == true`, the corresponding live tool must be **hidden/removed** from the canvas at that step (not merely have the flag copied), and a tool that was deleted before re-appearing must come back if a later action un-deletes it.
- A new-tool factory path on `ManagedView` (e.g. an `absorb`/create that materializes a tool from a `RecordingAction`, board-scoped by `boardId`/`toolId`), reusing the existing field-copy logic in `absorbRecordingAction`.
- Keep the recorder feedback guard intact — created/deleted tools during replay must still set `lastUserId = "recorder"` / respect `ignoreUpdates` so they don't get re-recorded.

**Out of scope:**
- The Animate-mode whole-screen UI, recordings list, transport controls, and scrub slider (separate AN-phase tasks).
- Per-action timestamps / a real timeline (the MEDIUM "orderIndex, not timestamps" finding) — replay stays the existing dispatch-delay loop here.
- Capture-side fidelity (the observer mis-sequence / missed-add MEDIUM finding) — this task fixes replay given the captured rows.
- Moving `isPlayingAnimation`/`isRecording` off `@AppStorage` (separate MEDIUM finding).
- **Firebase is OUT.** No sync, no remote writes, no listeners. New create/delete paths must be **Firebase-ready** (board-scoped, denormalised, same shape the existing models already use) but must not call Firebase.

## Files expected to change
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` — `runAnimation()`: handle the not-found case (create) and the `isDeleted` case (hide/remove) in both loops.
- `CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift` — add a create-from-`RecordingAction` path and (if needed) a remove/hide helper; keep `absorbRecordingAction` for the existing-tool update.

## Acceptance criteria
- [ ] Record a session in which a tool is **added** after recording starts; on replay that tool appears at the recorded step with the recorded geometry/colour/type (verified on a board that does **not** already contain it).
- [ ] Record a session in which an existing tool is **deleted** mid-recording; on replay that tool is visibly removed/hidden at the recorded step, not left on screen.
- [ ] A pure-movement recording still replays exactly as it does today (no regression for the existing-tool path).
- [ ] Replaying a recording onto an **empty** board (none of the recorded tools present) reconstructs all of them rather than playing back nothing.
- [ ] Tools created or removed during replay carry `lastUserId == "recorder"` (or are otherwise gated by `ignoreUpdates`) and do not get captured if a recording is somehow active.
- [ ] No Firebase calls are added; new model paths are board-scoped and denormalised (Firebase-ready only).

## Verification (build + sim)
1. `/build` clean.
2. Launch the **"Ludi Boards"** scheme (bundle `io.ludi.sol`) on an iPad simulator, verified **headlessly** per the project's background-simulator convention. **Verify on an iOS 18.x iPad sim in LANDSCAPE** — the 26.x sim masks layout bugs; 18.x landscape is the truth source.
3. On the live board: start recording, **add** a new tool, move it, then **delete** an existing tool, stop recording. Trigger playback and confirm the add appears and the delete disappears at the right steps. Repeat with a pure-movement recording to confirm no regression, and once with the recorded tools cleared from the board to confirm full reconstruction.

## Open questions / risks
- **Hide vs hard-delete on replay.** Honoring `isDeleted` could (a) set the live tool hidden so a later un-delete can restore it, or (b) actually delete the `ManagedView`. (a) is reversible within a single playback and safer; (b) matches the captured semantic but is harder to reverse mid-replay. Pick (a) unless there's a reason not to — decide before implementing.
- **Created-tool lifecycle after playback.** Tools materialized during replay are real `ManagedView` writes on the current board. Decide whether they persist after the recording finishes (matching "replay leaves the board in the recorded end state") or are torn down — and make sure that choice doesn't corrupt the user's actual board if they replay onto a live working board rather than a clean one.
- **Re-record feedback loop.** Creating/deleting tools during replay touches Realm, which is exactly what the capture observer watches. The `lastUserId = "recorder"` / `ignoreUpdates` guard must cover the new create and delete paths, or playback-while-recording could feed back into a recording.
- **`orderIndex == 0` skip.** The movement loop skips `orderIndex == 0` (treated as initial state); confirm adds/deletes are not assigned `orderIndex == 0` at capture, or they'll be dropped by that existing `continue`.

## Outcome (2026-06-27) — DONE (build verified; review pending)
RecordingAction now captures subToolType/playerId/jerseyNumber/teamSide (Recording.swift). New ManagedView.create(from:boardId:saveRealm:) materializes a tool from a snapshot (keeps the recorded id, lastUserId="recorder"). BEO.replayApply finds-or-creates the tool and absorbs; recorded isDeleted is honored by absorb copying the flag (the canvas filters isDeleted). Wired into the playback loop. Schema bumped 2→3 (additive).

## Hardened (2026-06-27) — post review
ManagedView.create(from:) now also copies toolSize + translationX/Y (review: materialized tools rendered at default size/translation). Recording observer closure given [weak self] (review HIGH retain cycle).
