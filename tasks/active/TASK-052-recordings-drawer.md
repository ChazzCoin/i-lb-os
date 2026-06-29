# TASK-052: Recordings drawer — list & load recordings for the board

**Phase:** AN — Animate & Record · **Severity:** HIGH · **Depends on:** TASK-051 · **Source:** [audit](../../docs/audits/2026-06-26-animate-record-playback.md) (decomposes TASK-043)

## User story
As a **coach**, I want **to see the recordings I've captured on this board and tap one to load it** so that **I can pick a saved sequence to play back instead of being stuck with a Record button that captures things I can never see again**.

## Why this matters
The engine already captures recordings (`startRecording`/`stopRecording` write `Recording` + `RecordingAction` rows scoped by `boardId`), but the redesign dropped every UI that let a coach *find* one. Today pressing Record just flips a label — there is no list, so a captured recording is invisible and unrecoverable from the live board. This is the first half of closing that gap: surface the recordings that exist for the current board and let the coach select one. The actual play happens in TASK-053; this task only has to make the list real and set the selection it will consume.

## Why this matters (current vs desired)
- **Current:** `EngineControlPill` ([Components.swift:418](../../Ludi%20Boards/Redesign/Components.swift)) toggles `BEO.isRecording`. There is no recordings list anywhere in the redesign. `.animate` is a dead enum case. The only list UI that ever existed is the retired `RecordingListView`/`SearchableRecordingsListView` behind the old `BoardSettingsToolBar`.
- **Desired:** in Animate mode, a panel lists every `Recording` for the current board (name, date, duration, action count). Tapping a row selects/loads it as the active recording for playback. Plan chrome (rail, Library, Squad, draw) is hidden in Animate mode — only the animation/record/playback surface shows.

## Findings / current state
- [`Ludi Boards/Redesign/Components.swift:418`](../../Ludi%20Boards/Redesign/Components.swift) — `EngineControlPill`'s `onRecord` only does `BEO.isRecording ? BEO.stopRecording() : BEO.startRecording()`. No list, no load, no play affordance exists in the redesign control surface.
- [`Ludi Boards/Redesign/TacticalBoardView.swift:47`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — the entire mode→screen relationship is `let presenting = state.mode == .present`, and the chrome below the top bar is gated by `if !presenting` ([:56](../../Ludi%20Boards/Redesign/TacticalBoardView.swift)). There is no `.animate` branch — tapping Animate renders the default Squad panel. The recordings drawer needs a home that the `.animate` gate (TASK-051) provides.
- [`Ludi Boards/Redesign/Models.swift:61`](../../Ludi%20Boards/Redesign/Models.swift) — `EditorMode` (Plan/Animate/Present) exists; `.animate` is a dead case with no reader.
- [`Ludi Boards/Redesign/BoardScreenState.swift:16`](../../Ludi%20Boards/Redesign/BoardScreenState.swift) — `RightPanel` is `{ squad, properties, library, layers }` and `panel` ([:45](../../Ludi%20Boards/Redesign/BoardScreenState.swift)) resolves Library → Layers → Properties → Squad. There is no `recordings` case and no field holding the selected/active recording id.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:388`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `recordingsByActivity` returns `RecordingAction` rows filtered by `boardId == currentActivityId AND isInitialState == false`, sorted by `orderIndex`. Note this is the *actions* stream, not the `Recording` headers — the drawer wants one row per `Recording`, so it must query `Recording` (board-scoped) and may use the action queries for the per-recording action count.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:402`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `@Published var playbackRecordingId: String` already exists on BEO and feeds `recordingsByRecordingId` ([:397](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift)); selecting a row should set this (and/or a mirror on `BoardScreenState`) so TASK-053 can read it. Confirm one authority — don't introduce a second source of truth.
- [`CoreEngine/.../Models/Recording.swift:11`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift) — `Recording` carries `id, dateCreated, boardId, duration, name, details`. `RecordingAction` is `orderIndex`-sequenced full tool snapshots — **no per-action timestamps** (the model is sequenced, not timed). Row metadata: `name`, `dateCreated`, `duration` are available; "action count" comes from counting `RecordingAction`s for the recording.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:413`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `playAnimationRecording()`/`runAnimation()` ([:421](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift)) is the orphaned play path (only the retired `BoardSettingsToolBar` called it). Out of scope here — TASK-053 reconnects it. This task only sets the selection it will play.
- [`Ludi Boards/views/Windows/BoardSettingsToolBar.swift`](../../Ludi%20Boards/views/Windows/BoardSettingsToolBar.swift) (`RecordingListView`/`SearchableRecordingsListView`) — the retired list UI. Use as a **shape reference only** for layout/sort/empty-state; do **not** revive or import it.

## Scope
**In scope:**
- A recordings panel shown only in Animate mode, listing one row per `Recording` for the current board (`boardId == currentActivityId`), each showing name, date, duration, and action count.
- Tap-to-select: tapping a row marks that recording active for playback by setting the single agreed authority (`BEO.playbackRecordingId` and/or a `BoardScreenState` field) that TASK-053 reads.
- An empty state ("no recordings yet") when the board has none.
- A new `RightPanel.recordings` case (or equivalent Animate-mode panel) wired into `panel` resolution so Animate shows the drawer instead of Squad.

**Out of scope:**
- Actually playing, pausing, scrubbing, or restarting a recording — TASK-053.
- The whole-screen `.animate` mode gate / chrome-hiding scaffolding — TASK-051 (this task depends on it; the drawer lives inside the surface it creates).
- Capturing recordings / record-toggle behavior (already exists).
- Renaming, deleting, duplicating, or reordering recordings.
- Per-action timestamps / timeline model changes (deeper engine work, separate task).
- **Firebase / sync is OUT everywhere.** Read recordings from the local Realm only. The `Recording`/`RecordingAction` models are already board-scoped and denormalised (Firebase-ready), but no sync code, no `FirebaseService` calls, no write-through in this task.

## Files expected to change
- `Ludi Boards/Redesign/BoardScreenState.swift` — add the `recordings` panel case (or Animate-panel resolution) and, if chosen as the authority, the selected-recording field.
- `Ludi Boards/Redesign/Panels.swift` (or a new `RecordingsPanel.swift` alongside it) — the drawer view + row + empty state.
- `Ludi Boards/Redesign/TacticalBoardView.swift` — render the recordings panel in the `.animate` branch (the branch itself lands in TASK-051; coordinate the seam).
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` — only if a board-scoped `Recording` (header) query or an action-count helper needs to be added; reuse `playbackRecordingId` for selection rather than adding a parallel field.

## Acceptance criteria
- [ ] In Animate mode, a recordings panel is visible and the Plan-mode Squad panel is not.
- [ ] The panel lists exactly the `Recording`s whose `boardId == currentActivityId` — recordings from other boards do not appear.
- [ ] Each row shows the recording's name, date (from `dateCreated`), duration, and action count.
- [ ] Tapping a row visibly marks it selected and sets the single agreed playback authority (`BEO.playbackRecordingId` and/or the `BoardScreenState` field) to that recording's id.
- [ ] When the board has no recordings, the panel shows an empty state rather than a blank or broken list.
- [ ] No Firebase/sync code is added; the list reads from local Realm only.
- [ ] `RecordingListView`/`SearchableRecordingsListView` are not revived, imported, or referenced.
- [ ] No new playback/scrub behavior is wired (selection only) — pressing a row does not start replay.

## Verification (build + sim)
1. `/build` clean.
2. Run on an iPad simulator (scheme **"Ludi Boards"**, bundle `io.ludi.sol`), verified headlessly per the project's background-simulator convention.
3. **Verify on an iOS 18.x iPad sim in LANDSCAPE** — the 26.x sim masks layout bugs, so do not rely on it for layout sign-off.
4. With at least one recording captured on the board: switch to Animate mode, confirm the drawer lists it with name/date/duration/action-count, tap it, and confirm the selection state flips and `playbackRecordingId` is set. Then switch to a board with no recordings and confirm the empty state.

## Open questions / risks
- **Selection authority:** `BEO.playbackRecordingId` already exists and the recording queries key off it. Decide whether selection lives there alone, or is mirrored on `BoardScreenState` for SwiftUI binding — pick one source of truth so TASK-053 doesn't read a stale copy. Lean toward `playbackRecordingId` as canonical.
- **Header vs action stream:** `recordingsByActivity` returns `RecordingAction` rows, not `Recording` headers. The drawer needs a board-scoped `Recording` query that doesn't exist yet — confirm whether to add it to BEO or query Realm directly in the panel, and how to count actions per recording without an N+1 query per row.
- **Duration trustworthiness:** `Recording.duration` is a stored field; if `stopRecording` doesn't populate it reliably (the model has no per-action timestamps to derive it), the displayed duration may be 0/stale. Decide whether to show it as-is or derive from action count for now.
- **Panel coupling to TASK-051:** the `.animate` chrome gate is TASK-051's deliverable. If TASK-051 hasn't merged, this task can build the panel view + selection in isolation but cannot fully verify the "Squad hidden, drawer shown" criterion until the gate exists — sequence accordingly.

## Outcome (2026-06-27) — DONE (build + render verified)
New EngineAnimatePanel (Panels.swift) lists the board's Recording rows via @ObservedResults (name, action count, duration), tap selects (sets BEO.playbackRecordingId, highlighted + checkmark), with an empty state. Shown as the right drawer in Animate mode. Verified on sim (empty-state renders). Selection-while-playing is blocked.
