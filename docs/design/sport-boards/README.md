# Sport Boards — vector field/court catalogue

Imported from the **Sports Boards Catalogue** handoff
(`_original-catalogue.html`, a self-extracting bundled page). 10 SwiftUI
sport-field backgrounds; the extracted sources are in [`sources/`](sources/).

## The 10 boards

Each is a `Shape` of field markings over a turf/surface fill, bridged into the
live engine as a `Sports` registry board. Four extend existing sports; six
introduce new sport classes.

| Board (registry name) | Sport class | Source |
|---|---|---|
| `Soccer Markings Full View` | `Soccer` (existing) | `SoccerMarkings` |
| `Football Gridiron Full View` | `Football` (existing) | `GridironMarkings` |
| `Basketball Court Full View` | `Basketball` (existing) | `CourtMarkings` |
| `Pool Table Vector` | `Pool` (existing) | `PoolTable` |
| `Futsal Court` | `Futsal` (new) | `FutsalMarkings` |
| `Baseball Diamond` | `Baseball` (new) | `DiamondMarkings` |
| `Tennis Court` | `Tennis` (new) | `TennisMarkings` |
| `Volleyball Court` | `Volleyball` (new) | `VolleyMarkings` |
| `Handball Court` | `Handball` (new) | `HandballMarkings` |
| `Ice Hockey Rink` | `Hockey` (new) | `RinkMarkings` |

## How they're wired

- **Views** — `Ludi Boards/views/Backgrounds/SportBoardBackgrounds.swift`. Each
  board is `<Sport>Markings: Shape` + `<Sport>Surface: View` (turf + stroke) +
  `<Sport>BoardView: View` (the registry-compatible board, `isMini` + frame).
- **Registry** — registered in `Providers/Sports.swift`. `getAllBoards()` /
  `getAllMinis()` now iterate a single `allSports` list, so adding a sport is a
  one-line change. The engine renders the selected board via
  `BoardEngineView` → `getAllBoards()[boardBgName]`.
- **Picker** — the redesign Library panel (`Redesign/Panels.swift`). `Sample.boards`
  is a sport-tagged catalogue (`BoardPreset.sport` / `.registryName`); the
  BOARDS grid filters to the selected SPORT pill, and `BoardThumb` renders the
  real registry mini (distinct turf colours make boards recognisable). Picking
  sets `BEO.boardBgOverride` / `boardBgName` to the registry name.

## Board-scale problem & fix

The catalogue authored these at card scale (~300pt) with small absolute details
— 2pt lines, 16pt pool pockets, 30pt faceoff dots. The engine board is
5000×6000, so dropped in raw the lines become hairlines and the details vanish
(the same scale problem the Smart Tools had).

`BoardSurfaceScaler` draws each surface into a fixed reference rect (600×500,
matching the board frame's 6000:5000 aspect) and uniformly scales it ~10× to
fill — so line weight and details survive at board scale, and shrink
proportionally for the 100×100 picker minis. The framing mirrors
`RedesignSoccerBoardView` / `SoccerFieldFullView`
(`width: boardHeight, height: boardWidth`) so spawned tools share the field's
coordinate space.

One source fix beyond the literal translation: the gridiron end-zone colour
bands used an `HStack` + `layoutPriority` that collapsed when filling the board;
replaced with a `GeometryReader` placing 8.3%-width bands aligned to the
markings inset.

## Green-backing fix (BoardEngineView)

A pre-existing artifact surfaced once the boards rendered: `FieldOverlayView`
painted `BEO.boardBgColor` (a 75%-opacity green) as a 5000×6000 backing rect,
but every board view is framed *transposed* (6000×5000) and rounded, so ~500pt
of green leaked as strips above/below the board and at its corners. Since every
redesign board draws its own opaque surface, the backing is dead weight on the
redesign path. Fixed in `BoardEngineView.swift` by clearing the background to
`Color.clear` when `boardBgOverride` is set (redesign mode) — the legacy board
(`boardBgOverride == nil`) keeps `boardBgColor` unchanged. Frame sizes are
untouched, so the transpose (load-bearing for tool coordinates) is preserved.

## Verification

All 10 boards rendered headlessly on a booted iPad Pro simulator
(`SIMCTL_CHILD_REDESIGN_BG="<registry name>"`, a DEBUG-only hook in
`RedesignPreviewEntry.configureRedesignBoard`). Renders + the wired Library
panel are in [`renders/`](renders/) (gitignored). Confirmed: arcs/circles,
hockey faceoff dots, pool pockets, baseball clay, and the fixed gridiron end
zones all read correctly at board scale.
