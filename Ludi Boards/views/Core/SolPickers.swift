//
//  Solponents.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/14/24.
//

import Foundation
import SwiftUI


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
