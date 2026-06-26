struct OverlapRun: Shape {
    var from: CGPoint, to: CGPoint
    var bow: CGFloat = 70
    func path(in r: CGRect) -> Path {
        let mid = CGPoint(x: (from.x + to.x) / 2,
                          y: (from.y + to.y) / 2)
        let nx = -(to.y - from.y), ny = to.x - from.x
        let len = max(hypot(nx, ny), 1)
        let c = CGPoint(x: mid.x + nx / len * bow,
                        y: mid.y + ny / len * bow)
        var p = Path()
        p.move(to: from)
        p.addQuadCurve(to: to, control: c)
        return p
    }
}

OverlapRun(from: CGPoint(x: 50, y: 160),
           to:   CGPoint(x: 230, y: 70))
    .stroke(.white, style: StrokeStyle(
        lineWidth: 2.6, dash: [7, 7]))