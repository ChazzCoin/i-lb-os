# TASK-016: Make the Properties panel tool-family-aware

**Phase:** Tool System Hardening · **Severity:** HIGH · **Depends on:** TASK-015 · **Source:** [audit](../../docs/audits/2026-06-26-tool-system.md)

## User story

As a **coach**, I want **size, rotation, and colour edits in the Properties panel to actually change the selected tool — whether it's a token, a line, or a smart/tactical tool** so that **the new tools respond the way they look like they should**.

## Why this matters

The Properties panel is not tool-family-aware: it reads/writes `width/rotation/toolColor` as if every tool were a token. For lines and smart tools `width` is a stroke (and `height` is unused), `rotation` is recomputed from geometry, and rendering comes from RGBA — not the `toolColor` name. So SIZE writes the wrong field, ROTATION silently no-ops, and COLOUR visibly does nothing. The new tools look right but don't respond right.

## Findings covered

- [`Ludi Boards/Redesign/Panels.swift:350`](../../Ludi%20Boards/Redesign/Panels.swift#L350) — SIZE slider rewrites `mv.width`, which for lines/smart tools is the STROKE width (and writes the unused `mv.height`). Fix: branch by tool family; for line/smart bind a stroke-width control to `mv.width` and stop writing `mv.height`.
- [`Ludi Boards/Redesign/Panels.swift:355`](../../Ludi%20Boards/Redesign/Panels.swift#L355) — ROTATION slider no-ops on line/shape tools (they recompute rotation from geometry, ignoring `mv.rotation`). Fix: hide/disable ROTATION where it is ignored (or rotate the geometry instead).
- [`Ludi Boards/Redesign/Panels.swift:359`](../../Ludi%20Boards/Redesign/Panels.swift#L359) — TEAM COLOUR writes the NAME field `toolColor`, but line/smart tools render from RGBA, so the colour visibly does not change. Fix: in `pickColor` also write `colorRed/Green/Blue/Alpha`.
- [`Ludi Boards/Redesign/Panels.swift:334`](../../Ludi%20Boards/Redesign/Panels.swift#L334) — rotation round-trip mishandles negative angles (knob goes off-track). Fix: normalise the rotation fraction into [0,1).

## Scope

**In scope:**
- Branch `EnginePropertiesPanel` by tool family (token vs line vs smart).
- Line/smart: a stroke-width control bound to `mv.width` (no `mv.height` write).
- Hide/disable ROTATION for tool families that ignore `mv.rotation` (or rotate geometry).
- `pickColor` also writes `colorRed/Green/Blue/Alpha`, not just `toolColor`.
- Normalise the rotation fraction into [0,1) so negative angles keep the knob on-track.

**Out of scope:**
- Smart-tool *selectability* (the `anchorsAreVisible` flip) — TASK-015.
- Making `refreshBoard()`/Realm observation propagate colour edits — separate finding (token disc colour, `SoccerPlayerToolView.swift` + `BoardEngineObject.swift`).
- Roster / linked-player wiring.

## Files expected to change

- `Ludi Boards/Redesign/Panels.swift`

## Acceptance criteria

- [ ] Changing size on a **line** tool visibly changes the rendered stroke (writes `mv.width`, leaves `mv.height` alone).
- [ ] Changing size on a **smart** tool visibly changes the rendered tool.
- [ ] Changing colour on a line tool and a smart tool visibly changes the rendered tool (RGBA written, not just `toolColor`).
- [ ] ROTATION is not shown (or actually works) for tool families that ignore `mv.rotation`.
- [ ] A negative `mv.rotation` keeps the rotation knob on-track (fraction normalised into [0,1)).
- [ ] Token behaviour (size/rotation/colour) is unchanged.

## Verification (build + sim)

1. `/build` clean.
2. iPad sim (headless ok): select a line tool, drag SIZE → stroke visibly thickens; change colour → line recolours; select a smart tool and confirm the same; confirm ROTATION is hidden/disabled (or works) for those families and that a tool rotated to a negative angle still tracks the knob.

## Open questions / risks

- ROTATION on lines/shapes: hide vs. rotate-the-geometry is a genuine fork — hiding is the smaller, safer change; rotating geometry is more capable but touches the start/center/end math. Default to hiding/disabling unless geometry rotation is cheap to do correctly.

## Outcome (2026-06-26) — DONE
`EnginePropertiesPanel` is family-aware: line/smart tools get a **STROKE** control (10–140, width only) and **no ROTATION**; `pickColor` now writes RGBA (colorRed/Green/Blue) so line/smart colour actually changes; negative rotation normalised. Verified (STROKE shown, ROTATION hidden).
