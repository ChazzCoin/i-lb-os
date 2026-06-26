# TASK-009: Properties panel replaces MvSettingsBar (via CodiChannel.TOOL_ATTRIBUTES)

**Phase:** RD-4 Panels · **Depends on:** TASK-002, TASK-004

## User story

As a **coach**, when I select a token I want the **Properties panel** (identity, team colour, size, rotation, duplicate/delete) instead of `MvSettingsBar`.

## Why this matters

The design's `PropertiesPanel` is static `@State`; engine tool settings already flow through `CodiChannel.TOOL_ATTRIBUTES` (rotation/size/color/delete are wired to `MvSettingsBar` today). We swap the **UI** and keep the **bus**.

## Scope

**In scope:**
- Wire `PropertiesPanel`: size → tool width/height; rotation → tool rotation; team-colour swatches → `toolColor`; duplicate/delete → existing actions — all via `CodiChannel.TOOL_ATTRIBUTES` (`ViewAtts`).
- Open the panel on selection (replaces the `MvSettingsBar` open path).
- Linked-player row = stub (RD-5).

**Out of scope (explicit):**
- Identity name/position + linked-player real data (RD-5, TASK-011).

## References

- `Ludi Boards/Redesign/Panels.swift:108` — `PropertiesPanel` / `SliderRow` / `ColourSwatch`
- `Ludi Boards/BoardEngine/RotationSlider.swift`, `Ludi Boards/BoardEngine/SizeSlider.swift` — current settings controls (`MvSettingsBar` successor)
- `CodiChannel.TOOL_ATTRIBUTES` → `ViewAtts`

## Files expected to change

- `Ludi Boards/Redesign/Panels.swift` (`PropertiesPanel` → send `ViewAtts`)
- Selection → panel-open wiring

## Acceptance criteria

- [x] Selecting a token opens Properties — shows the real tool (#5 matches the selected disc)
- [x] Size/rotation read the tool (200px/0°) + write to Realm (live via MVObject observation); swatch writes `toolColor`+refresh
- [x] Delete (soft) / duplicate wired to the engine
- [x] Redesign path uses `EnginePropertiesPanel`, not `MvSettingsBar`

## Verification (build + sim)

1. `/build` clean.
2. iPad sim: select a token, drag the size slider → tool resizes; change color via swatch.

## Open questions / risks

- Exact `ViewAtts` fields — confirm against current `RotationSlider`/`SizeSlider` usage.

## Blocker notes

(empty)

## Outcome (2026-06-26) — DONE
`PropertiesPanel` parameterised; `EnginePropertiesPanel` reads the selected `ManagedView` (number=placeholder, size=width, rotation, colour) and writes back (size/rotation live via the tool's Realm observation; colour via write+`refreshBoard`). Identity name + linked-player deferred to RD-5. Verified headless ([render](../../docs/design/canvas-board-redesign/renders/task-009/01-properties-reads-real-tool.png)).
