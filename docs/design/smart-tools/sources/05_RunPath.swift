struct RunPath: View {
    var points: [CGPoint]
    @State private var phase: CGFloat = 0
    var body: some View {
        Path { p in
            guard let f = points.first else { return }
            p.move(to: f)
            points.dropFirst().forEach { p.addLine(to: $0) }
        }
        .stroke(Brand.lime, style: StrokeStyle(
            lineWidth: 2.8, lineCap: .round,
            dash: [9, 7], dashPhase: phase))
        .onAppear {
            withAnimation(.linear(duration: 0.6)
                .repeatForever(autoreverses: false)) {
                phase = -16
            }
        }
    }
}

RunPath(points: [CGPoint(x: 40, y: 180),
                 CGPoint(x: 120, y: 80),
                 CGPoint(x: 240, y: 120)])