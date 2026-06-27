# TASK-037: Universal object linking (players as anchors; tools attach in sequence)

**Phase:** DM — Data model & linking · **Severity:** HIGH · **Size:** epic · **Depends on:** TASK-011 (RosterPlayer model established playerId denormalisation pattern), TASK-024 (confirmed empty migrationBlock practice) · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **players to be top-level objects that lines, cones, and other tools can attach to in sequence — and, more generally, any object able to link to any other object** so that **I can build a play around a player as an anchor (a run, a passing lane, a cone gate that follows him) and have those attachments move and animate together instead of being unrelated discs that happen to sit near each other**.

> Verbatim request: "Players are top-level objects; lines, cones, etc. are tools that need to be attached in sequence to player objects. Really all objects need to be able to link to all other objects."

## Why this matters
Today the only link that exists is a **one-to-one, player-to-tool denormalisation** on the disc itself: `ManagedView` carries `playerId` / `jerseyNumber` / `teamSide` ([ManagedView.swift:54-58](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift)), set once when a jersey is placed ([Panels.swift:188](../../Ludi%20Boards/Redesign/Panels.swift)). That covers "this disc *is* that player" and nothing else. There is no way to say "this line attaches to that player," "this cone attaches to that line," or to order a set of attachments in sequence.

A linking model was sketched early — `ManagedPlayerRef` ([ManagedView.swift:11-16](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift)) with `toolId` / `playerRefId` — but it is unused: nothing creates, reads, or migrates it, and it only models player→tool anyway. There is no general object-to-object relationship in the schema.

Animation makes the gap concrete. Playback is driven by **per-tool snapshots**, not by links: `RecordingAction` copies a full `ManagedView` per frame and replays them ordered by `orderIndex` ([Recording.swift:20-59](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift); playback in [BoardEngineObject.swift:382-422](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift)). Because nothing knows that a line *belongs to* a player, the line cannot follow him — each tool animates as an island. The legacy `ManagedViewAction` ([ManagedViewAction.swift:11-42](../../Wrlds/Realm/models/ManagedViewAction.swift)) is the same snapshot shape with no link field.

Desired state: a single universal link relation with sequencing, so players can be true anchors, tools can attach to tools, and animation can (eventually) traverse links instead of replaying disconnected snapshots.

## Findings / current state
- [`CoreEngine/.../ManagedView.swift:54-58`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift) — **the only working link.** Denormalised `playerId` / `jerseyNumber` / `teamSide` on the disc, one-to-one player↔jersey. **WIRED** for that single case; cannot express tool→tool, tool→player, or ordered attachments. Change: leave these in place (placement still uses them), add a separate `ObjectLink` relation for the general case rather than overloading these fields.
- [`CoreEngine/.../ManagedView.swift:11-16`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift) — `ManagedPlayerRef` (`toolId` / `playerRefId` / `status`). **MISSING / dead.** Early link sketch, never read or written, player→tool only. Change: supersede with `ObjectLink`; decide whether to delete `ManagedPlayerRef` in this task or leave the dead type for a follow-up (a removal is non-additive — see migration note).
- [`CoreEngine/.../Recording.swift:20-59`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/Recording.swift) — `RecordingAction` captures full per-tool snapshots keyed by `orderIndex`; `absorb(from: ManagedView)` copies geometry. **WIRED but link-blind.** Change: keep snapshot capture; optionally add link hints so a future link-driven replay can follow an anchor (gated on the open question below).
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:382-422`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — playback (`recordingsByRecordingId` sorted by `orderIndex`, `runAnimation()`) replays raw snapshots; no link traversal. **WIRED for snapshot replay; MISSING link awareness.** Change: add a link-traversal path so an attached tool resolves its position relative to its anchor during playback. Behind a flag; snapshot replay stays the default until proven.
- [`Ludi Boards/Redesign/Panels.swift:162-193`](../../Ludi%20Boards/Redesign/Panels.swift) — `placedDisc` / `place(_:)` spawn a jersey `ManagedView` and set `playerId` / `jerseyNumber` / `teamSide` at placement. **WIRED for player placement only.** Change: when a player is placed, create the `ObjectLink` record(s) alongside the denormalised fields so the player is a real anchor other tools can attach to.
- [`Ludi Boards/LudiBoardsApp.swift:17-24`](../../Ludi%20Boards/LudiBoardsApp.swift) — Realm config at `schemaVersion: 2`, **empty `migrationBlock`** (additive-only practice, TASK-024). **WIRED.** Change: bump to `schemaVersion: 3`; adding the `ObjectLink` table is additive, so the block stays empty — *unless* this task also removes `ManagedPlayerRef`, which is non-additive and would require explicit handling.
- [`Wrlds/Realm/models/ManagedViewAction.swift:11-42`](../../Wrlds/Realm/models/ManagedViewAction.swift) — legacy snapshot action type, `managedViewId` + `orderIndex`, no link field. **Legacy / parallel.** Change: out of scope to modify; noted so the new `ObjectLink` is not confused with it.

## Scope
**In scope:**
- Design and add a universal `ObjectLink` Realm model: stable `id`, `boardId`, `sourceId`, `targetId`, `orderIndex` (for sequencing attachments), and an optional `linkType` field (see open questions). Both `sourceId` and `targetId` reference object ids generically (a `ManagedView.id` or a `RosterPlayer.id`) — no type coupling in the schema.
- Support the three link patterns the request implies: (1) **player-as-anchor** with tools attached in sequence, (2) **tool-to-tool** (e.g. a cone on a line), (3) a foundation for **animation-driven** playback via link traversal rather than raw snapshots.
- Schema migration v2 → v3 adding the `ObjectLink` table (additive; empty `migrationBlock` preserved per TASK-024).
- Wire [Panels.swift](../../Ludi%20Boards/Redesign/Panels.swift) `place(_:)` to create the anchor `ObjectLink` when a player is placed.
- Add the read/traverse path in [BoardEngineObject.swift](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) so attached tools can resolve position relative to their anchor (behind a flag; does not replace snapshot replay yet).
- Make the model **Firebase-ready**: documented field names + a one-line annotation of the intended Firestore mapping. No Firebase reads/writes.

**Out of scope:**
- **Any Firebase wiring** — no Firestore reads, writes, listeners, or sync of `ObjectLink`. Design the Realm model to map cleanly later; that is the only Firebase deliverable.
- Replacing snapshot-based recording/playback with link-driven animation as the default. This task lays the traversal foundation; the cutover is a separate task (the animation open question below).
- A drag-to-attach / detach UI beyond the minimum needed to create an anchor link on placement. Rich attachment gestures are a follow-up.
- Reworking the existing `playerId` / `jerseyNumber` / `teamSide` denormalisation (TASK-011) — it stays as-is.
- Touching the legacy `ManagedViewAction` snapshot type.

## Files expected to change
- `CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ObjectLink.swift` (new) — the `ObjectLink` model.
- `Ludi Boards/LudiBoardsApp.swift` — bump `schemaVersion` 2 → 3 (empty `migrationBlock` retained).
- `Ludi Boards/Redesign/Panels.swift` — create anchor `ObjectLink` in `place(_:)`.
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` — link read/traversal path for attached tools (flagged).
- Possibly `CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift` — only if `ManagedPlayerRef` is removed (decide first; non-additive).

## Acceptance criteria
- [ ] An `ObjectLink` Realm model exists with `id`, `boardId`, `sourceId`, `targetId`, `orderIndex`, and the agreed optional `linkType`, with no compile-time coupling to a specific object type.
- [ ] Realm `schemaVersion` is `3`; the app launches against an existing v2 store without wiping boards, and `migrationBlock` stays empty (or, if `ManagedPlayerRef` is removed, the non-additive change is handled explicitly and documented).
- [ ] Placing a player via `place(_:)` creates an `ObjectLink` recording that player as an anchor, in addition to the existing denormalised `playerId` write.
- [ ] A tool can be linked to a player anchor and a tool can be linked to another tool, each with an `orderIndex` reflecting attachment sequence; both round-trip through Realm (write then read back ordered by `orderIndex`).
- [ ] `BoardEngineObject` exposes a way to fetch the ordered links for a given object id, and at least one attached tool resolves its position relative to its anchor through that path (behind a flag; default board behaviour unchanged).
- [ ] No Firebase calls are added; the model carries a documented Firestore-mapping annotation only.
- [ ] Existing player placement, the denormalised disc identity, and snapshot-based recording/playback all still work unchanged.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless, background-simulator convention) — scheme **"Ludi Boards"**, bundle **io.ludi.sol**:
   - Launch against an **existing v2 board store**; confirm boards are intact (no wipe) and the app reaches the canvas.
   - Place a player from the squad panel; confirm a jersey disc appears and an `ObjectLink` anchor row is created for it.
   - Create a tool→player and a tool→tool link (via the test/dev path); confirm both read back ordered by `orderIndex`.
   - With the traversal flag on, confirm an attached tool resolves relative to its anchor; with the flag off, confirm board and animation behaviour is unchanged.

## Open questions / risks
- **Typed vs polymorphic links.** Should `ObjectLink` distinguish player-to-tool / tool-to-tool / animation-sequence, or stay generic? *Recommendation:* polymorphic — generic `sourceId`/`targetId` plus an **optional `linkType` string** for callers that want to filter. Keeps the schema future-proof and avoids a table per relationship.
- **Animation: link IDs vs snapshots.** Should `RecordingAction` reference `ObjectLink` ids directly, or keep snapshot capture with optional link hints? *Recommendation:* keep snapshot capture as the default and add **link-aware hints** only; commit to a link-driven replay cutover when the animation task (the "TASK-043"-style follow-up) requires it, not here.
- **Firebase-ready scope.** Realm model only, or also draft the Firestore schema? *Recommendation:* **Realm model + annotations only** — document the intended Firestore field mapping in comments; no Firestore code (consistent with Firebase being out of scope everywhere in this task).
- **Risk — removing `ManagedPlayerRef`.** Deleting the dead type is non-additive and breaks the empty-`migrationBlock` invariant (TASK-024). *Recommendation:* leave `ManagedPlayerRef` untouched in this task (additive v3 only) and file its removal separately so the migration risk is isolated.
- **Risk — orphaned links.** Soft-deleting a `ManagedView` (as `place(_:)` does at [Panels.swift:177](../../Ludi%20Boards/Redesign/Panels.swift)) can leave dangling `ObjectLink` rows. Decide a cleanup rule (cascade soft-delete vs filter dangling links on read) before wiring traversal.
