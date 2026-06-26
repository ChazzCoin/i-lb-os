struct PolyShape: Shape {
    var points: [CGPoint]
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addLines(points)
        p.closeSubpath()
        return p
    }
}

struct PressingTriangle: View {
    var points: [CGPoint]
    var tint: Color = Brand.danger
    var body: some View {
        PolyShape(points: points)
            .fill(tint.opacity(0.18))
            .overlay(PolyShape(points: points)
                .stroke(tint.opacity(0.8), lineWidth: 1.6))
    }
}

PressingTriangle(points: [CGPoint(x: 60, y: 40),
                          CGPoint(x: 200, y: 70),
                          CGPoint(x: 110, y: 180)])