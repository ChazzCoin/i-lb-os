//
//  EventType.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import SwiftUI

enum EventType: String, CaseIterable {
    case practice = "Practice"
    case scrimmage = "Scrimmage"
    case game = "Game"
    case tournament = "Tournament"
    case teamMeeting = "Team Meeting"
    case trainingSession = "Training Session"
    case tryOut = "Try Out"
    case fundraiser = "Fundraiser"
    case communityEvent = "Community Event"
}

struct PickerEventType: View {
    @Binding var selection: String
    @Binding var isEdit: Bool

    var body: some View {
        if !isEdit {
            TextLabel("Event Type", text: selection)
        } else {
            Picker("Event Type", selection: $selection) {
                ForEach(EventType.allCases, id: \.self) { eventType in
                    Text(eventType.rawValue).tag(eventType.rawValue)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}
