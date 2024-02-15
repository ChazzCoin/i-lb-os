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

    var body: some View {
        Picker("Number of Players", selection: $selection) {
            ForEach(PlayerNumbers.numbers, id: \.self) { number in
                Text(String(number)).tag(number)
            }
        }
//        .pickerStyle(WheelPickerStyle())
    }
}


struct PickerDate: View {
    @Binding var selection: Date

    var body: some View {
        DatePicker("Scheduled Date", selection: $selection, displayedComponents: .date)
//            .datePickerStyle(GraphicalDatePickerStyle())
    }
}


struct PickerIntensity: View {
    @Binding var selection: String

    var body: some View {
        Picker("Intensity", selection: $selection) {
            ForEach(IntensityLevel.allCases) { intensityLevel in
                Text(intensityLevel.rawValue).tag(intensityLevel.rawValue)
            }
        }
//        .pickerStyle(SegmentedPickerStyle())
    }
}


struct PickerAgeLevel: View {
    @Binding var selection: String

    var body: some View {
        Picker("Age Level", selection: $selection) {
            ForEach(AgeLevel.allCases) { age in
                Text(age.rawValue).tag(age.rawValue)
            }
        }
//        .pickerStyle(WheelPickerStyle())
    }
}


struct PickerTimeDuration: View {
    @Binding var selection: String

    var body: some View {
        Picker("Time Duration", selection: $selection) {
            ForEach(TimeDuration.allCases) { duration in
                Text("\(duration.rawValue) Minutes").tag(String(duration.rawValue))
            }
        }
//        .pickerStyle(MenuPickerStyle())
    }
}

struct PickerGroupCount: View {
    @Binding var selection: Int

    var body: some View {
        Picker("Group Count", selection: $selection) {
            ForEach(PlayerNumbers.groups, id: \.self) { groupCount in
                Text("\(groupCount) Groups").tag(groupCount)
            }
        }
//        .pickerStyle(WheelPickerStyle())
    }
}

struct PickerNumPerGroup: View {
    @Binding var selection: Int

    var body: some View {
        Picker("Players in Group", selection: $selection) {
            ForEach(PlayerNumbers.numbers, id: \.self) { number in
                Text("\(number) Per Group").tag(number)
            }
        }
//        .pickerStyle(WheelPickerStyle())
    }
}
