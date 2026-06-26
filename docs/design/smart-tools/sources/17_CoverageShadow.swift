func convexHull(_ pts: [CGPoint]) -> [CGPoint] {
    let s = pts.sorted {
        $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x }
    func cross(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
        (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
    }
    var lower = [CGPoint]()
    for p in s {
        while lower.count >= 2 &&
              cross(lower[lower.count-2], lower.last!, p) <= 0 {
            lower.removeLast() }
        lower.append(p)
    }
    var upper = [CGPoint]()
    for p in s.reversed() {
        while upper.count >= 2 &&
              cross(upper[upper.count-2], upper.last!, p) <= 0 {
            upper.removeLast() }
        upper.append(p)
    }
    return Array(lower.dropLast() + upper.dropLast())
}

struct CoverageShadow: View {
    var players: [CGPoint]
    var body: some View {
        PolyShape(points: convexHull(players))
            .fill(Brand.teal.opacity(0.22))
    }
}