# TASK-021: Unified selection: shared ring, single-tap, non-global state

**Phase:** Tool System Hardening · **Severity:** MEDIUM · **Depends on:** TASK-015 · **Source:** [audit](../../docs/audits/2026-06-26-tool-system.md)

## User story
As a **coach**, I want **every tool to show the same selection ring on a single tap and to stop honouring a stale selection from a previous launch** so that **I always know what I'm editing and the Properties panel matches the tool I touched**.

## Why this matters
Selection feedback only exists for tokens — the lime ring lives in `enableManagedViewTool`, so lines, curved lines and smart tools show no ring, and single-point smart tools (offside/spotlight/focus/ladder/badge) give no selection feedback at all. Selection itself is a double-tap toggle with legacy `mvSettings` side effects, so there's no single-tap select and double-tapping a selected tool deselects it. Worse, the whole selection UX rests on one global `@AppStorage("selectedManagedViewId")` string that persists across launches, so the board boots pointing at a tool that may be deleted or on another board.

## Findings covered
- [`CoreEngine/.../ManagedToolView.swift:117`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/ManagedToolView.swift) + [`CoreEngine/.../SmartTools.swift:199`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift) — the lime selection ring lives only in `enableManagedViewTool` (tokens); lines/curved/smart tools get no ring (single-point smart tools show no selection feedback at all). Fix: factor the lime ring into a shared modifier keyed on `selectedManagedViewId` and apply it across families, incl. a halo for single-point smart tools.
- [`CoreEngine/.../MVObject.swift:180`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift) — selection is a DOUBLE-tap toggle with legacy mvSettings side effects; no single-tap select, and double-tapping a selected tool deselects it. Fix: add an idempotent single-tap selection setter for the redesign.
- [`Ludi Boards/Redesign/RedesignPreviewEntry.swift:63`](../../Ludi%20Boards/Redesign/RedesignPreviewEntry.swift) — the initial bridge honours a stale persisted `selectedManagedViewId` even if that tool was deleted / on another board. Fix: validate the persisted id against Realm on appear and clear it on activity change.
- [`CoreEngine/.../MVObject.swift:73`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift) — selection is a single global `@AppStorage` key persisted across launches (the whole selection UX rests on a UserDefaults string). Fix: consider an in-memory published selection on `BEO` with AppStorage as fallback.

## Scope
**In scope:**
- A shared selection-ring modifier keyed on `selectedManagedViewId`, applied across token / line / curved / smart families.
- A halo variant of the ring for single-point smart tools (offside/spotlight/focus/ladder/badge).
- An idempotent single-tap selection setter (select on tap, no deselect-on-retap) for the redesign path.
- Validate the persisted selection id against Realm on appear; clear it on activity change.
- In-memory published selection on `BEO`, with `@AppStorage` retained only as a fallback.

**Out of scope:**
- Smart-tool selection enablement via `anchorsAreVisible` (separate HIGH finding, TASK-015 — this task depends on it).
- Making Properties tool-family-aware (SIZE/ROTATION/COLOUR mis-edit — separate task).
- Drag-persistence / `isDragging` guards on smart tools (separate finding).

## Files expected to change
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/ManagedToolView.swift`
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift`
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift`
- `Ludi Boards/Redesign/RedesignPreviewEntry.swift`
- `Ludi Boards/CanvasEngine/BoardEngineObject.swift`

## Acceptance criteria
- [ ] Every tool family (token, line, curved line, smart) shows the lime selection ring when selected.
- [ ] Single-point smart tools (offside/spotlight/focus/ladder/badge) show a visible selection halo.
- [ ] A single tap selects a tool; tapping the already-selected tool keeps it selected (no deselect-on-retap).
- [ ] A stale/deleted persisted selection id is ignored on launch (validated against Realm).
- [ ] Switching activity/board clears the persisted selection.
- [ ] Selection is read from an in-memory published property on `BEO`; `@AppStorage` is fallback only.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless ok): tap a line and a smart tool — each shows the lime ring; with a known-bad `selectedManagedViewId` seeded in UserDefaults, the board boots with nothing selected.

## Open questions / risks
- BEO-published vs AppStorage source-of-truth precedence on launch — confirm the published value wins and AppStorage only seeds it.
- Halo geometry for single-point smart tools — needs a defined radius/offset so it doesn't collide with anchor dots.

## Outcome (2026-06-26) — DONE (core) / partial
Idempotent single-tap select (`selectTool()`); single-point smart tools get a lime selection halo; the persisted `selectedManagedViewId` is validated against Realm on appear (exists, !isDeleted, current board) and dropped if stale. **Deferred:** a shared ring on line/curved tools (they render as paths — a ring is debatable) and moving selection fully off `@AppStorage` onto a BEO published value (the on-appear validation mitigates the stale-id risk for now).
