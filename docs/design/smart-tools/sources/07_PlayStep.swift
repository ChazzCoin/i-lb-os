struct PlayStep: Identifiable {
    let id = UUID()
    var path: [CGPoint]
    var delay: Double
}

struct TimedSequence: View {
    var steps: [PlayStep]
    @State private var progress: CGFloat = 0
    var body: some View {
        ZStack {
            ForEach(steps) { step in
                Path { p in
                    guard let f = step.path.first else { return }
                    p.move(to: f)
                    step.path.dropFirst().forEach { p.addLine(to: $0) }
                }
                .trim(from: 0, to: progress)
                .stroke(Brand.lime, style: StrokeStyle(
                    lineWidth: 3, lineCap: .round))
                .animation(.easeInOut(duration: 0.8)
                    .delay(step.delay), value: progress)
            }
        }
        .onAppear { progress = 1 }
    }
}