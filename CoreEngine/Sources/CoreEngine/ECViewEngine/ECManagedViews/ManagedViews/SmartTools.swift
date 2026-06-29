//
//  SmartTools.swift
//  CoreEngine — Smart Tools (tactical) catalogue, Tier 1
//
//  Thirteen coaching-board tools imported from the Smart Tool Catalogue and
//  wired to the engine. Each is rendered in ABSOLUTE board space by the single
//  `SmartToolManaged` dispatcher, which reads geometry from the tool's
//  ManagedView (start / center / end points, colour, width) and switches on
//  `subToolType`. Catalogue constants were screen-scale (~300pt canvas); the
//  board is ~5000–6000 units at ~0.1 scale, so strokes/decorations are scaled
//  up ~8× off the tool's stroke width `w`.
//
//  Source: docs/design/smart-tools/ (Smart Tool Catalogue handoff).
//

import SwiftUI
import RealmSwift

// MARK: - Pure shapes (geometry only — scale comes from the stroke/params)

public struct PassArrow: Shape {
    public var from: CGPoint, to: CGPoint, head: CGFloat
    public init(from: CGPoint, to: CGPoint, head: CGFloat = 12) {
        self.from = from; self.to = to; self.head = head
    }
    public func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: from); p.addLine(to: to)
        let a = atan2(to.y - from.y, to.x - from.x)
        for s in [a + .pi - 0.5, a + .pi + 0.5] {
            p.move(to: to)
            p.addLine(to: CGPoint(x: to.x + cos(s) * head, y: to.y + sin(s) * head))
        }
        return p
    }
}

public struct DribbleArrow: Shape {
    public var from: CGPoint, to: CGPoint, amp: CGFloat, wave: CGFloat
    public init(from: CGPoint, to: CGPoint, amp: CGFloat = 7, wave: CGFloat = 18) {
        self.from = from; self.to = to; self.amp = amp; self.wave = wave
    }
    public func path(in r: CGRect) -> Path {
        var p = Path()
        let len = hypot(to.x - from.x, to.y - from.y)
        let a = atan2(to.y - from.y, to.x - from.x)
        let n = max(2, Int(len / wave))
        p.move(to: from)
        for i in 1...n {
            let t = CGFloat(i) / CGFloat(n)
            let off = sin(t * .pi * CGFloat(n)) * amp
            p.addLine(to: CGPoint(x: from.x + cos(a) * len * t - sin(a) * off,
                                  y: from.y + sin(a) * len * t + cos(a) * off))
        }
        return p
    }
}

public struct OverlapRun: Shape {
    public var from: CGPoint, to: CGPoint, bow: CGFloat
    public init(from: CGPoint, to: CGPoint, bow: CGFloat = 70) {
        self.from = from; self.to = to; self.bow = bow
    }
    public func path(in r: CGRect) -> Path {
        let mid = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
        let nx = -(to.y - from.y), ny = to.x - from.x
        let len = max(hypot(nx, ny), 1)
        let c = CGPoint(x: mid.x + nx / len * bow, y: mid.y + ny / len * bow)
        var p = Path()
        p.move(to: from); p.addQuadCurve(to: to, control: c)
        return p
    }
}

public struct AgilityLadder: Shape {
    public var origin: CGPoint, angle: CGFloat
    public var rungs: Int, width: CGFloat, step: CGFloat
    public init(origin: CGPoint, angle: CGFloat = 0, rungs: Int = 6, width: CGFloat = 40, step: CGFloat = 26) {
        self.origin = origin; self.angle = angle; self.rungs = rungs; self.width = width; self.step = step
    }
    public func path(in r: CGRect) -> Path {
        var p = Path()
        let dx = cos(angle), dy = sin(angle), nx = -sin(angle), ny = cos(angle)
        func pt(_ a: CGFloat, _ c: CGFloat) -> CGPoint {
            CGPoint(x: origin.x + dx * a + nx * c, y: origin.y + dy * a + ny * c)
        }
        let L = step * CGFloat(rungs)
        p.move(to: pt(0, -width/2)); p.addLine(to: pt(L, -width/2))
        p.move(to: pt(0,  width/2)); p.addLine(to: pt(L,  width/2))
        for i in 0...rungs {
            p.move(to: pt(step * CGFloat(i), -width/2)); p.addLine(to: pt(step * CGFloat(i), width/2))
        }
        return p
    }
}

// MARK: - Self-contained views (board-scaled via params)

public struct ZoneRect: View {
    public var rect: CGRect, tint: Color, scale: CGFloat
    public init(rect: CGRect, tint: Color = Color.brandLime, scale: CGFloat = 8) {
        self.rect = rect; self.tint = tint; self.scale = scale
    }
    public var body: some View {
        RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
            .fill(tint.opacity(0.16))
            .overlay(RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                .strokeBorder(tint.opacity(0.7), style: StrokeStyle(lineWidth: 1.5 * scale, dash: [6 * scale, 5 * scale])))
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}

public struct Spotlight: View {
    public var focus: CGPoint, radius: CGFloat
    public init(focus: CGPoint, radius: CGFloat = 70) { self.focus = focus; self.radius = radius }
    public var body: some View {
        Rectangle().fill(.black.opacity(0.6))
            .mask {
                Rectangle().overlay(
                    Circle().frame(width: radius * 2, height: radius * 2)
                        .position(focus).blendMode(.destinationOut)).compositingGroup()
            }
            .allowsHitTesting(false)
    }
}

public struct FocusRing: View {
    public var center: CGPoint, size: CGFloat, lineWidth: CGFloat
    @State private var pulse = false
    public init(center: CGPoint, size: CGFloat = 40, lineWidth: CGFloat = 2.5) {
        self.center = center; self.size = size; self.lineWidth = lineWidth
    }
    public var body: some View {
        Circle().stroke(Color.brandLime, lineWidth: lineWidth)
            .frame(width: size, height: size)
            .scaleEffect(pulse ? 1.4 : 1).opacity(pulse ? 0 : 1)
            .position(center)
            .onAppear { withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) { pulse = true } }
    }
}

public struct StatRing: View {
    public var value: Double, size: CGFloat, color: Color
    public init(value: Double, size: CGFloat = 42, color: Color = Color.brandLime) {
        self.value = value; self.size = size; self.color = color
    }
    public var body: some View {
        Circle().stroke(.white.opacity(0.12), lineWidth: size * 0.07)
            .overlay(Circle().trim(from: 0, to: value)
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round))
                .rotationEffect(.degrees(-90)))
            .frame(width: size, height: size)
    }
}

public struct StatBadge: View {
    public var number: Int, stamina: Double, size: CGFloat
    public init(number: Int, stamina: Double = 0.72, size: CGFloat = 34) {
        self.number = number; self.stamina = stamina; self.size = size
    }
    public var body: some View {
        Text("\(number)")
            .font(.system(size: size * 0.44, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(LinearGradient(colors: [Color.brandHomeTop, Color.brandHomeBot], startPoint: .top, endPoint: .bottom), in: Circle())
            .overlay(Circle().strokeBorder(.white.opacity(0.3), lineWidth: size * 0.04))
            .padding(size * 0.12)
            .background(StatRing(value: stamina, size: size * 1.24))
    }
}

// MARK: - The engine-wired dispatcher

/// Renders any Tier-1 Smart Tool from its ManagedView. Geometry lives in three
/// board-space points: start, center (control/vertex), end. Drag to move, double
/// tap to select, long-press to delete; start/end anchors show when selected.
public struct SmartToolManaged: View {
    @State public var viewId: String
    @State public var activityId: String
    public init(viewId: String, activityId: String) { self.viewId = viewId; self.activityId = activityId }

    @StateObject public var MVO: ManagedViewObject = ManagedViewObject()
    @State private var subType: String = ""
    @State private var jersey: Int = 0
    @State private var dragOrigin: (CGPoint, CGPoint, CGPoint)? = nil

    private var start: CGPoint { CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY) }
    private var end: CGPoint { CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY) }
    private var control: CGPoint { CGPoint(x: MVO.lifeCenterX, y: MVO.lifeCenterY) }
    private var color: Color { MVO.lifeColor }

    // Board-space tuning (TASK-023). `w` is the stroke width all decorations
    // scale off; clamped so an over-large width can't blow a tool up.
    private static let minStroke: CGFloat = 26
    private static let maxStroke: CGFloat = 140
    private static let boardHeight: CGFloat = 6000   // matches BEO.boardHeight; full-height verticals
    private static let metresPerUnit: CGFloat = 0.02 // board-units → display metres
    private var w: CGFloat { min(max(MVO.lifeWidth, Self.minStroke), Self.maxStroke) }
    private var selected: Bool { MVO.selectedManagedViewId == viewId }

    public var body: some View {
        ZStack {
            // Single-point tools have no anchors, so give them a visible lime
            // selection halo (TASK-021); 2-point tools show their anchors instead.
            if selected, !twoPoint {
                Circle().stroke(Color.brandLime.opacity(0.9), lineWidth: w * 0.6)
                    .frame(width: w * 11, height: w * 11)
                    .position(start)
            }
            shape
            // TASK-050: overlay / single-point tools (spotlight, focus ring,
            // offside line, ladder, stat badge) have a non-hittable or thin body
            // — the spotlight's dim overlay is `.allowsHitTesting(false)` — so
            // taps, the whole-tool move gesture, and long-press-to-delete never
            // land and the tool gets stuck on the board, unselectable. Give them
            // an always-hittable handle at their anchor so they can be selected,
            // moved, and deleted like any other tool. (2-point tools already have
            // draggable anchors + a hittable stroked body.)
            if !twoPoint {
                Circle()
                    .fill(Color.white.opacity(0.02))
                    .frame(width: w * 5, height: w * 5)
                    .contentShape(Circle())
                    .position(start)
            }
            if selected { anchors }
        }
        .opacity(MVO.isDeletedChecker() ? 0 : 1)
        // Whole-tool move is a plain gesture so the per-anchor highPriorityGestures
        // win when a drag starts on an anchor (TASK-020); it still beats the
        // ancestor canvas-pan because tool gestures are deeper in the hierarchy.
        .gesture(moveGesture)
        // Single-tap select (TASK-015/021): idempotent, opens Properties.
        .simultaneousGesture(TapGesture(count: 1).onEnded { MVO.selectTool() })
        .simultaneousGesture(TapGesture(count: 2).onEnded { MVO.selectTool() })
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.4).onEnded { _ in MVO.showDeleteAlert = true })
        .alertConfirm(isPresented: $MVO.showDeleteAlert, title: "Delete?", message: "Delete this tool?", action: { MVO.deleteTool() })
        .onAppear {
            MVO.initializeWithViewId(viewId: viewId)
            if let mv = MVO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId) {
                subType = mv.subToolType; jersey = mv.jerseyNumber
            }
        }
    }

    @ViewBuilder private var shape: some View {
        switch subType {
        case "tactic_pass_arrow":
            PassArrow(from: start, to: end, head: w * 2.6)
                .stroke(color, style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round))
        case "tactic_run_arrow":
            PassArrow(from: start, to: end, head: w * 2.6)
                .stroke(color, style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round, dash: [w * 2.4, w * 2.4]))
        case "tactic_dribble_arrow":
            DribbleArrow(from: start, to: end, amp: w * 1.8, wave: w * 4.5)
                .stroke(color, style: StrokeStyle(lineWidth: w, lineCap: .round))
        case "tactic_overlap_run":
            OverlapRun(from: start, to: end, bow: max(hypot(end.x - start.x, end.y - start.y) * 0.28, w * 10))
                .stroke(color, style: StrokeStyle(lineWidth: w, lineCap: .round, dash: [w * 2.4, w * 2.4]))
        case "tactic_curve_arrow":
            Path { p in p.move(to: start); p.addQuadCurve(to: end, control: control) }
                .stroke(color, style: StrokeStyle(lineWidth: w, lineCap: .round))
        case "tactic_distance_tool":
            distanceTool
        case "tactic_angle_tool":
            angleTool
        case "tactic_zone_rect":
            ZoneRect(rect: rectFromCorners(start, end), tint: color, scale: w * 0.35)
        case "tactic_offside_line":
            offsideLine
        case "tactic_spotlight":
            Spotlight(focus: start, radius: max(w * 10, 420))
        case "tactic_focus_ring":
            FocusRing(center: start, size: w * 9, lineWidth: w * 0.7)
        case "tactic_agility_ladder":
            AgilityLadder(origin: start, angle: MVO.lifeRotation.radians,
                          rungs: 6, width: w * 9, step: w * 7)
                .stroke(color, style: StrokeStyle(lineWidth: w * 0.5, lineCap: .round))
        case "tactic_stat_badge":
            StatBadge(number: jersey, stamina: 0.72, size: w * 9).position(start)
        default:
            EmptyView()
        }
    }

    // Inline board-scaled composites
    private var distanceTool: some View {
        let metres = hypot(end.x - start.x, end.y - start.y) * Self.metresPerUnit
        return ZStack {
            Path { p in p.move(to: start); p.addLine(to: end) }
                .stroke(color, style: StrokeStyle(lineWidth: w * 0.6, dash: [w * 1.4, w * 1.4]))
            Text(String(format: "%.1f m", metres))
                .font(.system(size: w * 2.2, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.brandLimeInk)
                .padding(.horizontal, w * 1.2).padding(.vertical, w * 0.5)
                .background(color, in: Capsule())
                .position(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        }
    }

    private var angleTool: some View {
        let v = control, p1 = start, p2 = end
        let a1 = atan2(p1.y - v.y, p1.x - v.x), a2 = atan2(p2.y - v.y, p2.x - v.x)
        let deg = abs(a1 - a2) * 180 / .pi
        return ZStack {
            Path { p in p.move(to: p1); p.addLine(to: v); p.addLine(to: p2) }
                .stroke(.white, lineWidth: w * 0.6)
            Path { p in p.addArc(center: v, radius: max(hypot(p1.x - v.x, p1.y - v.y) * 0.4, w * 4),
                                 startAngle: .radians(a1), endAngle: .radians(a2), clockwise: false) }
                .stroke(color, lineWidth: w * 0.6)
            Text("\(Int(deg))°").font(.system(size: w * 2.2, weight: .medium, design: .monospaced))
                .foregroundStyle(color)
                .position(x: v.x + w * 4, y: v.y)
        }
    }

    private var offsideLine: some View {
        let h = Self.boardHeight
        return Rectangle().fill(Color.brandDanger)
            .frame(width: w * 0.7, height: h)
            .overlay(alignment: .top) {
                Text("OFFSIDE").font(.system(size: w * 1.8, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, w).padding(.vertical, w * 0.3)
                    .background(Color.brandDanger, in: Capsule())
            }
            .position(x: start.x, y: h / 2)
    }

    private func rectFromCorners(_ a: CGPoint, _ b: CGPoint) -> CGRect {
        CGRect(x: min(a.x, b.x), y: min(a.y, b.y), width: abs(b.x - a.x), height: abs(b.y - a.y))
    }

    // Start/end (+ control) anchors for editing 2/3-point tools
    private var twoPoint: Bool {
        !["tactic_offside_line", "tactic_spotlight", "tactic_focus_ring",
          "tactic_agility_ladder", "tactic_stat_badge"].contains(subType)
    }
    private var threePoint: Bool { ["tactic_curve_arrow", "tactic_angle_tool"].contains(subType) }

    @ViewBuilder private var anchors: some View {
        if twoPoint {
            anchor(start) { p in MVO.lifeStartX = p.x; MVO.lifeStartY = p.y; persist() }
            anchor(end)   { p in MVO.lifeEndX = p.x; MVO.lifeEndY = p.y; persist() }
            if threePoint {
                // The bend/vertex point — editable, was previously frozen (TASK-020).
                anchor(control) { p in MVO.lifeCenterX = p.x; MVO.lifeCenterY = p.y; persist() }
            }
        }
    }
    private func anchor(_ at: CGPoint, _ onMove: @escaping (CGPoint) -> Void) -> some View {
        Circle().fill(Color.brandLime).frame(width: w * 2.2, height: w * 2.2)
            .position(at)
            // highPriority so an anchor drag wins over the whole-tool move (TASK-020).
            .highPriorityGesture(
                DragGesture()
                    .onChanged { g in
                        guard !MVO.lifeIsLocked else { return }
                        MVO.isDragging = true; MVO.ignoreUpdates = true
                        onMove(g.location)
                    }
                    .onEnded { _ in MVO.isDragging = false; MVO.ignoreUpdates = false }
            )
    }

    // Drag the whole tool. Sets isDragging/ignoreUpdates so a Realm observation
    // firing mid-drag doesn't reload persisted geometry and jump the tool (TASK-020).
    private var moveGesture: some Gesture {
        DragGesture()
            .onChanged { g in
                if MVO.lifeIsLocked { return }
                if dragOrigin == nil {
                    dragOrigin = (start, control, end)
                    MVO.isDragging = true; MVO.ignoreUpdates = true
                }
                guard let o = dragOrigin else { return }
                let dx = g.translation.width, dy = g.translation.height
                MVO.lifeStartX = o.0.x + dx; MVO.lifeStartY = o.0.y + dy
                MVO.lifeCenterX = o.1.x + dx; MVO.lifeCenterY = o.1.y + dy
                MVO.lifeEndX = o.2.x + dx; MVO.lifeEndY = o.2.y + dy
            }
            .onEnded { _ in
                MVO.isDragging = false; MVO.ignoreUpdates = false
                dragOrigin = nil; persist()
            }
    }

    private func persist() {
        MVO.realmInstance.safeWrite { _ in
            if let mv = MVO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId) {
                mv.startX = MVO.lifeStartX; mv.startY = MVO.lifeStartY
                mv.centerX = MVO.lifeCenterX; mv.centerY = MVO.lifeCenterY
                mv.endX = MVO.lifeEndX; mv.endY = MVO.lifeEndY
            }
        }
    }
}
