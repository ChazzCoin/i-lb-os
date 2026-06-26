# TASK-008: TopBar + EditorMode (Plan/Animate/Present) wired

**Phase:** RD-3 Chrome · **Depends on:** TASK-002

## User story

As a **coach**, I want the top bar to show my real activity/sport and switch Plan / Animate / Present, with a Share/export entry.

## Why this matters

The design's `TopBar` is static strings; `ModeSwitch` is local `@State`. The app has a current session/activity, the `Sports` registry, and a record/playback engine (the Animate/Present target — built but currently unreached).

## Scope

**In scope:**
- Breadcrumb from current session/activity (`BEO.currentActivityId`, `SESSION_ON_ID_CHANGE`).
- `SportChip` → current sport from the Sports registry + switch.
- `ModeSwitch`: Plan = edit; Animate = record/playback timeline entry; Present = hide chrome / full-screen.
- Share → export/share entry (stub or existing share).
- Presence avatars: gated/empty on the free build (no Firebase).

**Out of scope (explicit):**
- Realtime presence (paid/Firebase); the full Animate timeline UI (its own later task).

## References

- `Ludi Boards/Redesign/Components.swift:68` — `TopBar` / `ModeSwitch` / `SportChip` / `ShareButton`
- `Ludi Boards/CanvasEngine/BoardEngineView.swift:94` — `SESSION_ON_ID_CHANGE` / `changeActivity`
- `Ludi Boards/Providers/Sports.swift`; record/playback in `BoardEngineObject.swift`

## Files expected to change

- `Ludi Boards/Redesign/Components.swift` (`TopBar` → bind BEO + Sports + mode)

## Acceptance criteria

- [x] Breadcrumb reflects the real current activity — "My Board" from `ActivityPlan.title`
- [~] Sport chip displays the real sport ("Soccer · Full"); the switch dropdown is a stub (chevron present)
- [x] Plan/Animate/Present change board mode; Present hides chrome — verified
- [~] Share button present; export action stubbed for RD-6

## Verification (build + sim)

1. `/build` clean.
2. iPad sim: changing activity updates the breadcrumb; Present hides the chrome.

## Open questions / risks

- Scope of the Animate timeline UI (likely its own follow-up task).
- Share target (image export? link? existing share?).

## Blocker notes

(empty)

## Outcome (2026-06-26) — DONE
`EngineTopBar` wrapper binds breadcrumb to `ActivityPlan.title`/`subTitle` and gates presence on `BEO.isLoggedIn` (free build → none). `Present` mode hides rail/pill/panels/context bar (top bar stays to exit). Verified headless ([present](../../docs/design/canvas-board-redesign/renders/task-008/01-present-mode-chrome-hidden.png)). Sport-switch dropdown + Share export deferred (display correct).
