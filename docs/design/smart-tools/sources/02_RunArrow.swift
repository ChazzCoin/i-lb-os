struct RunArrow: View {
    var from: CGPoint, to: CGPoint
    var color: Color = .white
    var body: some View {
        PassArrow(from: from, to: to)
            .stroke(color, style: StrokeStyle(
                lineWidth: 2.6, lineCap: .round,
                lineJoin: .round, dash: [7, 7]))
    }
}

// Usage — a vertical run into space
RunArrow(from: CGPoint(x: 60, y: 40),
         to:   CGPoint(x: 60, y: 210))