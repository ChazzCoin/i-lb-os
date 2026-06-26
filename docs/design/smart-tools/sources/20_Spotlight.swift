struct Spotlight: View {
    var focus: CGPoint
    var radius: CGFloat = 70
    var body: some View {
        Rectangle()
            .fill(.black.opacity(0.6))
            .mask {
                Rectangle()
                    .overlay(
                        Circle()
                            .frame(width: radius * 2, height: radius * 2)
                            .position(focus)
                            .blendMode(.destinationOut))
                    .compositingGroup()
            }
            .allowsHitTesting(false)
    }
}

Spotlight(focus: CGPoint(x: 160, y: 110), radius: 60)