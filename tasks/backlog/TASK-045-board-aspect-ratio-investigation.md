# TASK-045: Investigate the board image aspect ratio (feels too wide / short)

**Phase:** FB — Functional board · **Severity:** MEDIUM · **Size:** small · **Depends on:** TASK-023 · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **the loaded board to look like a real soccer pitch with correct proportions** so that **the field doesn't read as squashed/too-wide and player positions land where I expect**.

> Verbatim request: "The board image when loaded feels a little off — the ratio feels too short and too wide. Look into the ratio/dimensions."

## Why this matters
The pitch markings are authored in a normalized **724×464** design space (= **1.562:1**, which matches a real pitch of 105×68m). But the live board frame is **6000×5000** (= **1.2:1**). Because the markings stretch to fill that frame, they scale non-uniformly: `sx = 6000/724 ≈ 8.29×` horizontally vs `sy = 5000/464 ≈ 10.78×` vertically. That stretches the field vertically by ~**1.30×**, which to the eye reads as "too wide / too short." This is a real distortion, not a perception quirk — the markings (center circle, boxes, arcs) are visibly out of proportion. Desired: the rendered field preserves the 724:464 ratio so it matches both the real pitch and the scaffold `PitchView`, which already constrains itself correctly.

## Findings / current state
- [`Ludi Boards/Redesign/RedesignPitchBackground.swift:100-110`](../../Ludi%20Boards/Redesign/RedesignPitchBackground.swift) — `RedesignSoccerBoardView` frames the live surface as `width: BEO.boardHeight (6000), height: BEO.boardWidth (5000)` with **no aspect constraint**. This is the distortion site: a 1.2:1 frame holding 1.562:1 markings. The `isMini` 100×100 branch is a square and renders acceptably but also has no aspect constraint.
- [`Ludi Boards/Redesign/RedesignPitchBackground.swift:19-60`](../../Ludi%20Boards/Redesign/RedesignPitchBackground.swift) — `RedesignPitchMarkings` is normalized to `W=724, H=464` and scales by `sx = rect.width/W`, `sy = rect.height/H` independently. It draws correctly **only when the rect it's given is 724:464**; any other ratio shears every shape. The fix must constrain the rect, not the markings.
- [`Ludi Boards/Redesign/PitchView.swift:189`](../../Ludi%20Boards/Redesign/PitchView.swift) — the scaffold `PitchView` already applies `.aspectRatio(724.0 / 464.0, contentMode: .fit)`. This is the proven correct pattern and the exact constraint the live board is missing — copy it.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:156-157`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `boardWidth = 5000`, `boardHeight = 6000`. Note the **backwards naming**: `boardWidth` is the vertical extent and `boardHeight` the horizontal extent (see the framing at the call site). These feed the frame directly. If we adjust dimensions instead of constraining, this is where the numbers change.
- [`Ludi Boards/views/Backgrounds/Soccer/SoccerFieldBG.swift:35-76`](../../Ludi%20Boards/views/Backgrounds/Soccer/SoccerFieldBG.swift) — the legacy `SoccerFieldFullView` is where the `width: boardHeight, height: boardWidth` swap (line 74) and the backwards-naming convention originate. The redesign mirrored it deliberately (per the comment at `RedesignPitchBackground.swift:9-10`) so tools land in the same coordinate space — which is why constraining is preferable to renaming.

## Scope
**In scope:**
- Constrain `RedesignSoccerBoardView` (non-mini branch) so the rendered pitch preserves the **724:464** ratio, matching `PitchView` and the real pitch — remove the visible vertical stretch.
- Confirm the chosen approach does not shift where tools spawn / land on the field (the stated reason the legacy framing was mirrored).
- Verify the mini (100×100) thumbnail still renders acceptably.

**Out of scope:**
- Renaming `boardWidth`/`boardHeight` to fix the backwards convention — separate cleanup (see open questions); confusing but not load-bearing here.
- Any Firebase wiring. Board-settings persistence stays as-is; if `boardWidth`/`boardHeight` ultimately change, leave the write/read path Firebase-ready but do not wire it.
- Reworking the markings geometry or the tool coordinate space.

## Files expected to change
- `Ludi Boards/Redesign/RedesignPitchBackground.swift` (primary — the frame/aspect constraint)
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift` (only if Option B / dimension rescale is chosen)

## Acceptance criteria
- [ ] On a freshly loaded redesign board, the pitch renders at **724:464 (≈1.562:1)** — the center circle is round, penalty/goal boxes are correctly proportioned, no vertical stretch.
- [ ] The rendered proportions match `PitchView` (`PitchView.swift:189`) side by side.
- [ ] Placed/spawned tools still land on the field at the same relative positions as before the change (no coordinate-space drift).
- [ ] The `isMini` 100×100 thumbnail still renders without regression.
- [ ] No Firebase wiring added; if board dimensions changed, persistence remains read/write-safe and Firebase-ready only.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless, scheme **"Ludi Boards"**, bundle **io.ludi.sol**, verified per the project's background-simulator convention): load the redesign board and confirm the pitch reads as a correctly-proportioned field (round center circle, no squash); spawn/place a tool and confirm it lands where expected; check the board thumbnail in any picker still looks right.

## Open questions / risks
- **Constrain vs. rescale.** Option A: apply `.aspectRatio(724.0/464.0, contentMode: .fit)` to `RedesignPitchSurface` in `RedesignSoccerBoardView` (line 106) — no change to `boardWidth`/`boardHeight`, so tool spawn geometry is untouched. Option B: rescale the dimensions (keep `boardWidth=5000` → `boardHeight≈7797`, or keep `boardHeight=6000` → `boardWidth≈3857`) — fixes the ratio at the source but shifts the frame the engine lays tools into. **Recommend Option A**: the comment at `RedesignPitchBackground.swift:10` says tools land identically because the frame mirrors the legacy convention; constraining the surface visually without moving the frame is the lowest-risk fix.
- **Backwards naming (`boardWidth`=vertical, `boardHeight`=horizontal).** Inherited from `SoccerFieldFullView`. **Recommend** leaving it as-is for this task and filing a separate low-priority cleanup (or documenting it as the convention) — renaming touches every consumer of these fields and is out of proportion to this fix.
- **Risk:** if Option A is chosen and the engine's tool overlay uses the raw `boardHeight × boardWidth` frame (not the visually-constrained surface), the markings and the tool layer could end up sized differently. Verify the overlay and the surface agree after constraining — this is the key thing to check in the sim.
