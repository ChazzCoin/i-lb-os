struct StatRing: View {
    var value: Double            // 0…1
    var body: some View {
        Circle().stroke(.white.opacity(0.12), lineWidth: 3)
            .overlay(
                Circle().trim(from: 0, to: value)
                    .stroke(Brand.lime, style: StrokeStyle(
                        lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90)))
    }
}

struct StatBadge: View {
    var number: Int, stamina: Double
    var body: some View {
        PlayerToken(number: number)
            .padding(4)
            .background(StatRing(value: stamina))
    }
}

StatBadge(number: 10, stamina: 0.72)