struct Heatmap: View {
    var samples: [CGPoint]
    var radius: CGFloat = 46
    var body: some View {
        Canvas { ctx, _ in
            ctx.addFilter(.blur(radius: 18))
            ctx.drawLayer { layer in
                for s in samples {
                    let rect = CGRect(
                        x: s.x - radius, y: s.y - radius,
                        width: radius * 2, height: radius * 2)
                    let g = Gradient(colors: [
                        Brand.lime.opacity(0.7), .clear])
                    layer.fill(Circle().path(in: rect),
                        with: .radialGradient(g, center: s,
                            startRadius: 0, endRadius: radius))
                }
            }
        }
        .blendMode(.screen)
        .allowsHitTesting(false)
    }
}