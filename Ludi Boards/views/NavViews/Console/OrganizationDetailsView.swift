//
//  OrganizationDetailsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import SwiftUI
import CoreEngine

struct OrganizationDetailsView: View {
    
    var orgId: String
    
    @State var sport: String = ""
    
    @State private var orgName: String = ""
    @State private var type: String = ""
    @State private var logoUrl: String? = nil
    @State private var founded: String = ""
    @State private var location: String = ""
    @State private var contactInfo: String = ""
    @State private var descriptionText: String = ""
    @State private var sports: [String] = [] // Converted from List<String>
    @State private var officialWebsite: String? = nil
    @State private var members: Int = 0
    @State private var socialMediaLinks: [String] = [] // Converted from List<String>

    @State var realmInstance = newRealm()
    @State var isEditMode: Bool = true
    
    func save() {
        if orgId == "new" { saveNewOrg()
        } else { updateOrg() }
    }
    
    func saveNewOrg() {
        let newOrg = Organization()
        newOrg.name = orgName
        newOrg.founded = founded
        newOrg.type = type
        newOrg.location = location
        newOrg.contactInfo = contactInfo
        newOrg.memberCount = members
        newOrg.descriptionText = descriptionText
        realmInstance.safeWrite { r in
            r.create(Organization.self, value: newOrg)
        }
    }
    func updateOrg() {
        if let org = realmInstance.findByField(Organization.self, value: orgId) {
            realmInstance.safeWrite { r in
                org.name = orgName
                org.founded = founded
                org.type = type
                org.location = location
                org.contactInfo = contactInfo
                org.memberCount = members
                org.descriptionText = descriptionText
            }
        }
    }
    
    var body: some View {
        
        BaseDetailsView(
            navTitle: "Organization",
            headerBuilder: {
                HStack {
                    SOLCON(
                        icon: SolIcon.save,
                        onTap: {
                            save()
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
                    CoreInputText(label: "Organization Name", text: $orgName, isEdit: $isEditMode)
                    CoreInputText(label: "Location", text: $location, isEdit: $isEditMode)
                    PickerYear(selection: $founded, isEdit: $isEditMode)
                    InputTextMultiLine("Details", text: $descriptionText, isEdit: $isEditMode)
                }
                
            },
            footerBuilder: {
                EmptyView()
            })
        
    }
}

#Preview {
    OrganizationDetailsView(orgId: "new")
}
