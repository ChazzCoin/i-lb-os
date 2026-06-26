struct DistanceTool: View {
    var a: CGPoint, b: CGPoint
    var metresPerPoint: CGFloat = 0.1
    var body: some View {
        let d = hypot(b.x - a.x, b.y - a.y) * metresPerPoint
        ZStack {
            Path { p in p.move(to: a); p.addLine(to: b) }
                .stroke(Brand.lime, style: StrokeStyle(
                    lineWidth: 2, dash: [4, 4]))
            Text(String(format: "%.1f m", d))
                .font(AppFont.mono(11))
                .foregroundStyle(Brand.limeInk)
                .padding(.horizontal, 7).padding(.vertical, 3)
                .background(Brand.lime, in: Capsule())
                .position(x: (a.x + b.x) / 2,
                          y: (a.y + b.y) / 2)
        }
    }
}