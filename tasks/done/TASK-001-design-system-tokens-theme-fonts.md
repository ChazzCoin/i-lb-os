# TASK-001: Design system — tokens, board-scoped theme, Color(hex) reconciliation, fonts

**Phase:** RD-1 Foundation · **Depends on:** none · **Blocks:** TASK-002..010

## User story

As a **developer**, I want the redesign's **design tokens, glass-panel surface, and three fonts available and scoped to the board screen**, so the board can adopt the new dark look without disturbing the SOL-green home/nav.

## Why this matters

Every RD-2…RD-4 view references `Brand` / `GlassPanel` / `AppFont`. Today the design files are isolated (`import SwiftUI` only) and the three fonts fall back to system. Decision: **board-screen theme only**.

## Scope

**In scope:**
- Make `Brand`, `GlassPanel`, `CanvasBackground` usable from the live board layer.
- Resolve the `Color(hex:)` ambiguity: the design's `Color.init(hex:opacity:)` (Theme.swift) collides with CoreEngine's `init(hex:)` once a board view imports CoreEngine. Alias/namespace one (e.g. a `Brand`-scoped initializer) so board views compile with both modules in scope.
- Source, bundle, and register the three fonts (Archivo, Hanken Grotesk, JetBrains Mono) in Info.plist `UIAppFonts`; confirm `AppFont` resolves on device.

**Out of scope (explicit):**
- Applying tokens to home / nav / settings (board-only decision).

## References

- `Ludi Boards/Redesign/Theme.swift` — `Brand`, `GlassPanel`, `AppFont`, `Color(hex:)`
- `CoreEngine/Sources/CoreEngine/ECProviders/ColorProvider.swift:60` — existing `init(hex:)` (collision)
- `docs/design/canvas-board-redesign/README.md` — "Fonts" (PostScript names)

## Files expected to change

- `Ludi Boards/Redesign/Theme.swift`
- `Ludi Boards/Info.plist` (UIAppFonts)
- `Ludi Boards/Fonts/*.ttf` (new)

## Acceptance criteria

- [x] Token text renders in Archivo/Hanken/JetBrains on iPad (not system fallback) — fonts bundled + registered (`UIAppFonts`); **pixel-level visual confirm folded into TASK-002** when the redesign becomes reachable in the running app
- [x] A board view can `import CoreEngine` and use `Brand` colors with no `Color(hex:)` ambiguity build error — verified: clean build, 0 ambiguity
- [x] Home/nav appearance unchanged — no changes outside `Theme.swift`, Info.plist, `Fonts/`, pbxproj

## Outcome (2026-06-25)

**Color(hex) reconciliation — namespaced initializer.** The redesign's
`Color(hex:opacity:)` collided with CoreEngine's public `Color(hex:)`
(`ColorProvider.swift:60`) — the default `opacity` made both match
`Color(hex:"…")` once a view imports both modules. All 37 redesign call
sites are 6-digit, no `opacity:` → identical RGB math to CoreEngine's.
Renamed the redesign initializer to `Color(brandHex:)` and rewrote all
37 call sites. Keeps the design system self-contained (no forced
CoreEngine import) and removes the collision permanently.

**Fonts — sourced, not stubbed.** OFL-licensed (freely redistributable).
Downloaded the variable `.ttf` from Google Fonts → `Ludi Boards/Fonts/`
with `OFL-*.txt`. Verified registered family names from each font's
`name` table; pointed `AppFont` at them (`Archivo`, `Hanken Grotesk`,
`JetBrains Mono`) so `.weight()` traverses the variable `wght` axis.
Added to target resources (xcodeproj gem) + `UIAppFonts`. Confirmed all
three `.ttf` in the built bundle and `UIAppFonts` in the compiled plist.

## Verification (build + sim)

1. `/build` clean.
2. iPad sim: redesigned board harness shows Archivo numerals on tokens (compare to `docs/design/canvas-board-redesign/renders/board.png`).

## Open questions / risks

- Source + license of the three `.ttf` files.
- Alias `Color(hex:)` vs fully-qualify CoreEngine's — pick one and document.

## Blocker notes

(empty)
