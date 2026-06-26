struct AgilityLadder: Shape {
    var origin: CGPoint
    var angle: CGFloat = 0
    var rungs: Int = 6, width: CGFloat = 40, step: CGFloat = 26
    func path(in r: CGRect) -> Path {
        var p = Path()
        let dx = cos(angle), dy = sin(angle)   // along
        let nx = -dy, ny = dx                  // across
        func pt(_ a: CGFloat, _ c: CGFloat) -> CGPoint {
            CGPoint(x: origin.x + dx * a + nx * c,
                    y: origin.y + dy * a + ny * c)
        }
        let L = step * CGFloat(rungs)
        p.move(to: pt(0, -width/2)); p.addLine(to: pt(L, -width/2))
        p.move(to: pt(0,  width/2)); p.addLine(to: pt(L,  width/2))
        for i in 0...rungs {
            p.move(to: pt(step * CGFloat(i), -width/2))
            p.addLine(to: pt(step * CGFloat(i), width/2))
        }
        return p
    }
}

AgilityLadder(origin: CGPoint(x: 40, y: 60), angle: .pi/8)
    .stroke(.white.opacity(0.8), lineWidth: 2)