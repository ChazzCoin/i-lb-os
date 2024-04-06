//
//  TeamItem.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine

struct TeamListView: View {
    // Assuming you have an array of image names from your assets
    var callback: (Team) -> Void
    @ObservedResults(Team.self) var teams
    
  

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 10) {
                
                if !teams.isEmpty {
                    ForEach(teams, id: \.self) { team in
                        TeamListItem(title: team.name, subTitle: team.foundedYear, isShared: false)
                            .onTapAnimation {
                                
                                callback(team)
                            }
                    }
                } else {
                    HeaderText("No Teams.")
                }
                
            }
            
        }
        .frame(height: 200)
        
    }
}

struct TeamListItem: View {
    var title: String
    var subTitle: String
    var isShared: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline) // Bold and slightly larger font for the title
                    .foregroundColor(.primaryBackground) // Default high-contrast text color
                Text(subTitle)
                    .font(.subheadline) // Slightly smaller and thinner font for the subtitle
                    .foregroundColor(.secondary) // Default secondary text color (more subdued)
            }
            Spacer() // Pushes the content to the left
        }
        .padding() // Padding around the HStack content
        .frame(maxWidth: 300, minHeight: 75, alignment: .leading) // Ensures the view stretches to the width of its container
        .background(Color(.systemBackground)) // Default background color
        .cornerRadius(10) // Optional: if you want rounded corners
        .shadow(radius: 1) // Optional: if you want a subtle shadow for some depth
    }
}
