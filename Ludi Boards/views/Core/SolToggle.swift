//
//  SolToggle.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/7/24.
//

import Foundation
import SwiftUI

struct SolToggle: View {
    var labelText: String
    @Binding var isOn: Bool
    var onToggleChange: ((Bool) -> Void)? // Optional closure to handle changes
    
    @Environment(\.colorScheme) var colorScheme // Access the color scheme directly if needed

    var body: some View {
        HStack {
            Spacer() // Ensures the switch is right-aligned if needed.
            Text(labelText)
                .foregroundColor(getTextColorOnBackground(colorScheme)) // Assuming you have this function defined elsewhere
                .onTapGesture {
                    isOn.toggle()
                }
            Toggle("", isOn: $isOn)
                .labelsHidden() // Hide the default label of the Toggle.
                .onChange(of: isOn) { newValue in
                    onToggleChange?(newValue) // Call the optional closure with the new value
                }
        }
    }
    
    // Placeholder for your existing method to get text color based on the color scheme
    func getTextColorOnBackground(_ colorScheme: ColorScheme) -> Color {
        // Example implementation, adjust according to your actual function
        colorScheme == .dark ? .white : .black
    }
}



