struct RinkMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let radius = r.height * 0.37               // rounded corners
        p.addRoundedRect(in: r, cornerSize: CGSize(width: radius,
                                                   height: radius))
        p.move(to: CGPoint(x: r.midX, y: r.minY))  // centre line
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        for bx in [r.width*0.275, r.width*0.725] {  // blue lines
            p.move(to: CGPoint(x: r.minX+bx, y: r.minY))
            p.addLine(to: CGPoint(x: r.minX+bx, y: r.maxY))
        }
        p.addEllipse(in: CGRect(x: r.midX-22, y: r.midY-22,
                                width: 44, height: 44))
        let fx = r.width*0.18, fy = r.height*0.26   // 4 face-off dots
        for sx in [r.minX+fx, r.maxX-fx] {
            for sy in [r.midY-fy, r.midY+fy] {
                p.addEllipse(in: CGRect(x: sx-15, y: sy-15,
                                        width: 30, height: 30))
            }
        }
        return p
    }
}

ZStack {
    LinearGradient(colors: [Color(hex: "eaf3fb"), Color(hex: "d4e6f4")],
                   startPoint: .top, endPoint: .bottom)
    RinkMarkings().stroke(Color(hex: "c0392b"), lineWidth: 2)
}
.aspectRatio(61.0/26.0, contentMode: .fit)
.clipShape(RoundedRectangle(cornerRadius: 40))