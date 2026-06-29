//
//  SportBoardBackgrounds.swift
//  Ludi Boards
//
//  Vector sport-field backgrounds imported from the Sports Boards Catalogue
//  (Claude Design SwiftUI handoff). Each board is a `Shape` of field markings
//  over a turf/surface fill, bridged into the live engine as a `Sports`
//  registry board (registered in `Providers/Sports.swift`).
//
//  Board-scale problem & fix
//  -------------------------
//  The catalogue authored these at card scale (~300pt) with small absolute
//  details — 2pt lines, 16pt pool pockets, 30pt faceoff dots. The engine board
//  is 5000×6000, so dropped in raw those lines become hairlines and the details
//  vanish. `BoardSurfaceScaler` draws each surface into a fixed reference rect
//  (matched to the board frame's 6000:5000 aspect) and uniformly scales it ~10×
//  to fill — so line weight and details survive at board scale, and shrink
//  proportionally for the 100×100 picker minis.
//
//  Framing mirrors `RedesignSoccerBoardView` / `SoccerFieldFullView`
//  (`width: boardHeight, height: boardWidth`) so spawned tools share the
//  field's coordinate space. Field rotation is applied uniformly by
//  `BoardEngineView`, so these views don't rotate themselves.
//

import SwiftUI
import CoreEngine

// MARK: - Scaler

/// Renders catalogue-scale surface content into the live board frame. The
/// reference rect carries the board frame's aspect (boardHeight:boardWidth =
/// 6000:5000), so a single uniform scale fills the board with even line weight.
struct BoardSurfaceScaler<Content: View>: View {
    /// Native authoring rect. Aspect = 6000:5000 (the transposed board frame).
    static var reference: CGSize { CGSize(width: 600, height: 500) }
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            content()
                .frame(width: Self.reference.width, height: Self.reference.height)
                .scaleEffect(max(geo.size.width, 1) / Self.reference.width, anchor: .topLeading)
        }
    }
}

/// Shared framing for every catalogue board: scale the surface to fill the
/// board (or a 100×100 mini), using the legacy `boardHeight × boardWidth`
/// convention so tools land on the field identically.
private struct CatalogueBoard<Surface: View>: View {
    @EnvironmentObject var BEO: BoardEngineObject
    let isMini: Bool
    @ViewBuilder var surface: () -> Surface

    var body: some View {
        BoardSurfaceScaler(content: surface)
            .frame(width: isMini ? 100.0 : BEO.boardHeight,
                   height: isMini ? 100.0 : BEO.boardWidth)
            .clipped()
    }
}

// MARK: - Soccer (flat markings)

struct SoccerMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        let cr = r.height * 0.18
        p.addEllipse(in: CGRect(x: r.midX - cr, y: r.midY - cr, width: cr*2, height: cr*2))
        let bw = r.width*0.16, bh = r.height*0.58       // penalty box
        let gw = r.width*0.055, gh = r.height*0.28      // goal box
        for far in [false, true] {
            let bx = far ? r.maxX - bw : r.minX
            let gx = far ? r.maxX - gw : r.minX
            p.addRect(CGRect(x: bx, y: r.midY-bh/2, width: bw, height: bh))
            p.addRect(CGRect(x: gx, y: r.midY-gh/2, width: gw, height: gh))
            let spot = far ? r.maxX - bw*0.66 : r.minX + bw*0.66
            p.addEllipse(in: CGRect(x: spot-1.4, y: r.midY-1.4, width: 2.8, height: 2.8))
        }
        return p
    }
}

struct SoccerMarkingsSurface: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "3c9a5c"), Color(hex: "2c7e45")],
                           startPoint: .top, endPoint: .bottom)
            SoccerMarkings().stroke(.white.opacity(0.9), lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SoccerMarkingsBoardView: View {
    let isMini: Bool
    var body: some View { CatalogueBoard(isMini: isMini) { SoccerMarkingsSurface() } }
}

// MARK: - Gridiron (American football)

struct GridironMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let ez = r.width * 0.083                  // 10-yd end zones
        let field = CGRect(x: r.minX + ez, y: r.minY, width: r.width - ez*2, height: r.height)
        p.addRect(field)
        for i in 0...20 {                          // lines every 5 yd
            let x = field.minX + field.width * CGFloat(i)/20
            p.move(to: CGPoint(x: x, y: field.minY))
            p.addLine(to: CGPoint(x: x, y: field.maxY))
            for hy in [r.height*0.37, r.height*0.63] {   // hash rows
                p.move(to: CGPoint(x: x-3, y: hy))
                p.addLine(to: CGPoint(x: x+3, y: hy))
            }
        }
        return p
    }
}

struct GridironSurface: View {
    var body: some View {
        ZStack {
            Color(hex: "2f8b4d")
            GeometryReader { g in                          // coloured end zones
                let ez = g.size.width * 0.083              // matches markings inset
                HStack(spacing: 0) {
                    Color(hex: "21437d").frame(width: ez)
                    Spacer(minLength: 0)
                    Color(hex: "9e3636").frame(width: ez)
                }
            }
            GridironMarkings().stroke(.white.opacity(0.85), lineWidth: 1.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct GridironBoardView: View {
    let isMini: Bool
    var body: some View { CatalogueBoard(isMini: isMini) { GridironSurface() } }
}

// MARK: - Diamond (baseball)

struct DiamondMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let home = CGPoint(x: r.midX, y: r.maxY - r.height*0.05)
        let b = r.width * 0.29
        let first  = CGPoint(x: home.x + b, y: home.y - b)
        let second = CGPoint(x: home.x,     y: home.y - b*2)
        let third  = CGPoint(x: home.x - b, y: home.y - b)
        p.move(to: home)                           // base paths
        p.addLine(to: first); p.addLine(to: second)
        p.addLine(to: third); p.closeSubpath()
        let reach = r.width * 0.5                   // foul lines
        p.move(to: home)
        p.addLine(to: CGPoint(x: home.x + reach, y: home.y - reach))
        p.move(to: home)
        p.addLine(to: CGPoint(x: home.x - reach, y: home.y - reach))
        let mound = CGPoint(x: home.x, y: home.y - b)
        p.addEllipse(in: CGRect(x: mound.x-4, y: mound.y-4, width: 8, height: 8))
        return p
    }
}

struct DiamondSurface: View {
    var body: some View {
        ZStack {
            Color(hex: "368a4f")                            // outfield grass
            DiamondMarkings().fill(Color(hex: "b06a37"))    // clay skin
            DiamondMarkings().stroke(.white.opacity(0.9), lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct DiamondBoardView: View {
    let isMini: Bool
    var body: some View { CatalogueBoard(isMini: isMini) { DiamondSurface() } }
}

// MARK: - Court (basketball)

struct CourtMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        let cc = r.height * 0.255                  // centre circle
        p.addEllipse(in: CGRect(x: r.midX-cc, y: r.midY-cc, width: cc*2, height: cc*2))
        let lw = r.width*0.18, lh = r.height*0.38  // the key
        for far in [false, true] {
            let lx = far ? r.maxX - lw : r.minX
            p.addRect(CGRect(x: lx, y: r.midY-lh/2, width: lw, height: lh))
            let cx = far ? r.maxX - lw : r.minX + lw
            p.addEllipse(in: CGRect(x: cx-cc, y: r.midY-cc, width: cc*2, height: cc*2))
            let hoop = CGPoint(x: far ? r.maxX - r.width*0.045 : r.minX + r.width*0.045, y: r.midY)
            p.addArc(center: hoop, radius: r.height*0.46,   // 3-pt arc
                     startAngle: .degrees(far ? 122 : -58),
                     endAngle:   .degrees(far ? 238 : 58),
                     clockwise: far)
        }
        return p
    }
}

struct CourtSurface: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "d8a868"), Color(hex: "c9974f")],
                           startPoint: .top, endPoint: .bottom)
            CourtMarkings().stroke(Color(hex: "f4efe6"), lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CourtBoardView: View {
    let isMini: Bool
    var body: some View { CatalogueBoard(isMini: isMini) { CourtSurface() } }
}

// MARK: - Tennis

struct TennisMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)                               // doubles court
        let allyH = r.height * 0.137               // tramline inset
        p.move(to: CGPoint(x: r.minX, y: r.minY+allyH))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY+allyH))
        p.move(to: CGPoint(x: r.minX, y: r.maxY-allyH))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY-allyH))
        let svc = r.width * 0.232                   // service line inset
        p.move(to: CGPoint(x: r.minX+svc, y: r.minY+allyH))
        p.addLine(to: CGPoint(x: r.minX+svc, y: r.maxY-allyH))
        p.move(to: CGPoint(x: r.maxX-svc, y: r.minY+allyH))
        p.addLine(to: CGPoint(x: r.maxX-svc, y: r.maxY-allyH))
        p.move(to: CGPoint(x: r.minX+svc, y: r.midY)) // centre service
        p.addLine(to: CGPoint(x: r.maxX-svc, y: r.midY))
        p.move(to: CGPoint(x: r.midX, y: r.minY-r.height*0.04)) // net
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY+r.height*0.04))
        return p
    }
}

struct TennisSurface: View {
    var body: some View {
        ZStack {
            Color(hex: "2f6db0")                            // acrylic blue
            TennisMarkings().stroke(.white.opacity(0.95), lineWidth: 2)
        }
        .padding(.horizontal, 24)                           // run-off margin
        .background(Color(hex: "2f7d49"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TennisBoardView: View {
    let isMini: Bool
    var body: some View { CatalogueBoard(isMini: isMini) { TennisSurface() } }
}

// MARK: - Volleyball

struct VolleyMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)
        p.move(to: CGPoint(x: r.midX, y: r.minY))  // centre / net line
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        let atk = r.width * 0.167                   // 3 m attack line
        p.move(to: CGPoint(x: r.midX-atk, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX-atk, y: r.maxY))
        p.move(to: CGPoint(x: r.midX+atk, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX+atk, y: r.maxY))
        return p
    }
}

struct VolleySurface: View {
    var body: some View {
        ZStack {
            Color(hex: "d89b54")                            // resin court
            VolleyMarkings().stroke(Color(hex: "f4efe6"), lineWidth: 2.4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct VolleyBoardView: View {
    let isMini: Bool
    var body: some View { CatalogueBoard(isMini: isMini) { VolleySurface() } }
}

// MARK: - Handball

struct HandballMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        let six = r.height * 0.5                    // 6 m goal-area
        let nine = r.height * 0.7                   // 9 m free-throw
        for far in [false, true] {
            let gx = far ? r.maxX : r.minX
            let goal = CGPoint(x: gx, y: r.midY)
            p.addArc(center: goal, radius: six,
                     startAngle: .degrees(far ? 90 : -90),
                     endAngle:   .degrees(far ? 270 : 90),
                     clockwise: far)
            p.addArc(center: goal, radius: nine,
                     startAngle: .degrees(far ? 90 : -90),
                     endAngle:   .degrees(far ? 270 : 90),
                     clockwise: far)
        }
        return p
    }
}

struct HandballSurface: View {
    var body: some View {
        ZStack {
            Color(hex: "3f7cae")                            // play surface
            HandballMarkings().stroke(Color(hex: "f4efe6"), lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct HandballBoardView: View {
    let isMini: Bool
    var body: some View { CatalogueBoard(isMini: isMini) { HandballSurface() } }
}

// MARK: - Futsal

struct FutsalMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        let cc = r.height * 0.19
        p.addEllipse(in: CGRect(x: r.midX-cc, y: r.midY-cc, width: cc*2, height: cc*2))
        let arc = r.height * 0.28                   // 6 m penalty arc
        for far in [false, true] {
            let gx = far ? r.maxX : r.minX
            p.addArc(center: CGPoint(x: gx, y: r.midY), radius: arc,
                     startAngle: .degrees(far ? 90 : -90),
                     endAngle:   .degrees(far ? 270 : 90),
                     clockwise: far)
        }
        return p
    }
}

struct FutsalSurface: View {
    var body: some View {
        ZStack {
            Color(hex: "3a945a")                            // indoor turf
            FutsalMarkings().stroke(Color(hex: "f4efe6"), lineWidth: 2.4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FutsalBoardView: View {
    let isMini: Bool
    var body: some View { CatalogueBoard(isMini: isMini) { FutsalSurface() } }
}

// MARK: - Rink (ice hockey)

struct RinkMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let radius = r.height * 0.37               // rounded corners
        p.addRoundedRect(in: r, cornerSize: CGSize(width: radius, height: radius))
        p.move(to: CGPoint(x: r.midX, y: r.minY))  // centre line
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        for bx in [r.width*0.275, r.width*0.725] {  // blue lines
            p.move(to: CGPoint(x: r.minX+bx, y: r.minY))
            p.addLine(to: CGPoint(x: r.minX+bx, y: r.maxY))
        }
        p.addEllipse(in: CGRect(x: r.midX-22, y: r.midY-22, width: 44, height: 44))
        let fx = r.width*0.18, fy = r.height*0.26   // 4 face-off dots
        for sx in [r.minX+fx, r.maxX-fx] {
            for sy in [r.midY-fy, r.midY+fy] {
                p.addEllipse(in: CGRect(x: sx-15, y: sy-15, width: 30, height: 30))
            }
        }
        return p
    }
}

struct RinkSurface: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "eaf3fb"), Color(hex: "d4e6f4")],
                           startPoint: .top, endPoint: .bottom)
            RinkMarkings().stroke(Color(hex: "c0392b"), lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 40))
    }
}

struct RinkBoardView: View {
    let isMini: Bool
    var body: some View { CatalogueBoard(isMini: isMini) { RinkSurface() } }
}

// MARK: - Pool table (vector)

struct PoolTableSurface: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)            // wood rail
                .fill(Color(hex: "5a3416"))
            RoundedRectangle(cornerRadius: 4)             // baize
                .fill(LinearGradient(
                    colors: [Color(hex: "1f7a52"), Color(hex: "176544")],
                    startPoint: .top, endPoint: .bottom))
                .padding(20)
            GeometryReader { g in
                let w = g.size.width, h = g.size.height
                ForEach(pockets(w, h), id: \.self) { pt in
                    Circle().fill(Color(hex: "3a2410"))
                        .frame(width: 16, height: 16).position(pt)
                }
                Circle().fill(.white)                     // foot spot
                    .frame(width: 5).position(x: w*0.29, y: h*0.5)
            }
        }
    }
    func pockets(_ w: CGFloat, _ h: CGFloat) -> [CGPoint] {
        [CGPoint(x: 14, y: 14), CGPoint(x: w/2, y: 9),
         CGPoint(x: w-14, y: 14), CGPoint(x: 14, y: h-14),
         CGPoint(x: w/2, y: h-9), CGPoint(x: w-14, y: h-14)]
    }
}

struct PoolTableBoardView: View {
    let isMini: Bool
    var body: some View { CatalogueBoard(isMini: isMini) { PoolTableSurface() } }
}
