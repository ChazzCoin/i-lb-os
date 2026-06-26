# TASK-023: Board-scale constants & shared CoreEngine tokens

**Phase:** Tool System Hardening · **Severity:** MEDIUM · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-tool-system.md)

## User story
As a **developer**, I want **named board-scale constants and shared brand-color tokens in CoreEngine instead of scattered magic multipliers and raw hex** so that **smart tools scale predictably, render their real colours, and don't drift from the app's Brand palette**.

## Why this matters
Smart-tool decorations are sized by ad-hoc multiples of stroke width `w` with no upper clamp and literals like `6000`/`0.02`, so the "~8× board upscale" exists only in scattered arithmetic — it can't be tuned or reasoned about, and the OffsideLine is pinned to a fixed board height that's wrong the moment the board resizes. The brand colours are re-hardcoded as raw hex inside CoreEngine with no link to the app Brand palette, so they will silently drift. And a model/`colorFromRGBA` scale mismatch (0–255 vs 0–1) makes any tool relying on the default colour render white.

## Findings covered
- [`SmartTools.swift:217-296`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift#L217-L296) — the "~8× upscale" is not a real constant; every decoration uses an ad-hoc multiple of `w`, no upper clamp; magic `6000`/`0.02`. → replace scattered multipliers with named board-scale constants and add a clamp on `w`.
- [`SmartTools.swift:287`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift#L287) — OffsideLine height/centre hardcoded to 6000 / y=3000, decoupled from `BEO.boardHeight`. → derive height/centre from board bounds, not a literal.
- [`SmartTools.swift:101`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift#L101) — Brand tokens re-hardcoded as raw hex in CoreEngine (lime CBDB2A etc.) with no link to the app Brand palette. → add `Color.brandLime`/`brandTeal`/`brandDanger` in `ColorProvider` and reference them from `SmartTools`.
- [`ColorProvider.swift:31`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECColor/ColorProvider.swift#L31) — RGBA scale ambiguity: model colour defaults are 0–255 but `colorFromRGBA` expects 0–1. → normalise on read or fix the defaults so a default-colour tool renders its colour, not white.

## Scope
**In scope:**
- Named board-scale constants (replacing the ad-hoc `w` multiples and `6000`/`0.02` literals) plus an upper clamp on `w` in `SmartTools`.
- Deriving OffsideLine height/centre from board bounds (`BEO.boardHeight` / the tool's own `start.y`).
- Adding `Color.brandLime`/`brandTeal`/`brandDanger` to CoreEngine's `ColorProvider` and referencing them from `SmartTools`.
- Resolving the RGBA 0–255 vs 0–1 scale mismatch (normalise on read or fix the model defaults).

**Out of scope:**
- Tool-family-aware Properties editing of colour/stroke (owned by the Properties-panel hardening task).
- Making tool views observe Realm / `refreshBoard()` re-render (owned by the colour-refresh task).
- Per-tool default-colour assignment (e.g. offside=red) and the create-path default-geometry factory.

## Files expected to change
- `Ludi Boards/.../SmartTools.swift` (`CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift`)
- `Ludi Boards/.../ColorProvider.swift` (`CoreEngine/Sources/CoreEngine/ECViewEngine/ECColor/ColorProvider.swift`)
- `Ludi Boards/.../ManagedView.swift` (`CoreEngine/Sources/CoreEngine/ECDatabase/ECRealm/Models/ManagedView.swift`) — only if the RGBA fix lands in the model defaults

## Acceptance criteria
- [ ] No raw magic multipliers in `SmartTools` decorations — board-scale factors are named constants, and `w` is clamped to an upper bound.
- [ ] The `6000` and `0.02` literals are removed in favour of named constants or derived values.
- [ ] OffsideLine spans the real board height (derived from board bounds / `start.y`), not a hardcoded 6000 / y=3000, and stays correct when the board resizes.
- [ ] `ColorProvider` exposes `Color.brandLime`, `Color.brandTeal`, `Color.brandDanger`; `SmartTools` references those instead of inline hex.
- [ ] The RGBA scale mismatch is resolved: a tool using the model's default colour renders its actual colour, not white/clamped.
- [ ] Existing smart tools still render at the correct on-board scale (no visual regression versus current output).

## Verification (build + sim)
1. `/build` clean (CoreEngine + app).
2. iPad sim (headless ok): `REDESIGN_BOARD=1 REDESIGN_SMART=1` renders the smart tools on the board — the OffsideLine spans the full board height and a default-colour tool shows its colour (not white).

## Open questions / risks
- RGBA fix has two valid landings: normalise on read in `colorFromRGBA`, or change the model defaults to 0–1. Normalising on read is safer (no migration, no silent shift for rows already written at 0–255) — confirm before changing model defaults.
- Brand hex values must match the app Brand palette exactly; if they already differ, treat reconciling them as the source-of-truth decision (CoreEngine token wins) rather than copying drift forward.

## Outcome (2026-06-26) — DONE
Added CoreEngine brand tokens (`Color.brandLime`/`brandTeal`/`brandDanger`/`brandHome*`) in `ColorProvider` and swapped SmartTools' raw hex for them; `colorFromRGBA` now tolerates 0–255 OR 0–1 (was clamping defaults to white); named the magic constants (`minStroke`/`maxStroke`/`boardHeight`/`metresPerUnit`) and clamped `w`.
