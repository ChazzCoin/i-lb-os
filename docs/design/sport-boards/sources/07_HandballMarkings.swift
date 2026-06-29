struct HandballMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        let six = r.height * 0.5                    // 6 m goal-area
        let nine = r.height * 0.7                   // 9 m free-throw
        for far in [false, true] {
            let gx = far ? r.maxX : r.minX
            let goal = CGPoint(x: gx, y: r.midY)
            p.addArc(center: goal, radius: six,
                     startAngle: .degrees(far ? 90 : -90),
                     endAngle:   .degrees(far ? 270 : 90),
                     clockwise: far)
            p.addArc(center: goal, radius: nine,
                     startAngle: .degrees(far ? 90 : -90),
                     endAngle:   .degrees(far ? 270 : 90),
                     clockwise: far)                // dash when stroked
        }
        return p
    }
}

ZStack {
    Color(hex: "3f7cae")                            // play surface
    HandballMarkings().stroke(Color(hex: "f4efe6"), lineWidth: 2)
}
.aspectRatio(40.0/20.0, contentMode: .fit)
.clipShape(RoundedRectangle(cornerRadius: 12))