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
    @State private var email: String = "email@example.com"
    @State private var phoneNumber: String = "123-456-7890"
    @State private var membershipType: Int = 0
    @State private var accountCreationDate: String = "Jan 1, 2020"
    @State private var visibility: String = "closed"
    @State private var photoUrl: String = "default_image_url"
    
    @State private var showChatButton = true
    @State private var showAddBuddyButton = true
    @State private var showShareActivityButton = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 30)
                
                Text(username)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(status)
                    .font(.subheadline)
                    .foregroundColor(status == "Online" ? .green : .gray)

                Divider()
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("About Me:")
                        .font(.headline)
                        .padding(.bottom, 5)

                    Text(aboutMe)
                }
                .padding(.horizontal)
                
                // Additional Info
                Group {
                    profileInfoRow(title: "Email", value: email)
                    profileInfoRow(title: "Phone", value: phoneNumber)
                    profileInfoRow(title: "Membership Type", value: String(membershipType))
                    profileInfoRow(title: "Account Created", value: accountCreationDate)
                    profileInfoRow(title: "Visibility", value: visibility)
                }
                .padding(.horizontal)
                
                if showAddBuddyButton {
                    Button("Add Buddy") {
                        // Add buddy action
                    }
                    .buttonStyle(ActionButtonStyle())
                }
                
                if showChatButton {
                    Button("Chat") {
                        // Chat action
                    }
                    .buttonStyle(ActionButtonStyle())
                }

                if showShareActivityButton {
                    Button("Share Activity") {
                        // Share activity action
                    }
                    .buttonStyle(ActionButtonStyle())
                }
                Spacer()
            }
            .padding(.bottom, 20)
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
    
    private func profileInfoRow(title: String, value: String) -> some View {
            VStack(alignment: .leading) {
                Text(title + ":")
                    .font(.headline)
                Text(value)
                    .font(.body)
                Divider()
            }
        }
}


struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct BuddyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        BuddyProfileView()
    }
}
