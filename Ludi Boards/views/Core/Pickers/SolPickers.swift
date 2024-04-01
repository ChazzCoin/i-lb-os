//
//  Solponents.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/14/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct SolTeamPicker: View {
    @Binding var selection: String
    @Binding var isEnabled: Bool
    @ObservedResults(Team.self) var allTeams
    
    var body: some View {
        
        ZStack {
            
            if isEnabled {
                Picker(selection: $selection, label: HeaderText("Teams")) {
                    ForEach(allTeams, id: \.self) { item in
                        Text(item.name)
                            .tag(item.name)
                    }
                }
            } else {
                SubHeaderText(selection)
            }
            
        }
        .padding(15)
        .background(Color.secondaryBackground) // Change background based on isEditable.
        .accentColor(.white) // Change text color based on isEditable.
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
    }
}

struct SolPlayerRefFreePicker: View {
    @Binding var selection: String
    @Binding var isEnabled: Bool
    @State var realmInstance = newRealm()
    @ObservedResults(PlayerRef.self, where: { $0.teamId == "" }) var allPlayers
    
    var body: some View {
        Picker(selection: $selection, label: BodyText("No Players")) {
            ForEach(allPlayers, id: \.self) { item in
                Text(item.name)
                    .tag(item.name)
            }
        }
        .padding(15)
        .background(Color.secondaryBackground) // Change background based on isEditable.
        .accentColor(.white) // Change text color based on isEditable.
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .solEnabled(isEnabled: isEnabled)
    }
}


struct PickerNumberOfPlayers: View {
    @Binding var selection: Int
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Number of Players", text: String(selection))
        } else {
            Picker("Number of Players", selection: $selection) {
                ForEach(PlayerNumbers.numbers, id: \.self) { number in
                    Text(String(number)).tag(number)
                }
            }
        }
        
//        .pickerStyle(WheelPickerStyle())
    }
}


struct PickerDate: View {
    @Binding var selection: Date
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Scheduled Date", text: "\(selection)")
        } else {
            DatePicker("Scheduled Date", selection: $selection, displayedComponents: .date)
        }
    }
}


struct PickerIntensity: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Intensity", text: selection)
        } else {
            Picker("Intensity", selection: $selection) {
                ForEach(IntensityLevel.allCases) { intensityLevel in
                    Text(intensityLevel.rawValue).tag(intensityLevel.rawValue)
                }
            }
        }
        
//        .pickerStyle(SegmentedPickerStyle())
    }
}


struct PickerAgeLevel: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Age Level", text: selection)
        } else {
            Picker("Age Level", selection: $selection) {
                ForEach(AgeLevel.allCases) { age in
                    Text(age.rawValue).tag(age.rawValue)
                }
            }
        }
    }
}


struct PickerTimeDuration: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Time Duration", text: selection)
        } else {
            Picker("Time Duration", selection: $selection) {
                ForEach(TimeDuration.allCases) { duration in
                    Text("\(duration.rawValue) Minutes").tag(String(duration.rawValue))
                }
            }
        }
    }
}

struct PickerGroupCount: View {
    @Binding var selection: Int
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Group Count", text: "\(selection)")
        } else {
            Picker("Group Count", selection: $selection) {
                ForEach(PlayerNumbers.groups, id: \.self) { groupCount in
                    Text("\(groupCount) Groups").tag(groupCount)
                }
            }
        }
    }
}

struct PickerNumPerGroup: View {
    @Binding var selection: Int
    @Binding var isEdit: Bool

    var body: some View {
        
        if !isEdit {
            TextLabel("Players in Group", text: "\(selection)")
        } else {
            Picker("Players in Group", selection: $selection) {
                ForEach(PlayerNumbers.numbers, id: \.self) { number in
                    Text("\(number) Per Group").tag(number)
                }
            }
        }
    }
}
