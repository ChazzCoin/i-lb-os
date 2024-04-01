//
//  TeamDetailsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import SwiftUI

struct TeamDetailsView: View {
    
    @State var sport: String = ""
    
    @State private var teamName: String = ""
    @State private var coachName: String = ""
    @State private var sportType: String = ""
    @State private var logoUrl: String? = nil
    @State private var foundedYear: String = "2020"
    @State private var homeCity: String = ""
    @State private var stadiumName: String = ""
    @State private var roster: [String] = [] // Converted from List<String>
    @State private var coach: String = ""
    @State private var manager: String = ""
    @State private var league: String = ""
    @State private var achievements: [String] = [] // Converted from List<String>
    @State private var officialWebsite: String? = nil
    @State private var socialMediaLinks: [String] = [] // Converted from List<String>

    @State var realmInstance = newRealm()
    @State var isEditMode: Bool = true
    
    var body: some View {
        
        BaseDetailsView(
            navTitle: "Team",
            headerBuilder: {
                HStack {
                    SOLCON(
                        icon: SolIcon.save,
                        onTap: {
                            
                        }
                    )
                    
                    SOLCON(
                        icon: SolIcon.delete,
                        onTap: {
                            
                        }
                    )
                    
                    Spacer()
                    Text(isEditMode ? "Done" : "Edit")
                        .foregroundColor(.blue)
                        .onTapAnimation {
                            isEditMode.toggle()
                        }
                    
                }
                
            },
            bodyBuilder: {
                Section("Team Details") {
                    PickerSport(selection: $sport, isEdit: $isEditMode)
                    InputText(label: "Team Name", text: $teamName, isEdit: $isEditMode)
                    InputText(label: "Coach Name", text: $coachName, isEdit: $isEditMode)
//                    FoundingYearPickerView()
                    
                }
                
            },
            footerBuilder: {
                EmptyView()
            })
        
    }
}

#Preview {
    TeamDetailsView()
}
