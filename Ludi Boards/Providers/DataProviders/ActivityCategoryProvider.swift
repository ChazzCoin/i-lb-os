//
//  ActivityCategoryProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 3/29/24.
//

import Foundation
import SwiftUI

enum ActivityCategory: String, CaseIterable {
    case oneVOneAttacking = "1v1 Attacking"
    case oneVOneDefending = "1v1 Defending"
    case passingAccuracy = "Passing Accuracy"
    case dribblingSkills = "Dribbling Skills"
    case shootingAccuracy = "Shooting Accuracy"
    case goalkeepingSkills = "Goalkeeping Skills"
    case headingDrills = "Heading Drills"
    case freeKickPractice = "Free Kick Practice"
    case cornerKickStrategies = "Corner Kick Strategies"
    case throwInTechniques = "Throw In Techniques"
    case speedLadders = "Speed Ladders"
    case agilityCones = "Agility Cones"
    case enduranceRuns = "Endurance Runs"
    case strengthCircuits = "Strength Circuits"
    case flexibilityYoga = "Flexibility Yoga"
    case tacticalPositioning = "Tactical Positioning"
    case ballControl = "Ball Control"
    case reactionTimeDrills = "Reaction Time Drills"
    case mentalToughness = "Mental Toughness"
    case teamPlaySimulation = "Team Play Simulation"
    case crossFitChallenges = "CrossFit Challenges"
    case plyometricHops = "Plyometric Hops"
    case balanceBoard = "Balance Board"
    case coordinationDrills = "Coordination Drills"
    case nutritionalPlanning = "Nutritional Planning"
    case injuryRehabilitation = "Injury Rehabilitation"
}

struct PickerActivityCategory: View {
    @Binding var selection: String
    @Binding var isEdit: Bool
    let title = "Activity Category"

    var body: some View {
        if !isEdit {
            TextLabel(title, text: selection)
        } else {
            Picker(title, selection: $selection) {
                ForEach(ActivityCategory.allCases, id: \.self) { item in
                    Text(item.rawValue).tag(item.rawValue)
                }
            }
            .foregroundColor(.blue)
            .pickerStyle(MenuPickerStyle())
        }
    }
}
