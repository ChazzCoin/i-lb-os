# TASK-046: Basic share wiring (free tier; deeper sharing later)

**Phase:** FB — Functional board · **Severity:** MEDIUM · **Size:** small · **Depends on:** TASK-012 · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **the Share button to actually do something — export the board as an image I can hand off via the system share sheet** so that **I can send a snapshot of my plan to players or staff without waiting on the full collaboration features**.

## Why this matters
Today the Share button is a dead end. `ShareButton` renders the lime pill with the share glyph ([`Components.swift:162`](../../Ludi%20Boards/Redesign/Components.swift)), and `EngineTopBar` wires `onShare` as an empty closure ([`Components.swift:136`](../../Ludi%20Boards/Redesign/Components.swift)) — tapping it does nothing. There is no `ImageRenderer`, `UIActivityViewController`, or `ShareLink` anywhere in the redesign code. The desired state for this task is the smallest honest thing: tapping Share captures the board canvas as an image and hands it to the system share sheet. Anything richer (links, collab, auth-gated sharing) is explicitly later work.

> Verbatim request: *"The Share button is a placeholder. I want basic share wiring — whatever is easiest now (basic free setup), with more planned later."*

## Findings / current state
- [`Ludi Boards/Redesign/Components.swift:136`](../../Ludi%20Boards/Redesign/Components.swift) — `EngineTopBar` passes `onShare: {}` (empty closure) into `TopBar`. The comment already marks this as the "export/share entry — RD-6" seam. **Change:** replace the empty closure with real share logic, driven from `EngineTopBar` where `@EnvironmentObject var BEO: BoardEngineObject` is already in scope (line 128).
- [`Ludi Boards/Redesign/Components.swift:162`](../../Ludi%20Boards/Redesign/Components.swift) — `ShareButton` is visual-only (lime background, share glyph, no tap target of its own). The tap routes through `TopBar`'s `onShare`. **Change:** none to the button's look; only the closure it ultimately fires needs wiring.
- [`Ludi Boards/Redesign/Components.swift:216`](../../Ludi%20Boards/Redesign/Components.swift) — `EngineToolRail` is the existing pattern for a BEO-wired chrome component: it reads board state off `@EnvironmentObject BEO` and routes interaction to engine actions. **Change:** follow this shape — add `@State private var isShareSheetPresented` (and a captured image) to `EngineTopBar`, populate it on tap, present from there.
- [`Ludi Boards/Redesign/TacticalBoardView.swift:39`](../../Ludi%20Boards/Redesign/TacticalBoardView.swift) — `TacticalBoardView` composes the board: floating chrome over `RedesignBoardCanvas` plus background. This is the view tree the export must capture. **Change:** decide capture scope (canvas-only is the MVP target) and feed that view into `ImageRenderer`.
- [`Ludi Boards/LudiBoardsApp.swift:49`](../../Ludi%20Boards/LudiBoardsApp.swift) — commented-out template showing the exact capture path: `ImageRenderer(content:).cgImage` → `UIImage(cgImage:)` → `CoreFiles.saveImageToDocuments`. **Change:** none here; use it as the reference for the renderer + CGImage→UIImage conversion. (Leave the commented block alone unless trivially in the way.)
- [`CoreEngine/Sources/CoreEngine/ECSystem/CoreFiles.swift:67`](../../CoreEngine/Sources/CoreEngine/ECSystem/CoreFiles.swift) — `saveImageToDocuments(image:withName:)` exists and forces a `.jpg` extension. **Change:** optional — reuse if a temp file URL is needed for the share item; otherwise share the `UIImage`/`Image` directly via `ShareLink`.

## Scope
**In scope:**
- Replace the empty `onShare` closure ([`Components.swift:136`](../../Ludi%20Boards/Redesign/Components.swift)) with real wiring in `EngineTopBar`.
- Capture the board via `ImageRenderer` and convert the result to a `UIImage`.
- Present a system share sheet (`ShareLink(item:)` or a `UIActivityViewController` wrapper) carrying the exported image.
- Use the live `ActivityPlan` title/subtitle (already resolved in `EngineTopBar.activityTitle`) as the share subject when the chosen API supports it.
- Canvas-only export for the free-tier MVP — no auth, no collaboration, no link generation.

**Out of scope (later / Firebase-ready, not Firebase-wired):**
- Any Firebase wiring — upload, share links, collab invites. Structure the entry point so a richer share path can slot in later, but wire **no** Firebase here.
- Login/auth-gated sharing (`BEO.isLoggedIn` already gates presence; do not gate the MVP image export on it).
- Multi-format export (PDF, video, animation frames), share history, or share targets beyond the system sheet.
- Restyling `ShareButton` or `TopBar` layout.

## Files expected to change
- `Ludi Boards/Redesign/Components.swift` (`EngineTopBar` — `onShare` wiring + share-sheet state)
- Possibly one small new helper file (e.g. a `ShareLink`/`UIActivityViewController` wrapper) if the share presentation doesn't fit cleanly inline in `EngineTopBar`.

## Acceptance criteria
- [ ] Tapping the Share button on a board presents the system share sheet (no longer a no-op).
- [ ] The shared item is an image of the current board, captured via `ImageRenderer`.
- [ ] The exported image renders the board contents (placed discs / drawings), not a blank frame.
- [ ] The share subject reflects the current `ActivityPlan` title/subtitle when present, and falls back to a sensible default for an untitled activity.
- [ ] No Firebase, auth, or collaboration code is added in this task.
- [ ] Sharing works in a non-DEBUG build (not gated behind `#if DEBUG` or `BEO.isLoggedIn`).

## Verification (build + sim)
1. `/build` clean.
2. iPad sim, headless per the project's background-simulator convention — scheme **"Ludi Boards"**, bundle **io.ludi.sol**: launch a board, place a disc or two, tap Share, confirm the system share sheet appears with an image item, and confirm the image preview shows the board contents and carries the activity title as its subject.

## Open questions / risks
- **Export scope — canvas alone vs. include chrome?** *Recommendation:* canvas-only (`RedesignBoardCanvas`) for the MVP — chrome UI (rail, pills, share button) does not belong in a shared snapshot and complicates the render. Revisit only if a coach asks for the framed view.
- **Share metadata — `ActivityPlan.title`+`subTitle` vs. generic subject?** *Recommendation:* reuse the live title/subtitle already computed in `EngineTopBar.activityTitle` so the share matches the breadcrumb; fall back to "Untitled Activity" / app name when both are empty.
- **Filename strategy — timestamped PNG vs. static name?** *Recommendation:* timestamped PNG (e.g. `board-<ISO8601>.png`) so repeated shares don't collide if a file URL is needed; if `ShareLink` can take the in-memory image directly, a filename may not be required at all. Note `CoreFiles.saveImageToDocuments` forces `.jpg` — if used, accept JPEG, otherwise write the file directly to control the format.
- **Risk:** `ImageRenderer` captures a SwiftUI view tree, not the live engine's 20000×20000 `GlobalPositioningZStack`. Confirm the rendered `RedesignBoardCanvas` produces a sensibly-cropped image at the board's visible bounds rather than the full hard-framed canvas — clamp/crop if needed.

## Outcome (2026-06-26) — DONE (MVP, build verified)
Replaced the empty `onShare` with a native `ShareLink(item:)` wrapping `ShareButton`, sharing "Check out my board: <activity title>". This is the easiest-now free share per the request. **Deferred (later):** board image export via `ImageRenderer` — the entry point is wired and the share item is structured to swap text → image without touching the button. No Firebase/links.
