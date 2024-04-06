//
//  SolListItem.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import CoreEngine

struct SolListItem: View {
    var title: String
    var subTitle: String
    var isShared: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            
            HStack {
                Image(systemName: "person.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                    .padding(.top, 30)
                Text(title)
                    .font(.headline) // Bold and slightly larger font for the title
                    .foregroundColor(colorScheme == .dark ? .secondaryBackground : .white) // Default high-contrast text color
            }
            
            Text(subTitle)
                .font(.subheadline) // Slightly smaller and thinner font for the subtitle
                .foregroundColor(colorScheme == .dark ? .secondaryBackground : .white) // Default secondary text color (more subdued)
//            Spacer() // Pushes the content to the left
            if isShared {
                Image(systemName: "person.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                    .padding(.top, 30)
            }
            Spacer()
        }
//        .padding() // Padding around the HStack content
        .frame(width: 200, height: 200, alignment: .leading) // Ensures the view stretches to the width of its container
        .background(colorScheme == .dark ? .white : .secondaryBackground) // Default background color
        .cornerRadius(10) // Optional: if you want rounded corners
        .shadow(radius: 1) // Optional: if you want a subtle shadow for some depth
    }
}

struct SolListSingleItem: View {
    var title: String
    var isShared: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline) // Bold and slightly larger font for the title
                    .foregroundColor(.primaryBackground) // Default high-contrast text color
            }
            Spacer() // Pushes the content to the left
            if isShared {
                Image(systemName: "person.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                    .padding(.top, 30)
            }
        }
        .padding() // Padding around the HStack content
        .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading) // Ensures the view stretches to the width of its container
        .background(Color(.systemBackground)) // Default background color
        .cornerRadius(10) // Optional: if you want rounded corners
        .shadow(radius: 1) // Optional: if you want a subtle shadow for some depth
    }
}

struct SessionListItem: View {
    var session: SessionPlan

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            
            HStack {
                Image(systemName: "person.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                    .padding(.top, 30)
                Text(session.title)
                    .font(.headline) // Bold and slightly larger font for the title
                    .foregroundColor(colorScheme == .dark ? .secondaryBackground : .white) // Default high-contrast text color
            }
            
            Text(session.subTitle)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .secondaryBackground : .white)
            
            Text(session.category)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .secondaryBackground : .white)
            
            Text(session.intensity)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .secondaryBackground : .white)

            
            Spacer()
        }
//        .padding() // Padding around the HStack content
        .frame(width: 200, height: 200, alignment: .leading) // Ensures the view stretches to the width of its container
        .background(colorScheme == .dark ? .white : .secondaryBackground) // Default background color
        .cornerRadius(10) // Optional: if you want rounded corners
        .shadow(radius: 1) // Optional: if you want a subtle shadow for some depth
    }
}
