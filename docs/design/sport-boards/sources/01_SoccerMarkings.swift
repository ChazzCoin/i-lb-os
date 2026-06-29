struct SoccerMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        let cr = r.height * 0.18
        p.addEllipse(in: CGRect(x: r.midX - cr, y: r.midY - cr,
                                width: cr*2, height: cr*2))
        let bw = r.width*0.16, bh = r.height*0.58       // penalty box
        let gw = r.width*0.055, gh = r.height*0.28      // goal box
        for far in [false, true] {
            let bx = far ? r.maxX - bw : r.minX
            let gx = far ? r.maxX - gw : r.minX
            p.addRect(CGRect(x: bx, y: r.midY-bh/2, width: bw, height: bh))
            p.addRect(CGRect(x: gx, y: r.midY-gh/2, width: gw, height: gh))
            let spot = far ? r.maxX - bw*0.66 : r.minX + bw*0.66
            p.addEllipse(in: CGRect(x: spot-1.4, y: r.midY-1.4,
                                    width: 2.8, height: 2.8))
        }
        return p
    }
}

ZStack {
    LinearGradient(colors: [Color(hex: "3c9a5c"), Color(hex: "2c7e45")],
                   startPoint: .top, endPoint: .bottom)
    SoccerMarkings().stroke(.white.opacity(0.9), lineWidth: 2)
}
.aspectRatio(105.0/68.0, contentMode: .fit)
.clipShape(RoundedRectangle(cornerRadius: 12))