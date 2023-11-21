//
//  BuddyProfileView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI

struct BuddyProfileView: View {
    @State private var username: String = "User123"
    @State private var status: String = "Online"
    @State private var aboutMe: String = "Just enjoying the world of coding and tech!"

    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.top, 20)

            Text(username)
                .font(.title)
                .padding(.top, 10)

            Text(status)
                .font(.subheadline)
                .foregroundColor(.green)
                .padding(.bottom, 20)

            HStack {
                Text("About Me:")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            Text(aboutMe)
                .padding()

            Spacer()
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    // Edit profile action
                }
            }
        }
    }
}

struct BuddyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        BuddyProfileView()
    }
}
