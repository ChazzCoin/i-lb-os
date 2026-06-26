struct OffsideLine: View {
    var x: CGFloat
    var height: CGFloat
    var body: some View {
        Rectangle()
            .fill(Brand.danger)
            .frame(width: 2, height: height)
            .shadow(color: Brand.danger.opacity(0.6), radius: 5)
            .overlay(alignment: .top) {
                Text("OFFSIDE")
                    .font(AppFont.ui(9, .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Brand.danger, in: Capsule())
                    .offset(y: -10)
            }
            .position(x: x, y: height / 2)
    }
}

OffsideLine(x: 210, height: 320)