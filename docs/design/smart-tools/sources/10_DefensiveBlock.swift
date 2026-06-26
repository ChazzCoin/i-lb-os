struct DefensiveBlock: View {
    var players: [CGPoint]      // sorted left → right
    var depth: CGFloat = 26
    var body: some View {
        Path { p in
            guard let f = players.first else { return }
            p.move(to: f)
            players.dropFirst().forEach { p.addLine(to: $0) }
        }
        .stroke(Brand.teal, style: StrokeStyle(
            lineWidth: depth, lineCap: .round, lineJoin: .round))
        .opacity(0.45)
        .blur(radius: 2)
    }
}

DefensiveBlock(players: [CGPoint(x: 40, y: 120),
                         CGPoint(x: 110, y: 110),
                         CGPoint(x: 180, y: 114),
                         CGPoint(x: 250, y: 122)])