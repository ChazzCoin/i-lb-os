//
//  ColorProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI
import UIKit

public extension UIColor {
    public func isEqualToColor(_ color: UIColor) -> Bool {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)

        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return red1 == red2 && green1 == green2 && blue1 == blue2 && alpha1 == alpha2
    }
}

public extension ColorProvider {
    static func fromColor(_ color: Color) -> ColorProvider {
        let uiColor = color.uiColor
        for case let candidate in ColorProvider.allCases {
            if uiColor.isEqualToColor(candidate.colorValue.uiColor) {
                return candidate
            }
        }
        return .black
    }
}

public func colorFromRGBA(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> Color {
    return Color(red: red, green: green, blue: blue, opacity: alpha)
}


public extension Color {
    
    public var uiColor: UIColor {
        UIColor(self)
    }
    
    public func toRGBA() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        // Convert Color to UIColor
        let uiColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        // Extract RGBA components
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        
        return (red, green, blue, alpha)
    }
}


public struct ColorPro {
    let title: String
    let color: Color
}

public func colorDict() -> [String: Color] {
    var colorDict = [String: Color]()

    for colorCase in ColorProvider.allCases {
        colorDict[colorCase.rawValue] = colorCase.colorValue
    }

    return colorDict
}

public enum ColorProvider: String, CaseIterable {
    case black = "Black"
    case red = "Red"
    case green = "Green"
    case blue = "Blue"
    case yellow = "Yellow"
    case cyan = "Cyan"
    case magenta = "Magenta"
    case orange = "Orange"
    case purple = "Purple"
    case brown = "Brown"
    case pink = "Pink"
    case lime = "Lime"
    case teal = "Teal"
    case coral = "Coral"
    case olive = "Olive"
    case maroon = "Maroon"
    case navy = "Navy"
    case silver = "Silver"
    case gray = "Gray"
    case gold = "Gold"
    case peach = "Peach"
    case lavender = "Lavender"
    case khaki = "Khaki"
    case mint = "Mint"
    case beige = "Beige"
    case ivory = "Ivory"
    case indigo = "Indigo"
    case violet = "Violet"
    case plum = "Plum"
    case tan = "Tan"

    public var colorValue: Color {
        switch self {
            case .black: return Color(red: 0.0, green: 0.0, blue: 0.0)
            case .red: return Color(red: 1.0, green: 0.0, blue: 0.0)
            case .green: return Color(red: 0.0, green: 0.5, blue: 0.0)
            case .blue: return Color(red: 0.0, green: 0.0, blue: 1.0)
            case .yellow: return Color(red: 1.0, green: 1.0, blue: 0.0)
            case .cyan: return Color(red: 0.0, green: 1.0, blue: 1.0)
            case .magenta: return Color(red: 1.0, green: 0.0, blue: 1.0)
            case .orange: return Color(red: 1.0, green: 0.65, blue: 0.0)
            case .purple: return Color(red: 0.5, green: 0.0, blue: 0.5)
            case .brown: return Color(red: 0.65, green: 0.16, blue: 0.16)
            case .pink: return Color(red: 1.0, green: 0.75, blue: 0.79)
            case .lime: return Color(red: 0.0, green: 1.0, blue: 0.0)
            case .teal: return Color(red: 0.0, green: 0.5, blue: 0.5)
            case .coral: return Color(red: 1.0, green: 0.5, blue: 0.31)
            case .olive: return Color(red: 0.5, green: 0.5, blue: 0.0)
            case .maroon: return Color(red: 0.5, green: 0.0, blue: 0.0)
            case .navy: return Color(red: 0.0, green: 0.0, blue: 0.5)
            case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
            case .gray: return Color(red: 0.5, green: 0.5, blue: 0.5)
            case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
            case .peach: return Color(red: 1.0, green: 0.89, blue: 0.71)
            case .lavender: return Color(red: 0.9, green: 0.9, blue: 0.98)
            case .khaki: return Color(red: 0.94, green: 0.9, blue: 0.55)
            case .mint: return Color(red: 0.6, green: 1.0, blue: 0.6)
            case .beige: return Color(red: 0.96, green: 0.96, blue: 0.86)
            case .ivory: return Color(red: 1.0, green: 1.0, blue: 0.94)
            case .indigo: return Color(red: 0.29, green: 0.0, blue: 0.51)
            case .violet: return Color(red: 0.93, green: 0.51, blue: 0.93)
            case .plum: return Color(red: 0.87, green: 0.63, blue: 0.87)
            case .tan: return Color(red: 0.82, green: 0.71, blue: 0.55)
        }
    }
    
    public func toColorPro() -> ColorPro {
        return ColorPro(title: self.rawValue, color: self.colorValue)
    }

    public static func fromColorName(colorName: String) -> ColorProvider {
        return ColorProvider(rawValue: colorName) ?? .black
    }
}

public extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}
