//
//  SolPicker.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
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
                            .tag(item.id)
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
