# TASK-027: Correct the TASK-006 recorded rail scope (doc drift)

**Phase:** Left tool rail · **Severity:** LOW · **Depends on:** TASK-025 · **Source:** [audit](../../docs/audits/2026-06-26-left-tool-rail.md)

## User story

As a **future contributor reading the roadmap**, I want **the recorded rail scope to match what the rail actually does** so that **I don't trust a "✅ wired" claim for controls that were never wired**.

## Why this matters

`ROADMAP.md` records TASK-006 as "Left ToolRail wired (select / pan / draw / shape / marker / color) ✅". Only select + draw-straight + draw-curved were ever wired; pan duplicated select and shape/marker/color were dead placeholders (removed in TASK-025). The roadmap overstates done-ness — exactly the kind of drift that makes future planning trust the wrong baseline.

## Findings covered

- [`tasks/ROADMAP.md:51`](../../tasks/ROADMAP.md) — LOW: TASK-006 scope overstates what's wired.

## Scope

**In scope:**
- Correct the TASK-006 line in `ROADMAP.md` to the real wired set (select / draw-straight / draw-curved), noting shape/marker/colour live in Library/Properties.
- Add the **Left tool rail** phase + TASK-025/026/027 to `PHASES.md` and `ROADMAP.md`.

**Out of scope:**
- Re-opening or re-scoping TASK-006 itself (it shipped; this is a record correction).

## Files expected to change

- `tasks/ROADMAP.md`
- `tasks/PHASES.md`

## Acceptance criteria

- [ ] The TASK-006 roadmap line reflects the real wired set, not the aspirational one.
- [ ] A "Left tool rail" phase exists in `PHASES.md` with scope prose.
- [ ] `ROADMAP.md` lists TASK-025/026/027 under that phase.

## Verification

1. Read-back: the roadmap/phases describe the rail as it is after TASK-025/026.

## Outcome (2026-06-26) — DONE

Corrected the `ROADMAP.md` TASK-006 line to the real wired set
(select / draw-straight / draw-curved) with a note that pan/shape/marker/colour
were never wired. Added **Phase LR — Left tool rail** to `PHASES.md` and
`ROADMAP.md` with TASK-025/026/027 listed.
