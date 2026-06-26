struct AngleTool: View {
    var vertex: CGPoint, p1: CGPoint, p2: CGPoint
    var body: some View {
        let a1 = atan2(p1.y - vertex.y, p1.x - vertex.x)
        let a2 = atan2(p2.y - vertex.y, p2.x - vertex.x)
        let deg = abs(a1 - a2) * 180 / .pi
        ZStack {
            Path { p in
                p.move(to: p1); p.addLine(to: vertex)
                p.addLine(to: p2)
            }.stroke(.white, lineWidth: 2)
            Path { p in
                p.addArc(center: vertex, radius: 26,
                         startAngle: .radians(a1),
                         endAngle: .radians(a2), clockwise: false)
            }.stroke(Brand.lime, lineWidth: 2)
            Text("\(Int(deg))°")
                .font(AppFont.mono(11)).foregroundStyle(Brand.lime)
                .position(x: vertex.x + 42, y: vertex.y)
        }
    }
}