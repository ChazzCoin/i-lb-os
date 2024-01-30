//
//  SolPlayerRefPicker.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct SolPlayerRefFreePicker: View {
    @Binding var selection: String
    @Binding var isEnabled: Bool
    @ObservedResults(PlayerRef.self, where: { $0.teamId == "" }) var allPlayers
    
    var body: some View {
        Picker(selection: $selection, label: HeaderText("Players")) {
            ForEach(allPlayers, id: \.self) { item in
                Text(item.name)
                    .tag(item.id)
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
