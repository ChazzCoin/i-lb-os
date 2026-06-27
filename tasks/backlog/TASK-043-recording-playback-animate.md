# TASK-043: Full recording + playback wired into the Animate tab

**Phase:** AN — Animate & Record · **Severity:** HIGH · **Size:** medium · **Depends on:** Recording + RecordingAction models stable (CoreEngine), BEO.startRecording/stopRecording/isRecording/isPlayingAnimation/recordingsByActivity all exist, ManagedView.absorbRecordingAction exists for playback state application, Redesign panel architecture (PanelShell, panel state machine) proven in squad/properties/library, EditorMode enum in Models.swift already has .animate case · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **to record every movement, tool action, add, and delete in sequence, then open a right-drawer view to browse my recordings, load one, and replay it with full playback controls and a scrub slider** so that **I can build and review animated plays from the Animate tab instead of a Record button that does nothing but flip to Stop**.

## Why this matters
The capture half of recording is real and wired: `startRecording()` snapshots all tools and the observer records every mutation as an ordered `RecordingAction`, and `playAnimationRecording()` can replay them. But none of it reaches the user. The Record button toggles `BEO.isRecording` with no visual feedback, no `.animate` mode coupling, and no panel. There is no way to see recordings, pick one, or control playback — `runAnimation()` just fires ordered actions on hardcoded ~1sec delays with no cursor, scrub, pause, or speed. A separate `SearchableRecordingsListView` exists but was never integrated into the redesign or the Animate flow. The result is exactly what the user reported: the button looks like a feature and does nothing useful. This task connects the existing engine to the redesign panel system so recording and playback are actually usable from the Animate tab.

## Findings / current state
- [`CoreEngine/.../Recording.swift:11-59`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift) — Models are stable and Firebase-ready. `Recording` (id, boardId, duration, name, details, dateCreated) and `RecordingAction` (recordingId, boardId, toolId, orderIndex, isInitialState + full ManagedView snapshot). **Exists; reuse as-is.** No model changes needed for the core feature.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:476-568`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `startRecording()` creates the `Recording`, starts a timer, and spawns an observer on `allTools`; the observer captures an initial-state snapshot (`isInitialState=true`) on start, then every add/move/rotate/delete/color/lock mutation as a new `RecordingAction` with an incrementing `orderIndex`. **Capture works.** Gap: `currentRecordingIndex` only increments — there is no playback cursor/scrub state.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:413-473`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `playAnimationRecording()` / `runAnimation()` replays the initial-state actions then the ordered actions via `ManagedView.absorbRecordingAction()`. **Playback works.** Gaps: hardcoded ~1sec delays, no pause/stop mid-playback, no scrub position, no speed control, no exposed current-index for UI binding.
- [`Ludi Boards/Redesign/Components.swift:313-331`](../../Ludi%20Boards/Redesign/Components.swift) — the Record button in `EngineControlPill` (line 329) toggles `BEO.isRecording`. **Wired but inert as UX.** Gaps: no recording-in-progress visual, no coupling to `mode == .animate` (stays `.plan`), no Stop/Play/Pause states, no scrub slider, no time/index readout.
- [`Ludi Boards/Redesign/BoardScreenState.swift:16-43`](../../Ludi%20Boards/Redesign/BoardScreenState.swift) — `RightPanel` enum is `squad / properties / library` (line 16); `panel` resolution is `libraryOpen → library`, else `selectedToolId → properties`, else `squad` (line 40-43). **Panel state machine is proven.** Gap: it is independent of `EditorMode` — nothing routes on `.animate`, and there is no `recordings` case or `recordingsOpen` flag.
- [`Ludi Boards/Redesign/TacticalBoardView.swift:126-131`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — `rightPanel` switch routes `EngineSquadPanel` / `EnginePropertiesPanel` / `EngineLibraryPanel`. **Routing exists.** Gap: no branch for the Animate/recording flow.
- [`Ludi Boards/Redesign/Panels.swift:15-31`](../../Ludi%20Boards/Redesign/Panels.swift) — `PanelShell` (header/content/footer) is the established panel shape used by squad/properties/library. **Reusable scaffold.** Gap: no `RecordingsPanel` exists.
- [`Ludi Boards/Redesign/Models.swift:61-64`](../../Ludi%20Boards/Redesign/Models.swift) — `EditorMode` already has the `.animate` case. **No enum change needed.**
- [`Ludi Boards/views/ListItems/SearchableRecordingsListView.swift:13-103`](../../Ludi%20Boards/views/ListItems/SearchableRecordingsListView.swift) — a standalone recordings browser (name/duration) already exists but is **not** wired into the redesign or Animate flow. Reference for row content; do not adopt wholesale (different shell).

## Scope
**In scope:**
- Extend [`BoardScreenState.swift`](../../Ludi%20Boards/Redesign/BoardScreenState.swift): add a `.recordings` case to `RightPanel` and a `recordingsOpen` (or equivalent) published flag; update `panel` resolution so that when `mode == .animate` and (`isRecording` or `isPlayingAnimation`), it resolves to `.recordings`, otherwise falls through to the existing squad/properties/library logic.
- Create a `RecordingsPanel` in [`Panels.swift`](../../Ludi%20Boards/Redesign/Panels.swift) using `PanelShell`: header (title + count + live REC badge/duration when recording); content (list of `BEO.recordingsByActivity` filtered to `currentActivityId`, sorted by `dateCreated` desc; each row shows name, duration, date; tap to select/load by setting the playback recording id; selected row highlighted); footer (soft-delete the selected `Recording` + cascade its `RecordingAction`s).
- Add playback controls to `EngineControlPill` in [`Components.swift`](../../Ludi%20Boards/Redesign/Components.swift): Record (red) when idle, Stop when recording, Play/Pause + scrub `Slider` (0…action count) + current-index/total + current-time/total readout when playing.
- Add the playback cursor/scrub state and the controls plumbing in `BoardEngineObject` (`playbackRecordingId`, current action index, play/pause/stop that respect a position) so the slider and pause are real, not cosmetic — including a way to seek to a slider position.
- Bind the Animate flow in [`TacticalBoardView.swift`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift): in the `rightPanel` switch, show `RecordingsPanel` for the `.recordings` resolution; optionally lock gestures (`gesturesAreLocked`) while `isPlayingAnimation`.
- Keep everything Firebase-ready (use the existing `Recording`/`RecordingAction` models and their save paths) without adding new sync wiring.

**Out of scope:**
- Any Firebase sync wiring (recordings already persist via existing model paths — do not add or change sync).
- The `Recording` / `RecordingAction` schema (stable, owned by CoreEngine — reuse as-is).
- Retiring or refactoring `SearchableRecordingsListView` (leave it; this task builds the redesign panel).
- Bonus enhancements unless trivially required: recording-name editor, pause/resume *during capture*, export to video/GIF, scrubbable action-preview timeline.
- Reworking how the observer captures actions (capture already covers add/move/rotate/delete/color/lock).

## Files expected to change
- `Ludi Boards/Redesign/BoardScreenState.swift`
- `Ludi Boards/Redesign/Panels.swift`
- `Ludi Boards/Redesign/Components.swift`
- `Ludi Boards/Redesign/TacticalBoardView.swift`
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift`

## Acceptance criteria
- [ ] In the Animate tab, starting a recording shows a clear in-progress state (red REC indicator + live duration), and the Record button reads as "Stop" while recording.
- [ ] Stopping a recording persists a `Recording` plus its ordered `RecordingAction`s and the new recording appears in the `RecordingsPanel` list for the current activity.
- [ ] The `RecordingsPanel` lists `recordingsByActivity` for `currentActivityId`, sorted newest-first, each row showing name, duration, and date; tapping a row selects/loads it and highlights it.
- [ ] Loading a recording and pressing Play replays the initial state then the ordered actions on the board via `absorbRecordingAction`.
- [ ] During playback the scrub slider tracks the current action index, Play/Pause actually pauses and resumes, and dragging the slider seeks to that action position.
- [ ] The control pill shows current action index / total and current time / total during playback.
- [ ] Deleting the selected recording from the panel footer soft-deletes the `Recording` and its `RecordingAction`s and removes the row.
- [ ] `RecordingsPanel` is reachable only via `mode == .animate` while recording or playing; when neither is active the right drawer still resolves to squad/properties/library as before.
- [ ] No new Firebase sync code is added; recordings use the existing model save paths.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless, background-simulator convention — scheme **"Ludi Boards"**, bundle **io.ludi.sol**): switch to the Animate tab, start a recording, move/add/delete a few tools, and stop. Confirm the recording appears in the `RecordingsPanel`. Select it, press Play, and confirm the board replays the captured sequence. Confirm Pause halts playback, the scrub slider tracks and can seek the action index, and the index/time readouts update. Delete the recording from the footer and confirm it disappears.

## Open questions / risks
- **Panel exclusivity in Animate mode.** Should Animate lock to the recordings panel, or still allow squad/properties? Recommendation: when `isPlayingAnimation` or `isRecording` is true, lock the drawer to `.recordings`; otherwise allow normal mode/tab selection.
- **Playback timing.** Real-time (~1 action/sec) vs instant (per-frame)? Recommendation: keep visible ~0.5sec delays and add a speed control (0.25x/0.5x/1x/2x) in the footer; this requires replacing the hardcoded delay in `runAnimation()`.
- **What counts as a discrete action.** Does the observer capture tool creation and deletion, or only property mutations? Recommendation: verified the observer already captures `isDeleted` mutations and new tools surface as `.update` modifications (drop handler at [`BoardEngineObject.swift:577-631`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) creates and saves, triggering the observer), so no extra capture work is expected — confirm during implementation.
- **In-progress recording display.** Show live name/duration or just a state badge? Recommendation: show a red "REC" indicator, live duration from the timer, and the live name if the user set one.
- **Seek correctness risk.** `runAnimation()` currently has no cursor, so adding seek means deriving board state at an arbitrary index (replay initial state + all actions up to the index). Confirm whether applying actions cumulatively from the initial snapshot is cheap enough to scrub smoothly, or whether seeking should snap-then-resume.

## Decomposed (2026-06-26)
Superseded as a single task by the 2026-06-26 animate audit
(`docs/audits/2026-06-26-animate-record-playback.md`). Split into Phase AN
tasks **TASK-051…057**: 051 whole-screen Animate mode · 052 recordings drawer ·
053 transport controls · 054 timeline+scrub · 055 faithful add/delete replay ·
056 transient-state hardening · 057 capture fidelity. Kept as the umbrella
reference; do not implement directly — work the decomposed tasks.
