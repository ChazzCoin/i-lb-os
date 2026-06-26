# Ludi Boards — SwiftUI export

A faithful SwiftUI translation of the **Ludi Boards** tactical-board redesign
(three iPad screens: *Board*, *Node selected*, *Library*). Built for
iPadOS/iOS, landscape-first, dark.

## What's here

```
Sources/
  Theme.swift            Colors, gradients, typography, glass-panel surface
  Models.swift           TeamKind, BoardToken, SquadPlayer, enums + sample data
  PitchView.swift        Pitch markings Shape, striped turf, discs, arrows, ball
  Components.swift       TopBar, ToolRail, ControlPill, presence avatars, ModeSwitch
  Panels.swift           SquadPanel, PropertiesPanel, LibraryPanel
  TacticalBoardView.swift  Full-screen composition + screen switcher
  LudiBoardsApp.swift    @main entry with a runtime screen picker
```

## Quick start

1. **New Xcode project** → iOS App → SwiftUI → name it `LudiBoards`.
2. Delete the generated `ContentView.swift` and the default `…App.swift`.
3. Drag everything in `Sources/` into the project (check *Copy items if needed*).
4. Set the device to an **iPad (landscape)** and run, or use the SwiftUI
   previews at the bottom of `TacticalBoardView.swift`.

## Fonts

The design uses three families. Add the `.ttf` files to the target and list
them in **Info.plist → "Fonts provided by application"**:

- **Archivo** — display & numerals (`AppFont.display`)
- **Hanken Grotesk** — UI text (`AppFont.ui`, expects `HankenGrotesk-Regular`)
- **JetBrains Mono** — data/readouts (`AppFont.mono`, expects `JetBrainsMono-Regular`)

If a family isn't bundled, SwiftUI falls back to the system font — layout still
holds, only the typeface changes. Adjust the PostScript names in
`AppFont` (Theme.swift) to match the files you ship.

## Icons & images

- UI icons use **SF Symbols**, mapped from the redesign's custom line icons.
  Swap any symbol name inline if you prefer different glyphs.
- The top bar references an image asset named **`AppIcon-Board`** — add the
  app icon (`assets/app_icon.png` from the source project) to your asset
  catalog under that name, or change the `Image("AppIcon-Board")` call.

## Notes on fidelity

- Colors, radii, spacing, gradients and shadows are ported 1:1 from the
  mockup's inline styles (see `Brand` in Theme.swift).
- The pitch markings are vector (`PitchMarkings: Shape`) so they scale crisply;
  player positions are stored as fractions of the pitch rect in `Sample`.
- Hover states (`.onHover`) are included for iPad pointer / Mac Catalyst; they
  no-op on touch.
- Sliders, swatches and tab selections carry real `@State` so the panels are
  interactive out of the box. Wire them to your model as needed.
- The bottom-right segmented picker in `RootView` is a demo affordance —
  remove it for production.

## Next steps to make it functional

- Replace `Sample` data with your real squad / board model.
- Make `BoardToken` positions draggable (`DragGesture` updating `x`/`y`
  fractions) for true tactical-board editing.
- Hook `EditorMode` (Plan / Animate / Present) and `Record` to your
  animation/timeline layer.
