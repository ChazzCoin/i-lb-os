**Target.** Animate mode + record / playback / animation setup, and the mode-switch that should drive it.
**Scope.** `Redesign/{TacticalBoardView,Components,Models,BoardScreenState,RedesignPreviewEntry}.swift`, `CanvasEngine/BoardEngineObject.swift` (recording + playback engine), `CoreEngine/.../Models/Recording.swift` + `RecordingAction.swift` + `ManagedView.absorbRecordingAction`, `CoreEngine/.../MVObject.swift` (isPlayingAnimation), legacy `views/Windows/BoardSettingsToolBar.swift` + `RecordingListView`.
**Date.** 2026-06-26

# Audit — Animate mode + record / playback

> **TL;DR.** A complete record→capture→replay engine already exists (Realm-observer capture, `Recording`/`RecordingAction` models, a timed replay loop) — but it's **orphaned**: the redesign only toggles `isRecording`, `Animate` is a dead enum case, and there is no recordings list, no play button, and no scrub anywhere on the live board. This is a wiring + mode-switch + new-UI job over a working-but-rough engine, not a new engine.

**Scope.** Mode gating (TacticalBoardView/Components/BoardScreenState), the recording engine (BoardEngineObject), the Realm models (Recording/RecordingAction/ManagedView), playback (BoardEngineObject + MVObject), legacy UI (BoardSettingsToolBar/RecordingListView)
**Lines audited.** ~900 across redesign chrome + engine + models

---

## Part 1 — Architectural breakdown

### Mode gating — one boolean, and Animate is dead

`EditorMode` (Plan/Animate/Present) lives in `BoardScreenState.mode` and is bound to the top-bar `ModeSwitch`. The *entire* mode→screen relationship is a single check:

```swift
// Ludi Boards/Redesign/TacticalBoardView.swift:47
let presenting = state.mode == .present
…
if !presenting {   // rail, right panel, context toolbar, control pill
```

`.present` hides all chrome below the top bar. `.plan` is the default (everything shown). **`.animate` does nothing at all** — no code reads `state.mode == .animate`. Tapping "Animate" switches the enum and renders the same default Squad panel. ([Models.swift:61](../../Ludi%20Boards/Redesign/Models.swift), [BoardScreenState.swift:31](../../Ludi%20Boards/Redesign/BoardScreenState.swift))

### Recording capture — Realm-observer driven

Capture is not event-by-event from the UI; it's a Realm collection observer on the board's `ManagedView`s. `startRecording()` creates a `Recording`, snapshots every current tool as `isInitialState` rows, then watches for `.update`s:

```swift
// Ludi Boards/CanvasEngine/BoardEngineObject.swift:476  (startRecording)
//   → currentRecordingId = Recording(); isRecording = true; startRecordingObserver()
// :521 startRecordingObserver(): realm.observe → .initial snapshots all tools,
//   .update writes a RecordingAction per changed tool (orderIndex-sequenced),
//   gated by `ignoreUpdates` so programmatic writes don't self-record.
```

So capture is "whatever Realm noticed changed," sequenced by `orderIndex`. `isRecording` only gates the observer's lifecycle. ([BoardEngineObject.swift:476-569](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift))

### The models — a flat snapshot log

```swift
// CoreEngine/.../Models/Recording.swift:11   Recording: id, dateCreated, boardId, duration, name, details
// RecordingAction: id, recordingId, boardId, toolId, isInitialState, orderIndex,
//   + ~22 denormalised ManagedView fields (geometry, RGBA, flags) via absorb(from:)
```

A `Recording` is a session header; `RecordingAction`s are an ordered list of full tool snapshots. Clean, Firebase-ready, board-scoped by `boardId`. ([Recording.swift:11-59](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift))

### Playback — a timed replay loop

`playAnimationRecording()` sets `isPlayingAnimation = true` and steps `RecordingAction`s back onto live tools on a dispatch loop with fixed delays; `MVObject` wraps position updates in `withAnimation` while that flag is set:

```swift
// Ludi Boards/CanvasEngine/BoardEngineObject.swift:413  playAnimationRecording()
//   → runAnimation(): for each action in orderIndex, after ~0.5–1s,
//     obj.absorbRecordingAction(from: item)  (ManagedView.swift:112)
// CoreEngine/.../MVObject.swift:465  if isPlayingAnimation { withAnimation(...) }
```

Playback is one-shot, start-to-finish. There is no pause, seek, scrub, or speed. ([BoardEngineObject.swift:413-473](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift))

### Legacy UI — the wiring the redesign dropped

The old `BoardSettingsToolBar` had the full loop: a record toggle with confirm, a recordings sheet (`RecordingListView` / `SearchableRecordingsListView`), and a (commented-out) "Load and Play" + an actions timeline. The redesign cut over to `EngineControlPill`, which kept only the record toggle and dropped everything else:

```swift
// Ludi Boards/Redesign/Components.swift:418
onRecord: { BEO.isRecording ? BEO.stopRecording() : BEO.startRecording() }
```

`playAnimationRecording()` is now **dead code on the live board** — its only caller is the retired `BoardSettingsToolBar`. ([Components.swift:402-421](../../Ludi%20Boards/Redesign/Components.swift), [BoardSettingsToolBar.swift:386-413](../../Ludi%20Boards/views/Windows/BoardSettingsToolBar.swift))

### External libraries used in this slice

| Library | Version | Used for | Docs |
|---|---|---|---|
| `RealmSwift` | 20.0.4 | `Recording`/`RecordingAction` persistence, the `.observe` capture token, live replay writes | https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/ |
| `CoreEngine` | local SPM | `ManagedView`, `MVObject`, recording models, `absorbRecordingAction` | in-repo `CoreEngine/` |
| `SwiftUI` | iOS SDK | `EditorMode`/`ModeSwitch`, chrome gating, `withAnimation` playback | https://developer.apple.com/documentation/swiftui |

---

## Part 2 — Honest assessment

### What's working

- **The capture→store→replay engine exists and is coherent** — observer-based capture, an ordered snapshot log, and a replay loop that animates tools to recorded positions. `BoardEngineObject.swift:413-569`.
- **The data model is clean and Firebase-ready** — `Recording` (header) + `RecordingAction` (ordered snapshots), board-scoped, denormalised so replay needs no joins. `Recording.swift:11-59`.
- **Capture self-protects against feedback** — `ignoreUpdates` and `lastUserId = "recorder"` stop playback writes from re-recording. `ManagedView.swift:112`.
- **The mode gate is a clean seam** — the `presenting` boolean shows the chrome architecture can flip whole-screen on a mode with one conditional; Animate can hook the same way. `TacticalBoardView.swift:47`.

### Findings

```
▌ HIGH      ·  Ludi Boards/Redesign/Components.swift:418
  Record button captures recordings the user can never see or play on
  the live board: Animate is a dead enum case, playAnimationRecording()
  is orphaned (only the retired BoardSettingsToolBar called it), and
  there is no recordings list / play / scrub anywhere in the redesign.
  Pressing Record just flips a label — exactly the "nothing happens"
  complaint. This is THE gap.
  └─ wire Animate mode to a record/playback surface; reconnect the
     engine's play path

▌ HIGH      ·  Ludi Boards/Redesign/TacticalBoardView.swift:47
  Mode→screen is a single `presenting` boolean; there is no `.animate`
  branch, no Animate RightPanel case, and BoardScreenState holds no
  playback state (currentRecordingId, isPlaying, progress). A
  whole-screen Animate mode has nowhere to live yet.
  └─ add an .animate gate + an Animate panel/state, mirroring how
     .present already flips the chrome

▌ HIGH      ·  CoreEngine/.../ManagedView.swift:112
  Playback replays geometry/colour only — absorbRecordingAction updates
  existing tools but does not add or remove them. A tool ADDED or
  DELETED mid-recording won't appear/disappear on replay (delete is
  captured as an isDeleted attribute but not honored as a hide). Replay
  is unfaithful for any session that isn't pure movement.
  └─ replay adds/deletes (create missing tools, honor isDeleted) — the
     full-functionality ask depends on this

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:421
  Playback is a fixed ~0.5–1s dispatch loop, one-shot start→finish.
  No pause/resume, no seek, no scrub, no speed — none of the controls
  the Animate target calls for. The replay also can't be positioned to
  a time because there's no time model, only orderIndex steps.
  └─ add a real timeline (per-action timestamps) + transport controls;
     this is the bulk of the new work

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:71
  isPlayingAnimation (and isRecording context) live in @AppStorage, so
  a crash/quit mid-playback or mid-record leaves a persisted "playing"/
  "recording" flag that resumes wrong on next launch.
  └─ make transient playback/record state non-persistent (@Published or
     reset on board load)

▌ MEDIUM    ·  Ludi Boards/CanvasEngine/BoardEngineObject.swift:521
  Capture trusts the Realm observer to notice tool adds/deletes, and the
  initial-state snapshot is taken synchronously just before the observer
  attaches — a tool created in that window, or rapid batched changes,
  can be mis-sequenced or missed. Capture fidelity is "best effort,"
  not guaranteed.
  └─ verify add/delete capture explicitly; consider capturing at the
     mutation sites rather than only via the collection observer

▌ LOW       ·  Ludi Boards/Redesign/TacticalBoardView.swift:47
  Present mode hides chrome but does not lock gestures or exit draw
  mode, so a "presentation" is still editable underneath. Animate/
  playback will want the same lock while replaying.
  └─ set gesturesAreLocked / disableDrawing on present + during playback
```

### Tradeoffs worth naming

The **observer-based capture** is the central design bet: it's cheap to wire (one Realm listener instead of instrumenting every tool mutation) and automatically catches anything that touches Realm — but it pays for that in fidelity, because it only sees *what Realm noticed*, in *Realm's order*, with no semantic notion of "add" vs "move" vs "delete." That's why adds/deletes don't replay cleanly. The alternative (capture explicit events at each mutation site) is more code but gives a faithful, seek-able timeline. For the "record every movement, tool action, add, delete in sequence" ask, the observer approach is the weak link.

Second: **`orderIndex` instead of timestamps.** The log is sequenced, not timed, so playback can step but can't scrub to a moment or show a progress bar honestly. A scrub slider (explicitly requested) needs a real per-action time offset, which the model doesn't store yet.

---

## Bottom line

Don't rebuild the engine — it captures and replays today. The work is three layers on top of it: (1) make **Animate a real whole-screen mode** (gate the Plan chrome off, like `.present` already does, and show an animation surface instead); (2) build the **Animate UI** the redesign never got — a recordings list (load), transport controls (play/pause/restart), and a **scrub slider**; (3) **harden the engine** for faithful replay — replay adds/deletes, add per-action timestamps so scrub/seek is real, and move the transient `isPlaying`/`isRecording` state out of `@AppStorage`. Layers 1–2 are mostly wiring to a working engine and can ship first; layer 3 (timeline + add/delete fidelity) is the deeper change and is what turns "it replays movements" into the full record/playback experience asked for. This is the right shape to decompose the existing `TASK-043` epic into the AN phase.

**Adjacent observations.** The `Recording`/`RecordingAction` models are already Firebase-ready (board-scoped, denormalised) — they slot into TASK-049's coverage audit cleanly. And the retired `RecordingListView`/`SearchableRecordingsListView` are a usable reference for the new recordings drawer; don't revive them, but copy their shape.
