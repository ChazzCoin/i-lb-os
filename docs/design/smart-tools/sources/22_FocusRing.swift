struct FocusRing: View {
    var center: CGPoint
    @State private var pulse = false
    var body: some View {
        Circle()
            .stroke(Brand.lime, lineWidth: 2.5)
            .frame(width: 40, height: 40)
            .scaleEffect(pulse ? 1.4 : 1)
            .opacity(pulse ? 0 : 1)
            .position(center)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)
                    .repeatForever(autoreverses: false)) {
                    pulse = true
                }
            }
    }
}

FocusRing(center: CGPoint(x: 150, y: 110))