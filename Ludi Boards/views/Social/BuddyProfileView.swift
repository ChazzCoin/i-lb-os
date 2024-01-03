//
//  BuddyProfileView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI

struct BuddyProfileView: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @State private var username: String = "User123"
    @State private var status: String = "Online"
    @State private var aboutMe: String = "Just enjoying the world of coding and tech!"
    @State private var email: String = "email@example.com"
    @State private var phoneNumber: String = "123-456-7890"
    @State private var membershipType: Int = 0
    @State private var accountCreationDate: String = "Jan 1, 2020"
    @State private var visibility: String = "closed"
    @State private var photoUrl: String = "default_image_url"
    
    @State private var showNewPlanSheet = false
    @State private var showChatButton = true
    @State private var showAddBuddyButton = true
    @State private var showShareActivityButton = true
    
    var body: some View {
        LoadingForm() { runLoading in
            Group() {
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
                    .foregroundColor(status == "online" ? .green : .gray)

                Divider()
                    .padding(.horizontal)
                
                // Additional Info
//                Group {
//                    profileInfoRow(title: "Membership Type", value: String(membershipType))
//                    profileInfoRow(title: "Account Created", value: accountCreationDate)
//                    profileInfoRow(title: "Visibility", value: visibility)
//                }
//                .padding(.horizontal)
                solButton(title: "Sign Out", action: {
                    runLoading()
                    logoutUser() { result in
                        print("User Logged Out. \(result)")
                    }
                    if let user = self.BEO.realmInstance.findByField(CurrentSolUser.self, value: CURRENT_USER_ID) {
                        self.BEO.realmInstance.safeWrite { r in
                            user.userId = ""
                            user.userName = ""
                            user.email = ""
                            user.imgUrl = ""
                            user.isLoggedIn = false
                        }
                    }
                    self.BEO.userId = nil
                    self.BEO.userName = nil
                    self.BEO.isLoggedIn = false
                }, isEnabled: true)
                
                if showAddBuddyButton {
                    Button("Add Buddy") {
                        // Add buddy action
                        showNewPlanSheet = true
                    }
                    .buttonStyle(ActionButtonStyle())
                }
                
//                if showChatButton {
//                    Button("Chat") {
//                        // Chat action
//                    }
//                    .buttonStyle(ActionButtonStyle())
//                }

//                if showShareActivityButton {
//                    Button("Share Activity") {
//                        // Share activity action
//                    }
//                    .buttonStyle(ActionButtonStyle())
//                }
//                Spacer()
            }
            .padding(.bottom, 20)
        }
        .refreshable {
            loadUser()
        }
        .onAppear() {
            loadUser()
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .sheet(isPresented: $showNewPlanSheet) {
            AddBuddyView(isPresented: $showNewPlanSheet)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    // Edit profile action
                }
            }
        }
    }
    
    func loadUser() {
        syncUserFromFirebaseDb(email) { result in
            print(result)
            if let user = self.BEO.realmInstance.getCurrentSolUserId() {
                username = user.userName
                email = user.email
                status = "online"
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

//struct BuddyProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        BuddyProfileView()
//    }
//}
