# TASK-015: Fix smart-tool selection (unblock Properties for tactic tools)

**Phase:** Tool System Hardening · **Severity:** HIGH · **Depends on:** none · **Source:** [audit](../../docs/audits/2026-06-26-tool-system.md)

## User story
As a **coach**, I want **double-tapping a tactic tool to select it and open its Properties** so that **I can edit that tool's attributes like I can for soccer/line tools**.

## Why this matters
Today, double-tapping a smart/tactic tool clears the current selection instead of selecting the tapped tool, so the Properties panel never opens for tactic tools. The smart-tool double-tap calls `toggleMenuWindow()` without first making anchors visible, and `toggleMenuWindow()` only writes the selection when anchors are already visible — otherwise it clears it. The result is that an entire class of tools (tactics) is uneditable through Properties.

## Findings covered
- [`CoreEngine/.../ManagedViews/SmartTools.swift:203`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift#L203) — the smart-tool double-tap calls `MVO.toggleMenuWindow()` without first setting `anchorsAreVisible`. Fix: flip `MVO.anchorsAreVisible` before `toggleMenuWindow()` (as the line tools do), or use a dedicated idempotent single-tap selection setter.
- [`CoreEngine/.../MVObject.swift:181`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/MVObject.swift#L181) — `toggleMenuWindow()` only WRITES `selectedManagedViewId` when `anchorsAreVisible` is already true; otherwise it CLEARS it, so tactic tools clear selection instead of selecting and Properties never opens. Fix: ensure the caller sets `anchorsAreVisible` first, or add an idempotent selection setter that always writes the id.

## Scope
**In scope:**
- Make double-tapping a tactic/smart tool set `selectedManagedViewId` to that tool and open Properties.
- Match the selection path the line tools already use (set `anchorsAreVisible` before `toggleMenuWindow()`), or introduce a dedicated idempotent single-tap selection setter used by the redesign.

**Out of scope:**
- Reworking `toggleMenuWindow()`'s anchor-toggle semantics for line/soccer tools beyond what's needed to fix selection.
- Properties panel content/attribute binding (owned by TASK-009).
- Any change to soccer/line tool selection behavior (must remain unchanged).

## Files expected to change
- `CoreEngine/Sources/CoreEngine/ECViewEngine/ECManagedViews/ManagedViews/SmartTools.swift`

## Acceptance criteria
- [ ] Double-tapping a tactic tool sets `selectedManagedViewId` to that tool's id.
- [ ] Double-tapping a tactic tool opens the Properties panel.
- [ ] Existing soccer-tool selection behavior is unchanged.
- [ ] Existing line-tool selection behavior is unchanged.

## Verification (build + sim)
1. `/build` clean.
2. iPad sim (headless ok): seed a tactic tool, double-tap it, confirm `selectedManagedViewId` equals the tapped tool's id and the Properties panel is open; repeat for a soccer tool and a line tool to confirm their selection is unchanged.

## Open questions / risks
- Fork: flip `anchorsAreVisible` before `toggleMenuWindow()` (minimal, mirrors line tools) vs. add a dedicated idempotent single-tap selection setter (cleaner, but a new API surface the redesign must adopt). Pick one; don't do both.

## Outcome (2026-06-26) — DONE
Smart tools select via single-tap (and double-tap) → new idempotent `MVObject.selectTool()` (sets anchorsAreVisible + selectedManagedViewId + opens mvSettings). Properties now opens for tactic tools. Verified headless.
