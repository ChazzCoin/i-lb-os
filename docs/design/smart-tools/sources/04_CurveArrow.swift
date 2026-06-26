struct CurveArrow: View {
    var start: CGPoint, end: CGPoint
    @State private var control: CGPoint
    init(start: CGPoint, end: CGPoint) {
        self.start = start; self.end = end
        _control = State(initialValue: CGPoint(
            x: (start.x + end.x) / 2,
            y: min(start.y, end.y) - 60))
    }
    var body: some View {
        ZStack {
            Path { p in
                p.move(to: start)
                p.addQuadCurve(to: end, control: control)
            }
            .stroke(Brand.lime, style: StrokeStyle(
                lineWidth: 3, lineCap: .round))
            Circle().fill(.white).frame(width: 16, height: 16)
                .position(control)
                .gesture(DragGesture()
                    .onChanged { control = $0.location })
        }
    }
}