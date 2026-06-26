struct DiamondMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let home = CGPoint(x: r.midX, y: r.maxY - r.height*0.05)
        let b = r.width * 0.29
        let first  = CGPoint(x: home.x + b, y: home.y - b)
        let second = CGPoint(x: home.x,     y: home.y - b*2)
        let third  = CGPoint(x: home.x - b, y: home.y - b)
        p.move(to: home)                           // base paths
        p.addLine(to: first); p.addLine(to: second)
        p.addLine(to: third); p.closeSubpath()
        let reach = r.width * 0.5                   // foul lines
        p.move(to: home)
        p.addLine(to: CGPoint(x: home.x + reach, y: home.y - reach))
        p.move(to: home)
        p.addLine(to: CGPoint(x: home.x - reach, y: home.y - reach))
        let mound = CGPoint(x: home.x, y: home.y - b)
        p.addEllipse(in: CGRect(x: mound.x-4, y: mound.y-4,
                                width: 8, height: 8))
        return p
    }
}

ZStack {
    Color(hex: "368a4f")                            // outfield grass
    DiamondMarkings().fill(Color(hex: "b06a37"))    // clay skin
    DiamondMarkings().stroke(.white.opacity(0.9), lineWidth: 2)
}
.aspectRatio(1.4, contentMode: .fit)
.clipShape(RoundedRectangle(cornerRadius: 12))