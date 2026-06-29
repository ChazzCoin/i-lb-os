struct CourtMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        let cc = r.height * 0.255                  // centre circle
        p.addEllipse(in: CGRect(x: r.midX-cc, y: r.midY-cc,
                                width: cc*2, height: cc*2))
        let lw = r.width*0.18, lh = r.height*0.38  // the key
        for far in [false, true] {
            let lx = far ? r.maxX - lw : r.minX
            p.addRect(CGRect(x: lx, y: r.midY-lh/2, width: lw, height: lh))
            let cx = far ? r.maxX - lw : r.minX + lw
            p.addEllipse(in: CGRect(x: cx-cc, y: r.midY-cc,
                                    width: cc*2, height: cc*2))
            let hoop = CGPoint(
                x: far ? r.maxX - r.width*0.045 : r.minX + r.width*0.045,
                y: r.midY)
            p.addArc(center: hoop, radius: r.height*0.46,   // 3-pt arc
                     startAngle: .degrees(far ? 122 : -58),
                     endAngle:   .degrees(far ? 238 : 58),
                     clockwise: far)
        }
        return p
    }
}

ZStack {
    LinearGradient(colors: [Color(hex: "d8a868"), Color(hex: "c9974f")],
                   startPoint: .top, endPoint: .bottom)
    CourtMarkings().stroke(Color(hex: "f4efe6"), lineWidth: 2)
}
.aspectRatio(28.0/15.0, contentMode: .fit)
.clipShape(RoundedRectangle(cornerRadius: 12))