struct FutsalMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        let cc = r.height * 0.19
        p.addEllipse(in: CGRect(x: r.midX-cc, y: r.midY-cc,
                                width: cc*2, height: cc*2))
        let arc = r.height * 0.28                   // 6 m penalty arc
        for far in [false, true] {
            let gx = far ? r.maxX : r.minX
            p.addArc(center: CGPoint(x: gx, y: r.midY), radius: arc,
                     startAngle: .degrees(far ? 90 : -90),
                     endAngle:   .degrees(far ? 270 : 90),
                     clockwise: far)
        }
        return p
    }
}

ZStack {
    Color(hex: "3a945a")                            // indoor turf
    FutsalMarkings().stroke(Color(hex: "f4efe6"), lineWidth: 2.4)
}
.aspectRatio(2.0, contentMode: .fit)
.clipShape(RoundedRectangle(cornerRadius: 12))