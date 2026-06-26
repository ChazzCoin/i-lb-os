struct Keyframe: Identifiable {
    let id = UUID()
    var label: String
}

struct FreezeFrame: View {
    var frames: [Keyframe]
    @Binding var current: UUID?
    var body: some View {
        HStack(spacing: 8) {
            ForEach(frames) { k in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(k.id == current
                            ? Brand.lime : .white.opacity(0.08))
                        .frame(width: 44, height: 30)
                    Text(k.label).font(AppFont.mono(9))
                        .foregroundStyle(Brand.textMuted)
                }
                .onTapGesture { current = k.id }
            }
        }
    }
}