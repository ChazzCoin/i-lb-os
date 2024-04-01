//
//  OrganizationDetailsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import SwiftUI

struct OrganizationDetailsView: View {
    
    @State var sport: String = ""
    
    @State private var orgName: String = ""
    @State private var type: String = ""
    @State private var logoUrl: String? = nil
    @State private var founded: Int = 0
    @State private var location: String = ""
    @State private var contactInfo: String = ""
    @State private var descriptionText: String = ""
    @State private var sports: [String] = [] // Converted from List<String>
    @State private var officialWebsite: String? = nil
    @State private var members: Int = 0
    @State private var socialMediaLinks: [String] = [] // Converted from List<String>

    @State var realmInstance = newRealm()
    @State var isEditMode: Bool = true
    
    func saveNewOrg() {
        
    }
    func updateOrg() {
        
    }
    
    var body: some View {
        
        BaseDetailsView(
            navTitle: "Organization",
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
                Section("Organization Details") {
                    PickerSport(selection: $sport, isEdit: $isEditMode)
                    InputText(label: "Organization Name", text: $orgName, isEdit: $isEditMode)
                }
                
            },
            footerBuilder: {
                EmptyView()
            })
        
    }
}

#Preview {
    OrganizationDetailsView()
}
