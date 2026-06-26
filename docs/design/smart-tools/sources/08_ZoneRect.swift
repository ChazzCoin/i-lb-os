struct ZoneRect: View {
    var rect: CGRect
    var tint: Color = Brand.lime
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(tint.opacity(0.16))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(tint.opacity(0.7),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 5])))
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}

ZoneRect(rect: CGRect(x: 40, y: 30, width: 180, height: 120),
         tint: Brand.teal)