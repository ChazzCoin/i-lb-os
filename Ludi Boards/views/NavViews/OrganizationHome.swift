//
//  OrganizationHome.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 3/29/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct OrganizationDashboardView: View {
    var orgId: String
    @State var organization: Organization? = nil
    @State var isEmpty: Bool = false

    
    var body: some View {
        // Card for Organization Details
        HStack {
            
            if isEmpty {
                VStack(alignment: .leading) {
                    // Organization Name
                    Text("No Organization")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.vertical, 2)
                    
                    // Organization Description
                    Text("Create or Join an Organization.")
                        .padding(.bottom, 5)
                }
            } else {
                // Organization Logo or Placeholder
                if let organization = organization, let url = URL(string: organization.logoUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Image("sol_icon")
                            .resizable()
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(10)
                    .padding(.bottom, 5)
                } else {
                    Image("sol_icon")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.bottom, 5)
                }
                
                VStack(alignment: .leading) {
                    // Organization Name
                    Text(organization?.name ?? "Organization Name")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.vertical, 2)
                    
                    // Organization Description
                    Text(organization?.descriptionText ?? "No description available.")
                        .padding(.bottom, 5)
                }
            }
            
            Spacer()
        }
        .background(Color.white) // Consider using a custom color or .ultraThinMaterial for a frosted glass look
        .cornerRadius(15)
        .shadow(radius: 5)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            if let temp = newRealm().findByField(Organization.self, value: orgId) {
                organization = temp
                return
            }
            isEmpty = true
        }
    }
}


