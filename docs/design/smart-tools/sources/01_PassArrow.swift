struct PassArrow: Shape {
    var from: CGPoint, to: CGPoint
    var head: CGFloat = 12
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: from); p.addLine(to: to)
        let a = atan2(to.y - from.y, to.x - from.x)
        for s in [a + .pi - 0.5, a + .pi + 0.5] {
            p.move(to: to)
            p.addLine(to: CGPoint(x: to.x + cos(s) * head,
                                  y: to.y + sin(s) * head))
        }
        return p
    }
}

// Usage — a forward pass
PassArrow(from: CGPoint(x: 40, y: 80),
          to:   CGPoint(x: 230, y: 120))
    .stroke(Brand.lime, style: StrokeStyle(
        lineWidth: 3, lineCap: .round, lineJoin: .round))