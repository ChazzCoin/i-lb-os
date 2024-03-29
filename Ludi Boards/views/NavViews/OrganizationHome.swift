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
    var organization: Organization
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let logoUrl = organization.logoUrl, let url = URL(string: logoUrl) {
                    AsyncImage(url: url)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                }
                
                Text(organization.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 5)
                
                Text("Founded: \(organization.founded)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(organization.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 1)
                
                if let website = organization.officialWebsite, let url = URL(string: website) {
                    Link("Visit Official Website", destination: url)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Text(organization.descriptionText)
                    .padding(.vertical, 5)
                
                if !organization.socialMediaLinks.isEmpty {
                    Text("Follow Us")
                        .font(.headline)
                        .padding(.vertical, 2)
                    
                    HStack {
                        ForEach(organization.socialMediaLinks, id: \.self) { link in
                            if let url = URL(string: link) {
                                Link(destination: url) {
                                    Image(systemName: "globe")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Organization Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}


