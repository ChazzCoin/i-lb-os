struct TennisMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)                               // doubles court
        let allyW = r.width * 0.0
        let allyH = r.height * 0.137               // tramline inset
        p.move(to: CGPoint(x: r.minX, y: r.minY+allyH))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY+allyH))
        p.move(to: CGPoint(x: r.minX, y: r.maxY-allyH))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY-allyH))
        let svc = r.width * 0.232                   // service line inset
        p.move(to: CGPoint(x: r.minX+svc, y: r.minY+allyH))
        p.addLine(to: CGPoint(x: r.minX+svc, y: r.maxY-allyH))
        p.move(to: CGPoint(x: r.maxX-svc, y: r.minY+allyH))
        p.addLine(to: CGPoint(x: r.maxX-svc, y: r.maxY-allyH))
        p.move(to: CGPoint(x: r.minX+svc, y: r.midY)) // centre service
        p.addLine(to: CGPoint(x: r.maxX-svc, y: r.midY))
        p.move(to: CGPoint(x: r.midX, y: r.minY-r.height*0.04)) // net
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY+r.height*0.04))
        return p
    }
}

ZStack {
    Color(hex: "2f6db0")                            // acrylic blue
    TennisMarkings().stroke(.white.opacity(0.95), lineWidth: 2)
}
.aspectRatio(23.77/10.97, contentMode: .fit)
.padding(.horizontal, 24)                           // run-off margin
.background(Color(hex: "2f7d49"))
.clipShape(RoundedRectangle(cornerRadius: 12))