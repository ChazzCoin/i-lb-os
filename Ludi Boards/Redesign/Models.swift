//
//  Models.swift
//  Ludi Boards
//
//  Domain models + sample data for the tactical board.
//

import SwiftUI

// MARK: - Team / token kinds

enum TeamKind {
    case home, away, goalkeeper

    var fill: LinearGradient {
        switch self {
        case .home:       return .homeJersey
        case .away:       return .awayJersey
        case .goalkeeper: return .gkJersey
        }
    }
    var ink: Color {
        switch self {
        case .home:       return .white
        case .away:       return Brand.awayInk
        case .goalkeeper: return Brand.lime
        }
    }
    var ring: Color {
        switch self {
        case .away: return Brand.awayInk.opacity(0.14)
        default:    return .white.opacity(0.28)
        }
    }
}

// MARK: - A draggable token on the board (player / equipment)

struct BoardToken: Identifiable {
    let id = UUID()
    var kind: TeamKind
    var number: Int
    /// Position as a fraction (0…1) of the pitch rect.
    var x: CGFloat
    var y: CGFloat
    var diameter: CGFloat = 34
}

// MARK: - Squad roster entry

struct SquadPlayer: Identifiable {
    let id = UUID()
    var number: Int
    var name: String
    var position: String   // ST, RW, CM, GK …
    var kind: TeamKind
}

// MARK: - Editor mode (Plan / Animate / Present)

enum EditorMode: String, CaseIterable, Identifiable {
    case plan = "Plan", animate = "Animate", present = "Present"
    var id: String { rawValue }
}

// MARK: - Library tabs

enum LibraryTab: String, CaseIterable, Identifiable {
    case equipment = "Equipment", tactics = "Tactics", markers = "Markers"
    var id: String { rawValue }
}

struct Sport: Identifiable {
    let id = UUID()
    var name: String
    var symbol: String   // SF Symbol
}

struct EquipmentItem: Identifiable {
    let id = UUID()
    var name: String
    var symbol: String
}

struct BoardPreset: Identifiable {
    let id = UUID()
    var name: String          // display label in the picker
    var sport: String         // sport pill it appears under
    var registryName: String  // key into the `Sports` board registry
}

// MARK: - Sample data (mirrors the redesign mockups)

enum Sample {
    /// 4-3-3 home + GK, matching the hero board layout (fractions of pitch rect).
    static let homeTokens: [BoardToken] = [
        .init(kind: .goalkeeper, number: 1, x: 0.0897, y: 0.50),
        .init(kind: .home, number: 3, x: 0.2308, y: 0.2115),
        .init(kind: .home, number: 4, x: 0.2179, y: 0.4038),
        .init(kind: .home, number: 5, x: 0.2179, y: 0.5962),
        .init(kind: .home, number: 2, x: 0.2308, y: 0.7885),
        .init(kind: .home, number: 6, x: 0.4038, y: 0.2885),
        .init(kind: .home, number: 8, x: 0.3910, y: 0.5038),
        .init(kind: .home, number: 7, x: 0.4038, y: 0.7154),
        .init(kind: .home, number: 11, x: 0.6026, y: 0.2308),
        .init(kind: .home, number: 9, x: 0.6474, y: 0.5038),
        .init(kind: .home, number: 10, x: 0.6026, y: 0.7731),
    ]

    static let awayTokens: [BoardToken] = [
        .init(kind: .away, number: 1, x: 0.9167, y: 0.50),
        .init(kind: .away, number: 5, x: 0.7821, y: 0.3462),
        .init(kind: .away, number: 6, x: 0.7974, y: 0.5769),
        .init(kind: .away, number: 4, x: 0.7026, y: 0.4327),
        .init(kind: .away, number: 2, x: 0.7026, y: 0.6442),
    ]

    static let homeRoster: [SquadPlayer] = [
        .init(number: 9, name: "M. Reed",   position: "ST", kind: .home),
        .init(number: 7, name: "L. Okafor", position: "RW", kind: .home),
        .init(number: 8, name: "D. Silva",  position: "CM", kind: .home),
        .init(number: 1, name: "A. Stone",  position: "GK", kind: .goalkeeper),
    ]

    static let awayRoster: [SquadPlayer] = [
        .init(number: 4, name: "T. Bauer", position: "CB", kind: .away),
        .init(number: 6, name: "N. Costa", position: "DM", kind: .away),
    ]

    static let sports: [Sport] = [
        .init(name: "Soccer",     symbol: "soccerball"),
        .init(name: "Futsal",     symbol: "soccerball.inverse"),
        .init(name: "Basketball", symbol: "basketball.fill"),
        .init(name: "Football",   symbol: "football.fill"),
        .init(name: "Baseball",   symbol: "baseball.fill"),
        .init(name: "Tennis",     symbol: "tennisball.fill"),
        .init(name: "Volleyball", symbol: "volleyball.fill"),
        .init(name: "Handball",   symbol: "figure.handball"),
        .init(name: "Hockey",     symbol: "hockey.puck.fill"),
        .init(name: "Pool",       symbol: "circle.grid.cross.fill"),
    ]

    static let equipment: [EquipmentItem] = [
        .init(name: "Cone",   symbol: "triangle"),
        .init(name: "Goal",   symbol: "rectangle.portrait"),
        .init(name: "Ball",   symbol: "soccerball"),
        .init(name: "Flag",   symbol: "flag.fill"),
        .init(name: "Ladder", symbol: "ladder"),
        .init(name: "Dummy",  symbol: "figure.stand"),
    ]

    /// Board picker catalogue — `registryName` keys the `Sports` registry; the
    /// grid filters to the selected sport pill. Order = display order per sport.
    static let boards: [BoardPreset] = [
        // Soccer
        .init(name: "Redesign Full", sport: "Soccer",     registryName: "Soccer Redesign Full View"),
        .init(name: "Redesign Half", sport: "Soccer",     registryName: "Soccer Redesign Half View"),
        .init(name: "Classic Full",  sport: "Soccer",     registryName: "Soccer Field Full View"),
        .init(name: "Markings",      sport: "Soccer",     registryName: "Soccer Markings Full View"),
        // Futsal
        .init(name: "Court",         sport: "Futsal",     registryName: "Futsal Court"),
        // Basketball
        .init(name: "Court",         sport: "Basketball", registryName: "Basketball Court Full View"),
        // Football
        .init(name: "Gridiron",      sport: "Football",   registryName: "Football Gridiron Full View"),
        // Baseball
        .init(name: "Diamond",       sport: "Baseball",   registryName: "Baseball Diamond"),
        // Tennis
        .init(name: "Court",         sport: "Tennis",     registryName: "Tennis Court"),
        // Volleyball
        .init(name: "Court",         sport: "Volleyball", registryName: "Volleyball Court"),
        // Handball
        .init(name: "Court",         sport: "Handball",   registryName: "Handball Court"),
        // Hockey
        .init(name: "Rink",          sport: "Hockey",     registryName: "Ice Hockey Rink"),
        // Pool
        .init(name: "Table",         sport: "Pool",       registryName: "Pool Table 1"),
        .init(name: "Vector Table",  sport: "Pool",       registryName: "Pool Table Vector"),
    ]
}
