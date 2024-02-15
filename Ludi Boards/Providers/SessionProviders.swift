//
//  SessionProviders.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/14/24.
//

import Foundation

struct PlayerNumbers {
    static let numbers: [Int] = [1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
    static let groups: [Int] = [1, 2, 3, 4, 5, 6, 7, 8]
}

enum AgeLevel: String, CaseIterable, Identifiable {
    case Youth = "Youth"
    case U6 = "U6"
    case U8 = "U8"
    case U10 = "U10"
    case U12 = "U12"
    case U14 = "U14"
    case U16 = "U16"
    case U18 = "U18"
    case U21 = "U21"
    case Adult = "Adult"
    case Professional = "Professional"

    var id: String { self.rawValue }
}

enum TimeDuration: Int, CaseIterable, Identifiable {
    case one = 1
    case five = 5
    case ten = 10
    case fifteen = 15
    case thirty = 30
    case fortyFive = 45
    case sixty = 60
    case ninety = 90

    var id: Int { self.rawValue }

    var description: String {
        "\(self.rawValue) Minutes"
    }
}


enum IntensityLevel: String, CaseIterable, Identifiable {
    case Cool = "Cool Down"
    case Warm = "Warm Up"
    case Low = "Low"
    case Medium = "Medium"
    case High = "High"
    case Max = "Max"

    var id: String { self.rawValue }
}


