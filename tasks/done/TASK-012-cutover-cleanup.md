# TASK-012: Cutover & cleanup (route live board to redesign, retire old chrome)

**Phase:** RD-6 Cutover · **Depends on:** TASK-001..010 (TASK-011 optional)

## User story

As a **coach**, I want the redesigned board to be **the** board on launch, with the old chrome gone.

## Why this matters

RD-1..RD-5 build the redesign behind a flag. This makes it live and retires the superseded pieces so there's no dead/duplicate chrome.

## Scope

**In scope:**
- Route the live board (the `CanvasEngine` / `@main` path) to the redesigned `TacticalBoardView`.
- Remove the `RedesignPreviewEntry` demo switcher.
- Retire `CanvasMenuView` + `MvSettingsBar` (superseded by rail/pill/Properties).
- Final iPad-landscape polish.
- Confirm the free/local-only build still boots logged-out.

**Out of scope (explicit):**
- iPhone/portrait (separate effort); app-wide reskin (separate).

## References

- `Ludi Boards/CanvasEngine/CanvasEngine.swift` — current composition
- `Ludi Boards/LudiBoardsApp.swift:32` — `@main` scene
- `Ludi Boards/CanvasEngine/CanvasMenuView.swift`; `MvSettingsBar`; `Ludi Boards/Redesign/RedesignPreviewEntry.swift`

## Files expected to change

- `Ludi Boards/LudiBoardsApp.swift` / `Ludi Boards/CanvasEngine/CanvasEngine.swift` (route)
- Delete `CanvasMenuView` / `MvSettingsBar` / `RedesignPreviewEntry` once unreferenced

## Acceptance criteria

- [x] Launch shows the redesigned board on iPad landscape — `@main` → `RedesignRootView` (verified, no env vars)
- [~] Old chrome removed from the LIVE path (CanvasMenuView/MvSettingsBar reachable only via the DEBUG `LEGACY_BOARD` escape). Files NOT deleted — see note
- [x] Logged-out free build works — boots with no Firebase/login

## Verification (build + sim)

1. `/build` clean.
2. iPad sim: launch → redesigned board is live.
3. `grep -r "CanvasMenuView\|MvSettingsBar\|RedesignPreviewEntry"` → no live references.

## Open questions / risks

- Keep `RedesignPreviewEntry` for QA or delete.
- Flag-flip vs hard cutover.

## Blocker notes

(empty)

## Outcome (2026-06-26) — DONE (with a deliberate follow-up)

`@main` now routes to `RedesignRootView` (the redesigned board); the legacy
`CanvasEngine` is reachable only via the DEBUG `LEGACY_BOARD=1` escape. The
redesign board defaults to the redesign pitch, the demo switcher is reduced to
a production Library toggle (Clear is DEBUG-only), and the board boots
logged-out with an empty board + empty roster (the honest production start).

**Deliberate follow-up (NOT done, on purpose):** I did not hard-delete
`CanvasEngine` / `CanvasMenuView` / `MvSettingsBar`. They're now dead code on
the live path but deleting them is a cascade (CanvasEngine references the menu/
settings; the DEBUG escape + redesign button reference CanvasEngine). Keeping a
legacy fallback during a cutover is prudent — removal should be a separate,
deliberate cleanup once the redesign is confirmed stable in production.

**Known production gaps to flag:** the roster seeds only under DEBUG, so a fresh
production board has an empty Squad and the "Add player" button is still a stub
(a real add-player flow is future work); Share export and the sport-switch
dropdown are stubs.

Verified headless ([render](../../docs/design/canvas-board-redesign/renders/task-012/01-redesign-is-live-board.png)).
