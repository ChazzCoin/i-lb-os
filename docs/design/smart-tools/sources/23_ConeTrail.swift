func conePositions(from a: CGPoint, to b: CGPoint,
                   spacing: CGFloat = 34) -> [CGPoint] {
    let len = hypot(b.x - a.x, b.y - a.y)
    let n = max(1, Int(len / spacing))
    return (0...n).map { i in
        let t = CGFloat(i) / CGFloat(n)
        return CGPoint(x: a.x + (b.x - a.x) * t,
                       y: a.y + (b.y - a.y) * t)
    }
}

struct ConeTrail: View {
    var a: CGPoint, b: CGPoint
    var body: some View {
        ForEach(Array(conePositions(from: a, to: b)
            .enumerated()), id: \.offset) { _, p in
            Image(systemName: "triangle.fill")
                .font(.system(size: 12))
                .foregroundStyle(Brand.lime)
                .position(p)
        }
    }
}