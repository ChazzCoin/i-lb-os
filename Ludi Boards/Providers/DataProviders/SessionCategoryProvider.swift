//
//  SessionCategoryProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 3/29/24.
//

import Foundation
import SwiftUI

enum SessionCategory: String, CaseIterable {
    case warmUp = "Warm-Up"
    case preGame = "Pre-Game"
    case scrimmage = "Scrimmage"
    case formationTraining = "Formation Training"
    case defensiveDrills = "Defensive Drills"
    case offensiveDrills = "Offensive Drills"
    case technicalSkills = "Technical Skills"
    case tacticalTraining = "Tactical Training"
    case strengthAndConditioning = "Strength and Conditioning"
    case coolDown = "Cool Down"
    case teamMeeting = "Team Meeting"
    case strategySession = "Strategy Session"
    case individualSkills = "Individual Skills"
    case recoverySession = "Recovery Session"
    case mentalPreparation = "Mental Preparation"
    case goalkeeperTraining = "Goalkeeper Training"
    case plyometrics = "Plyometrics"
    case speedAndAgility = "Speed and Agility"
    case enduranceTraining = "Endurance Training"
    case flexibilitySession = "Flexibility Session"
    case nutritionEducation = "Nutrition Education"
    case injuryPrevention = "Injury Prevention"
    case videoAnalysis = "Video Analysis"
    case postGameAnalysis = "Post-Game Analysis"
    case communityEngagement = "Community Engagement"
    case youthDevelopment = "Youth Development"
    case equipmentPreparation = "Equipment Preparation"
}

struct PickerSessionCategory: View {
    @Binding var selection: String
    @Binding var isEdit: Bool
    let title = "Session Category"

    var body: some View {
        if !isEdit {
            TextLabel(title, text: selection)
        } else {
            Picker(title, selection: $selection) {
                ForEach(SessionCategory.allCases, id: \.self) { item in
                    Text(item.rawValue).tag(item.rawValue)
                }
            }
            .foregroundColor(.blue)
            .pickerStyle(MenuPickerStyle())
        }
    }
}
