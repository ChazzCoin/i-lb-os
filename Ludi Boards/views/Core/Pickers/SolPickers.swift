//
//  Solponents.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/14/24.
//

import Foundation
import SwiftUI
import RealmSwift

// Sport Picker 'SolSportPicker'
let sports = ["Soccer", "Basketball", "Baseball", "Football", "Hockey", "Tennis", "Volleyball", "Rugby", "Cricket", "Golf"]

struct PickerSport: View {
    @Binding var selection: String
    @Binding var isEdit: Bool
    var body: some View {
        CorePicker(selection: $selection, data: sports, title: "Sport", isEdit: $isEdit)
    }
}

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
                .foregroundColor(.blue)
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
        if !isEnabled {
            TextLabel("Free Players", text: "Player Selector")
        } else {
            if allPlayers.isEmpty {
                TextLabel("Free Players", text: "No Free Players Available.")
            } else {
                Picker("Free Players", selection: $selection) {
                    ForEach(allPlayers, id: \.self) { item in
                        Text(item.name).tag(item.name)
                    }
                }
                .foregroundColor(.blue)
                .pickerStyle(MenuPickerStyle())
            }
        }
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
            .foregroundColor(.blue)
        }
    }
}


struct PickerDate: View {
    @Binding var selection: Date
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Scheduled Date", text: "\(DateTimeTools.toDisplayText(fromTimestamp: selection))")
        } else {
            DatePicker("Scheduled Date", selection: $selection, displayedComponents: .date)
                .foregroundColor(.blue)
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
            .foregroundColor(.blue)
        }
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
            .foregroundColor(.blue)
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
            .foregroundColor(.blue)
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
            .foregroundColor(.blue)
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
            .foregroundColor(.blue)
        }
    }
}

struct PickerWeight: View {
    
    @Binding var selection: String
    @Binding var isEdit: Bool
    let weightOptions: [Int] = Array(50...500)
    
    var body: some View {
        if !isEdit {
            TextLabel("Weight", text: selection)
        } else {
            HStack {
                Text("Weight")
                    .foregroundColor(.blue)
                
                Spacer()

                Picker("Pounds", selection: $selection) {
                    ForEach(weightOptions, id: \.self) { pounds in
                        Text("\(pounds) Pounds").tag(String("\(pounds) Pounds"))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 200, height: 75)
            }
            .frame(height: 50)
        }
    }
}
struct PickerHeight: View {
    
    @Binding var selection: String
    @Binding var isEdit: Bool
    @State private var selectedFeet: Int = 5
    @State private var selectedInches: Int = 0
    
    // Arrays to hold the feet and inches options
    let feetOptions: [Int] = Array(4...7) // Adjust the range as needed
    let inchesOptions: [Int] = Array(0...11)
    
    var body: some View {
        if !isEdit {
            TextLabel("Height", text: selection)
        } else {
            HStack {
                Text("Height")
                    .foregroundColor(.blue)
                
                Spacer()

                // Picker for selecting feet
                Picker("Feet", selection: $selectedFeet) {
                    ForEach(feetOptions, id: \.self) { feet in
                        Text("\(feet) Feet").tag(feet)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 150, height: 100)
                .clipped()

                // Picker for selecting inches
                Picker("Inches", selection: $selectedInches) {
                    ForEach(inchesOptions, id: \.self) { inches in
                        Text("\(inches) Inches").tag(inches)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 150, height: 100)
            }
            .frame(height: 75)
            .onChange(of: selectedFeet, perform: { value in
                selection = "\(selectedFeet) Feet, \(selectedInches) Inches"
            })
            .onChange(of: selectedInches, perform: { value in
                selection = "\(selectedFeet) Feet, \(selectedInches) Inches"
            })
        }
    }
}

struct PickerDominateFoot: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Dominate Foot", text: selection)
        } else {
            Picker("Dominate Foot", selection: $selection) {
                ForEach(DominateFoot.allCases, id: \.self) { item in
                    Text(item.rawValue).tag(item.rawValue)
                }
            }
            .foregroundColor(.blue)
        }
    }
}

struct PickerDominateHand: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Dominate Hand", text: selection)
        } else {
            Picker("Dominate Hand", selection: $selection) {
                ForEach(DominateHand.allCases, id: \.self) { item in
                    Text(item.rawValue).tag(item.rawValue)
                }
            }
            .foregroundColor(.blue)
        }
    }
}
