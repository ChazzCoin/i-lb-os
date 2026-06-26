struct VolleyMarkings: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addRect(r)
        p.move(to: CGPoint(x: r.midX, y: r.minY))  // centre / net line
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        let atk = r.width * 0.167                   // 3 m attack line
        p.move(to: CGPoint(x: r.midX-atk, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX-atk, y: r.maxY))
        p.move(to: CGPoint(x: r.midX+atk, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX+atk, y: r.maxY))
        return p
    }
}

ZStack {
    Color(hex: "d89b54")                            // resin court
    Rectangle().fill(Color(hex: "c0712f"))          // centre zone tint
        .frame(width: 36).position(x: 150, y: 84)
    VolleyMarkings().stroke(Color(hex: "f4efe6"), lineWidth: 2.4)
}
.aspectRatio(18.0/9.0, contentMode: .fit)
.clipShape(RoundedRectangle(cornerRadius: 12))