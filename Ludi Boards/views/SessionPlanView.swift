//
//  SessionPlanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI

struct BoardSessionDetailsForm: View {
    var boardId: String
    // Assuming you have a similar way to fetch your data in SwiftUI
    @State private var screenWidth = "1500"
    @State private var screenHeight = "2000"
    @State private var backgroundImg = "Soccer 1"
    @State private var sport = "soccer"
    @State private var title = ""
    @State private var description = ""
    @State private var objective = ""
    @State private var isOpen = true

    // Replace with your data fetching logic
    private func fetchBoardDetails() {
        // Fetch board details and update state variables
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            InputField(label: "Title", value: $title, onValueChange: { title = $0 })
            InputField(label: "Description", value: $description, onValueChange: { description = $0 })
            InputField(label: "Objective", value: $objective, onValueChange: { objective = $0 })
            InputField(label: "Screen Width", value: $screenWidth, onValueChange: { screenWidth = $0 })
            InputField(label: "Screen Height", value: $screenHeight, onValueChange: { screenHeight = $0 })
            Toggle("Is Open", isOn: $isOpen)
            Text(backgroundImg)
            // Add additional UI components as needed
        }
        .padding()
        .onAppear {
            fetchBoardDetails()
        }
    }
}

struct InputSwitch: View {
    @Binding var isChecked: Bool
    var onCheckedChange: (Bool) -> Void

    var body: some View {
        Toggle(isOn: $isChecked) {
            Text(isChecked ? "On" : "Off")
        }.onChange(of: isChecked, perform: onCheckedChange)
    }
}

struct BoardSessionDetailsForm_Previews: PreviewProvider {
    static var previews: some View {
        BoardSessionDetailsForm(boardId: "123")
    }
}

