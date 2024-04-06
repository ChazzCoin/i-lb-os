//
//  SportsPositions.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import SwiftUI
import CoreEngine

// Soccer
enum SoccerPosition: CaseIterable {
    case goalkeeper
    case rightFullback
    case leftFullback
    case centerBack
    case rightCenterBack
    case leftCenterBack
    case defensiveMidfield
    case rightMidfield
    case leftMidfield
    case attackingMidfield
    case forward
    
    var positionNumber: Int {
        switch self {
            case .goalkeeper: return 1
            case .rightFullback: return 2
            case .leftFullback: return 3
            case .centerBack: return 4
            case .rightCenterBack: return 5
            case .leftCenterBack: return 6
            case .defensiveMidfield: return 7
            case .rightMidfield: return 8
            case .leftMidfield: return 9
            case .attackingMidfield: return 10
            case .forward: return 11
        }
    }
    
    var positionName: String {
        switch self {
            case .goalkeeper: return "Goalkeeper"
            case .rightFullback: return "Right Fullback"
            case .leftFullback: return "Left Fullback"
            case .centerBack: return "Center Back"
            case .rightCenterBack: return "Right Center Back"
            case .leftCenterBack: return "Left Center Back"
            case .defensiveMidfield: return "Defensive Midfield"
            case .rightMidfield: return "Right Midfield"
            case .leftMidfield: return "Left Midfield"
            case .attackingMidfield: return "Attacking Midfield"
            case .forward: return "Forward"
        }
    }
    
    var positionFull: String {
        switch self {
            case .goalkeeper: return "1 : Goalkeeper"
            case .rightFullback: return "2 : Right Fullback"
            case .leftFullback: return "3 : Left Fullback"
            case .centerBack: return "4 : Center Back"
            case .rightCenterBack: return "5 : Right Center Back"
            case .leftCenterBack: return "6 : Left Center Back"
            case .defensiveMidfield: return "7 : Defensive Midfield"
            case .rightMidfield: return "8 : Right Midfield"
            case .leftMidfield: return "9 : Left Midfield"
            case .attackingMidfield: return "10 : Attacking Midfield"
            case .forward: return "11 : Forward"
        }
    }
    
    static func position(forNumber number: Int) -> SoccerPosition? {
        return SoccerPosition.allCases.first { $0.positionNumber == number }
    }
}
struct PickerSoccerPosition: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Soccer Position", text: selection)
        } else {
            Picker("Soccer Position", selection: $selection) {
                ForEach(SoccerPosition.allCases, id: \.self) { item in
                    Text(item.positionFull).tag(item.positionFull)
                }
            }
            .foregroundColor(.blue)
        }
    }
}
