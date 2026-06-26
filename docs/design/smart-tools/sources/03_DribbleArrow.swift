struct DribbleArrow: Shape {
    var from: CGPoint, to: CGPoint
    var amp: CGFloat = 7, wave: CGFloat = 18
    func path(in r: CGRect) -> Path {
        var p = Path()
        let len = hypot(to.x - from.x, to.y - from.y)
        let a = atan2(to.y - from.y, to.x - from.x)
        let n = max(2, Int(len / wave))
        p.move(to: from)
        for i in 1...n {
            let t = CGFloat(i) / CGFloat(n)
            let off = sin(t * .pi * CGFloat(n)) * amp
            p.addLine(to: CGPoint(
                x: from.x + cos(a) * len * t - sin(a) * off,
                y: from.y + sin(a) * len * t + cos(a) * off))
        }
        return p
    }
}

DribbleArrow(from: CGPoint(x: 30, y: 120),
             to:   CGPoint(x: 250, y: 90))
    .stroke(Brand.lime, lineWidth: 3)