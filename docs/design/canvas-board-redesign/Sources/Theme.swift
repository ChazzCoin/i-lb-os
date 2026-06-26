//
//  Theme.swift
//  Ludi Boards — tactical board redesign
//
//  Design tokens translated from the HTML redesign.
//  Palette, typography, gradients and reusable surface styles.
//

import SwiftUI

// MARK: - Colors

extension Color {
    /// #RRGGBB / #RRGGBBAA hex initializer.
    init(hex: String, opacity: Double = 1) {
        var s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        if s.count == 8 {
            // includes alpha
            let a = UInt8(s.suffix(2), radix: 16) ?? 255
            s = String(s.prefix(6))
            self.init(hexRGB: s, opacity: Double(a) / 255.0)
            return
        }
        self.init(hexRGB: s, opacity: opacity)
    }

    private init(hexRGB s: String, opacity: Double) {
        let v = UInt64(s, radix: 16) ?? 0
        self.init(
            .sRGB,
            red:   Double((v >> 16) & 0xFF) / 255.0,
            green: Double((v >> 8) & 0xFF) / 255.0,
            blue:  Double(v & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

enum Brand {
    // Accent
    static let lime      = Color(hex: "CBDB2A")   // primary accent
    static let limeInk   = Color(hex: "11200A")   // text/icons on lime
    static let teal      = Color(hex: "3E7167")
    static let danger    = Color(hex: "F0726B")

    // Canvas backgrounds (radial stops)
    static let bgTop     = Color(hex: "18212F")
    static let bgMid     = Color(hex: "10161F")
    static let bgBottom  = Color(hex: "0B1018")

    // Surfaces (glass panels / bars)
    static let panel     = Color(hex: "141C28")   // base; apply opacity at use site
    static let panelLine = Color.white.opacity(0.07)
    static let hairline  = Color.white.opacity(0.06)

    // Text
    static let textHi    = Color(hex: "EEF2EE")
    static let text      = Color(hex: "E9EEF0")
    static let textMid   = Color(hex: "CFD7DD")
    static let textMuted = Color(hex: "8A95A3")
    static let textDim   = Color(hex: "7F8B98")
    static let textFaint = Color(hex: "5E6B78")

    // Pitch
    static let pitch        = Color(hex: "356A5C")
    static let pitchStripe  = Color(hex: "2F6053")
    static let pitchLine    = Color(hex: "EEF4EC")

    // Player skins
    static let homeTop   = Color(hex: "4D8576")
    static let homeBot   = Color(hex: "37645A")
    static let awayTop   = Color(hex: "FBFCFD")
    static let awayBot   = Color(hex: "E6EAEE")
    static let awayInk   = Color(hex: "1D2632")
    static let gkTop     = Color(hex: "2C3648")
    static let gkBot     = Color(hex: "222A39")
}

// MARK: - Gradients

extension ShapeStyle where Self == LinearGradient {
    static var homeJersey: LinearGradient {
        LinearGradient(colors: [Brand.homeTop, Brand.homeBot], startPoint: .top, endPoint: .bottom)
    }
    static var awayJersey: LinearGradient {
        LinearGradient(colors: [Brand.awayTop, Brand.awayBot], startPoint: .top, endPoint: .bottom)
    }
    static var gkJersey: LinearGradient {
        LinearGradient(colors: [Brand.gkTop, Brand.gkBot], startPoint: .top, endPoint: .bottom)
    }
}

/// Full-screen canvas background (radial graphite, matches `radial-gradient(120% 95% at 72% -8%, …)`).
struct CanvasBackground: View {
    var body: some View {
        RadialGradient(
            colors: [Brand.bgTop, Brand.bgMid, Brand.bgBottom],
            center: UnitPoint(x: 0.72, y: -0.08),
            startRadius: 0,
            endRadius: 1100
        )
        .ignoresSafeArea()
    }
}

// MARK: - Typography
//
//  The design uses Archivo (display/numerals), Hanken Grotesk (UI) and
//  JetBrains Mono (data). Add the .ttf files to the app target and register
//  them in Info.plist under "Fonts provided by application", then these
//  helpers resolve them. If a family is missing, SwiftUI falls back to the
//  system font automatically.

enum AppFont {
    static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .custom("Archivo", size: size).weight(weight)
    }
    static func ui(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .custom("HankenGrotesk-Regular", size: size).weight(weight)
    }
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
        .custom("JetBrainsMono-Regular", size: size).weight(weight)
    }
}

// MARK: - Surface modifier (frosted glass panel)

struct GlassPanel: ViewModifier {
    var radius: CGFloat = 18
    var fill: Double = 0.82
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .background(Brand.panel.opacity(fill), in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Brand.panelLine, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 18)
    }
}

extension View {
    func glassPanel(radius: CGFloat = 18, fill: Double = 0.82) -> some View {
        modifier(GlassPanel(radius: radius, fill: fill))
    }
}
