//
//  ColorProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI

struct ColorPro {
    let title: String
    let color: Color
}

enum ColorProvider: String, CaseIterable {
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

    var colorValue: Color {
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
    
    func toColorPro() -> ColorPro {
        return ColorPro(title: self.rawValue, color: self.colorValue)
    }

    static func fromColorName(colorName: String) -> ColorProvider {
        return ColorProvider(rawValue: colorName) ?? .black
    }
}
