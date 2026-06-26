struct GridironMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let ez = r.width * 0.083                  // 10-yd end zones
        let field = CGRect(x: r.minX + ez, y: r.minY,
                           width: r.width - ez*2, height: r.height)
        p.addRect(field)
        for i in 0...20 {                          // lines every 5 yd
            let x = field.minX + field.width * CGFloat(i)/20
            p.move(to: CGPoint(x: x, y: field.minY))
            p.addLine(to: CGPoint(x: x, y: field.maxY))
            for hy in [r.height*0.37, r.height*0.63] {   // hash rows
                p.move(to: CGPoint(x: x-3, y: hy))
                p.addLine(to: CGPoint(x: x+3, y: hy))
            }
        }
        return p
    }
}

ZStack {
    Color(hex: "2f8b4d")
    HStack(spacing: 0) {                           // coloured end zones
        Color(hex: "21437d").frame(maxWidth: .infinity)
        Color.clear.frame(maxWidth: .infinity).layoutPriority(10)
        Color(hex: "9e3636").frame(maxWidth: .infinity)
    }
    GridironMarkings().stroke(.white.opacity(0.85), lineWidth: 1.5)
}
.aspectRatio(120.0/53.3, contentMode: .fit)
.clipShape(RoundedRectangle(cornerRadius: 12))