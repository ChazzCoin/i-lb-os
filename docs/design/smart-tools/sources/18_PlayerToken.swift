struct PlayerToken: View {
    var number: Int
    var fill: LinearGradient = .homeJersey
    var stat: String? = nil
    var size: CGFloat = 34
    var body: some View {
        Text("\(number)")
            .font(AppFont.display(size * 0.44, .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(fill, in: Circle())
            .overlay(Circle()
                .strokeBorder(.white.opacity(0.3), lineWidth: 1.5))
            .overlay(alignment: .bottom) {
                if let stat {
                    Text(stat).font(AppFont.mono(9))
                        .foregroundStyle(Brand.limeInk)
                        .padding(.horizontal, 5).padding(.vertical, 1)
                        .background(Brand.lime, in: Capsule())
                        .offset(y: 9)
                }
            }
    }
}

PlayerToken(number: 9, stat: "7.8")