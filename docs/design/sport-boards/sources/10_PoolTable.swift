struct PoolTable: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)            // wood rail
                .fill(Color(hex: "5a3416"))
            RoundedRectangle(cornerRadius: 4)             // baize
                .fill(LinearGradient(
                    colors: [Color(hex: "1f7a52"), Color(hex: "176544")],
                    startPoint: .top, endPoint: .bottom))
                .padding(20)
            GeometryReader { g in
                let w = g.size.width, h = g.size.height
                ForEach(pockets(w, h), id: \.self) { pt in
                    Circle().fill(Color(hex: "3a2410"))
                        .frame(width: 16, height: 16).position(pt)
                }
                Circle().fill(.white)                     // foot spot
                    .frame(width: 5).position(x: w*0.29, y: h*0.5)
            }
        }
        .aspectRatio(2.0, contentMode: .fit)
    }
    func pockets(_ w: CGFloat, _ h: CGFloat) -> [CGPoint] {
        [CGPoint(x: 14, y: 14), CGPoint(x: w/2, y: 9),
         CGPoint(x: w-14, y: 14), CGPoint(x: 14, y: h-14),
         CGPoint(x: w/2, y: h-9), CGPoint(x: w-14, y: h-14)]
    }
}