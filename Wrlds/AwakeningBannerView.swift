import SwiftUI

/// Canvas-scale aware hero banner with glass, gradient text, glow, and shimmer.
/// Designed for huge coordinate spaces (e.g., 20,000x20,000) and works with your pan/zoom.
public struct AwakeningBanner: View {
    public var title: String
    public var subtitle: String? = nil
    public var position: CGPoint                      // where on your canvas
    public var maxWidth: CGFloat = 20000               // banner width in world units
    public var cornerRadius: CGFloat = 1400           // generous for giant canvas
    public var canvasScale: CGFloat = 7.0               // pass your BEO.canvasScale here

    @State private var shimmerPhase: CGFloat = 0

    public init(
        title: String,
        subtitle: String? = nil,
        position: CGPoint,
        maxWidth: CGFloat = 20000,
        cornerRadius: CGFloat = 1400,
        canvasScale: CGFloat = 1
    ) {
        self.title = title
        self.subtitle = subtitle
        self.position = position
        self.maxWidth = maxWidth
        self.cornerRadius = cornerRadius
        self.canvasScale = canvasScale
    }

    // Scale-aware pixel unit so strokes/shadows stay ~1px on screen as you zoom.
    private var px: CGFloat { 1 / max(canvasScale, 0.01) }

    public var body: some View {
        ZStack {
            // Soft ambient glows behind the card
            glowBlob(color: .purple,  size: maxWidth * 0.9,  offset: .init(width: -maxWidth*0.12, height: -maxWidth*0.06))
            glowBlob(color: .blue,    size: maxWidth * 0.7,  offset: .init(width:  maxWidth*0.18, height:  maxWidth*0.08))
            glowBlob(color: .pink,    size: maxWidth * 0.45, offset: .init(width: -maxWidth*0.22, height:  maxWidth*0.20))

            // Glass card container
            VStack(spacing: 400 * px) {
//                titleView
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 100, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.2)
                        .foregroundStyle(.secondary)
                        .kerning(8)
                        .opacity(0.9)
                        .padding(.horizontal, 600 * px)
                }

//                // Accent underline
//                RoundedRectangle(cornerRadius: 9999)
//                    .fill(
//                        LinearGradient(
//                            colors: [.cyan, .mint, .yellow, .orange, .pink],
//                            startPoint: .leading, endPoint: .trailing
//                        )
//                    )
//                    .frame(height: max(20 * px, 6))
//                    .shadow(radius: 60 * px)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 9999)
//                            .stroke(.white.opacity(0.45), lineWidth: 2 * px)
//                    )
//                    .padding(.horizontal, 1000 * px)
            }
            .padding(.vertical, 900 * px)
//            .frame(maxWidth: .infinity)
//            .background(.ultraThinMaterial, in:
//                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
//            )
//            .overlay( // gradient hairline around the glass
//                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
//                    .strokeBorder(
//                        AngularGradient(
//                            colors: [.cyan, .blue, .purple, .pink, .orange, .yellow, .cyan],
//                            center: .center
//                        ),
//                        lineWidth: max(14 * px, 1)
//                    )
//                    .blendMode(.plusLighter)
//            )
            .shadow(color: .black.opacity(0.25), radius: 320 * px, x: 0, y: 120 * px)
//            .compositingGroup()
//            .drawingGroup()
        }
//        .frame(maxWidth: .infinity)
//        .position(position)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                shimmerPhase = 1
            }
        }
    }

    @ViewBuilder
    public var titleView: some View {
        let px = self.px
        let f = adaptiveFontSize // keeps effective pixels under GPU limits

        ZStack {
            // Base fill: luxe white gradient
            baseText(fontSize: f)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.85), Color(white: 0.95)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            // Shimmer: moving line through the letters
            baseText(fontSize: f)
                .foregroundStyle(
                    LinearGradient(
                        stops: [
                            .init(color: .clear,               location: shimmer - 0.30),
                            .init(color: .white.opacity(0.95), location: shimmer - 0.02),
                            .init(color: .clear,               location: shimmer + 0.26)
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .blendMode(.plusLighter)
                .opacity(0.9)

            // Iridescent glaze
            baseText(fontSize: f)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan.opacity(0.55), .purple.opacity(0.5), .pink.opacity(0.5)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .blendMode(.overlay)
                .opacity(0.8)
        }
        // Soft halo glows (lightweight)
//        .frame(maxWidth: .infinity)
        .shadow(color: .cyan.opacity(0.25), radius: 160 * px)
        .shadow(color: .purple.opacity(0.20), radius: 260 * px)
        .shadow(color: .pink.opacity(0.16), radius: 360 * px)
        .compositingGroup()              // keep blends crisp
        .allowsHitTesting(false)
        .onAppear {
            // Animate shimmer from left -> right repeatedly
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                shimmer = 1.4
            }
        }
    }
    @State private var shimmer: CGFloat = -0.4

    private func baseText(fontSize: CGFloat) -> some View {
        Text(title.uppercased())
            .font(.system(size: fontSize, weight: .black, design: .rounded))
            .minimumScaleFactor(0.1)
            .multilineTextAlignment(.center)
            .kerning(18)
            .lineLimit(2)
            .fixedSize() // use intrinsic bounds; avoids huge off-screen masks
    }

    // Cap effective pixel size so the layer never explodes at extreme zooms
    private var adaptiveFontSize: CGFloat {
        let desired: CGFloat = 2400
        let maxPixels: CGFloat = 3600           // safe across most iOS GPUs
        let cap = maxPixels / max(canvasScale, 0.0001)
        return min(desired, cap)
    }


    // Reusable text mask so the compiler doesn’t re-infer the world
    private var titleText: some View {
        let baseFontSize: CGFloat = 2400
        return Text(title.uppercased())
            .font(.system(size: baseFontSize, weight: .black, design: .rounded))
            .minimumScaleFactor(1)
            .multilineTextAlignment(.center)
            .kerning(18)
            .lineLimit(2)
    }

    // Styles broken out so generics stay shallow
    private var primaryFill: LinearGradient {
        LinearGradient(
            colors: [Color.white, Color.white.opacity(0.85), Color(white: 0.95)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var shimmerLayer: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.00),
                .init(color: .white.opacity(0.9), location: 0.48),
                .init(color: .clear, location: 0.96)
            ],
            startPoint: .leading, endPoint: .trailing
        )
        .scaleEffect(x: 1.8, anchor: .leading)
        .offset(x: shimmerOffset) // see below
        .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: shimmerPhase)
    }

    private var iridescentLayer: LinearGradient {
        LinearGradient(
            colors: [.cyan.opacity(0.55), .purple.opacity(0.5), .pink.opacity(0.5)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var shimmerOffset: CGFloat {
        // keep it simple for the compiler
        let width = maxWidth
        return (shimmerPhase * width).truncatingRemainder(dividingBy: width)
    }


    public func glowBlob(color: Color, size: CGFloat, offset: CGSize) -> some View {
        Circle()
            .fill(color.opacity(0.25))
            .frame(width: size, height: size)
            .blur(radius: size * 0.12 * px)
            .offset(offset)
            .allowsHitTesting(false)
    }
}
